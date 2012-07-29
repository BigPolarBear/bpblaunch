//
//  BPBLaunchControllerViewController.m
//  bpblaunch
//
//  Created by BigPolarBear on 7/9/12.
//
//

#import "BPBLaunchScrollView.h"
#import "BPBTool.h"

#define icon_width      57
#define icon_height     57
#define title_width     57
#define title_height    17
#define title_font      [UIFont boldSystemFontOfSize:12]
#define between_title_icon  4

#define total_width     icon_width
#define total_height    (icon_height + title_height + between_title_icon)

#define default_numberOfColumns 4

@interface BPBLaunchScrollView ()
{
}
@property (nonatomic,retain) NSMutableArray* innerSubviews;

@end

@implementation BPBLaunchScrollView

@synthesize innerSubviews;
@synthesize defaultIconImage;
@synthesize dataSource;

-(void)setDataSource:(id<BPBLaunchScrollViewDataSource>)ds
{
    dataSource = ds;
    [self reloadData];
}

@synthesize numberOfColumns;
-(void)setNumberOfColumns:(NSInteger)aNumberOfColumns
{
    numberOfColumns = aNumberOfColumns;
}

-(id)init
{
    self = [super init];
    
    [self setPagingEnabled:NO];
    [self setShowsVerticalScrollIndicator:NO];
    [self setShowsHorizontalScrollIndicator:NO];
    [self setBackgroundColor:[UIColor clearColor]];
    
    [self setMaximumZoomScale:1];
    [self setMinimumZoomScale:1];
    
    self.userInteractionEnabled = YES;
    
    self.bounces = NO;
    self.alwaysBounceHorizontal = NO;
    self.alwaysBounceVertical = NO;
    
    return self;
}

-(void)iconClicked:(UIView*)sender
{
    if(self.delegate && [self.delegate conformsToProtocol:@protocol(BPBLaunchScrollViewDelegate)])
    {
        id<BPBLaunchScrollViewDelegate> bpbLaunchDelegate = (id<BPBLaunchScrollViewDelegate>)self.delegate;
        [bpbLaunchDelegate BPBLaunchController:self didClicked:sender.tag];
    }
}

-(UIButton*)createButtonWithTag:(NSInteger)tag
{
    UIButton* buttonIcon = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, icon_width, icon_height)];
    buttonIcon.tag = tag;
    [buttonIcon addTarget:self action:@selector(iconClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return buttonIcon;
}

-(void)addSubview:(UIView *)view
{
    if(!self.innerSubviews)
    {
        self.innerSubviews = [[NSMutableArray alloc]init];
    }
    
    [self.innerSubviews addObject:view];
    
    [super addSubview:view];
}
-(void)removeAllInnerSubviews
{
    for (UIView* innerSubview in self.innerSubviews) {
        [innerSubview removeFromSuperview];
    }
}

-(void)reloadData
{
    // 移除所有的subview     remove all subviews
    [self removeAllInnerSubviews];
    
    // 中心点间距    space between icon center point
    CGFloat spaceCenter = (self.frame.size.width - self.contentInset.left - self.contentInset.right - total_width)/(self.numberOfColumns - 1);

    // 图标间距     space between icon
    CGFloat spaceBorder = spaceCenter - total_width;
    
    
    // 总数       get number of items
    int numberOfUserInfo = [self.dataSource numberOfUserInfoInBPBLaunchController:self];
    // 有多少行    number of rows
    int numberOfRows;
    if(numberOfUserInfo == 0)
    {
        numberOfRows = 0;
    }
    else if(numberOfUserInfo % self.numberOfColumns == 0)
    {
        numberOfRows = numberOfUserInfo / self.numberOfColumns;
    }
    else
    {
        numberOfRows = numberOfUserInfo / self.numberOfColumns + 1;
    }

    float heightOfContent = total_height * numberOfRows + (numberOfRows-1) * spaceBorder;
    float widthOfContent = self.frame.size.width;
    self.contentSize = CGSizeMake(widthOfContent - self.contentInset.left - self.contentInset.right, heightOfContent);
    self.bounces = NO;
    self.alwaysBounceHorizontal = NO;
    
    NSLog(@"spaceCenter:%f",spaceCenter);
    NSLog(@"spaceBorder:%f",spaceBorder);
    NSLog(@"contentSize:(%f,%f)",self.contentSize.width,self.contentSize.height);
    NSLog(@"contentOffset:(%f,%f)",self.contentOffset.x,self.contentOffset.y);

    
    for (int iCnt = 0; iCnt<numberOfUserInfo; iCnt++)
    {
        int iRow = iCnt / numberOfColumns;
        int iCol = iCnt % numberOfColumns;
        
        // 承载的背景标签 label that will contain icon and title
        UILabel* labelBackground = [[UILabel alloc]init];
        CGRect frame = labelBackground.frame;
        frame.size = CGSizeMake(total_width, total_height);
        labelBackground.frame = frame;
        labelBackground.backgroundColor = [UIColor clearColor];
        labelBackground.userInteractionEnabled = YES;
        
        // 计算位置 caculate center point
        CGFloat centerX = total_width / 2 + spaceCenter*iCol;
        CGFloat centerY = total_height / 2 + (total_height + spaceBorder)*iRow;
        labelBackground.center = CGPointMake(centerX, centerY);
        NSLog(@"iCnt:%d (%f,%f)",iCnt,centerX,centerY);
        
        // 增加图标按钮 add icon
        UIButton* buttonIcon = [self createButtonWithTag:iCnt];
        [labelBackground addSubview:buttonIcon];

        // 设置图标图片 set icon image by url
        NSString* imgUrl = [self.dataSource imageUrlAtIndex:iCnt];
        if(self.defaultIconImage)
        {
            [buttonIcon setImage:self.defaultIconImage forState:UIControlStateNormal];
        }
        [BPBTool loadRemoteImage:imgUrl usingCache:YES completion:^(BOOL success, UIImage *image, NSError *error) {
           if(success)
           {
               // 替换图标图片    use new button with loaded image
               UIButton* newButtonIcon = [self createButtonWithTag:iCnt];
               
               newButtonIcon.alpha = 0;
               [newButtonIcon setImage:image forState:UIControlStateNormal];
               [labelBackground addSubview:newButtonIcon];
               
               // 老的按钮淡出，新按钮淡入  old button fade out while new button fade in
               [UIView animateWithDuration:1 animations:^{
                   newButtonIcon.alpha = 1;
                   buttonIcon.alpha = 0;
               } completion:^(BOOL finished) {
                   if(buttonIcon.superview)
                   {
                       [buttonIcon removeFromSuperview];
                   }
                   else
                   {
                       NSLog(@"buttonIcon.superview is nil");
                   }
               }];
           }
        }];
        
        // 增加文字     add title
        UILabel* labelTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, icon_height + between_title_icon, title_width, title_height)];
        // todo 可由外部设置
        labelTitle.font = title_font;
        labelTitle.textAlignment = UITextAlignmentCenter;
        labelTitle.textColor = [UIColor whiteColor];
        labelTitle.shadowColor = [UIColor darkGrayColor];
        labelTitle.shadowOffset = CGSizeMake(0, 1);
        labelTitle.backgroundColor = [UIColor clearColor];
        NSString* title = [self.dataSource titleAtIndex:iCnt];
        labelTitle.text = title;
        
        [labelBackground addSubview:labelTitle];
        [self addSubview:labelBackground];
    }
}



@end
