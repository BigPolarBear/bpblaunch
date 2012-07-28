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

@end

@implementation BPBLaunchScrollView

@synthesize dataSource;
@synthesize defaultIconImage;
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
    
    [self setPagingEnabled:NO];   // 不分页
    [self setShowsVerticalScrollIndicator:NO];//不显示垂直滚动条
    [self setShowsHorizontalScrollIndicator:NO];//不显示水平滚动条
    [self setBackgroundColor:[UIColor clearColor]];   //设置背景为透明
    
    [self setMaximumZoomScale:1];
    [self setMinimumZoomScale:1];
    
    self.userInteractionEnabled = YES;
    
    self.bounces = NO;
    self.directionalLockEnabled = YES;

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

-(void)reloadData
{
    // 移除所有的subview
    for(UIView *subview in [self subviews]) {
        [subview removeFromSuperview];
    }
    
    // 中心点间距
    CGFloat spaceCenter = (self.frame.size.width - self.contentInset.left - self.contentInset.right - total_width)/(self.numberOfColumns - 1);

    // 图标间距
    CGFloat spaceBorder = spaceCenter - total_width;
    
    
    // 总数
    int numberOfUserInfo = [self.dataSource numberOfUserInfoInBPBLaunchController:self];
    // 有多少行
    int numberOfRows;
    if(numberOfUserInfo == 0)
    {
        numberOfRows = 0;
    }
    else
    {
        numberOfRows = numberOfUserInfo / self.numberOfColumns;
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
        
        // 承载的背景标签
        UILabel* labelBackground = [[UILabel alloc]init];
        CGRect frame = labelBackground.frame;
        frame.size = CGSizeMake(total_width, total_height);
        labelBackground.frame = frame;
        labelBackground.backgroundColor = [UIColor clearColor];
        labelBackground.userInteractionEnabled = YES;
        
        // 计算位置
        CGFloat centerX = total_width / 2 + spaceCenter*iCol;
        CGFloat centerY = total_height / 2 + (total_height + spaceBorder)*iRow;
        labelBackground.center = CGPointMake(centerX, centerY);
        NSLog(@"iCnt:%d (%f,%f)",iCnt,centerX,centerY);
        
        // 增加图标按钮
        UIButton* buttonIcon = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, icon_width, icon_height)];
        [labelBackground addSubview:buttonIcon];
        // tag记录下序号
        buttonIcon.tag = iCnt;
        // 增加点击事件
        [buttonIcon addTarget:self action:@selector(iconClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        // 设置图标图片
        NSString* imgUrl = [self.dataSource imageUrlAtIndex:iCnt];
        if(self.defaultIconImage)
        {
            [buttonIcon setImage:self.defaultIconImage forState:UIControlStateNormal];
        }
        [BPBTool loadRemoteImage:imgUrl usingCache:YES completion:^(BOOL success, UIImage *image, NSError *error) {
           if(success)
           {
               // 增加图标按钮
               UIButton* newButtonIcon = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, icon_width, icon_height)];
               // tag记录下序号
               newButtonIcon.tag = iCnt;
               // 增加点击事件
               [newButtonIcon addTarget:self action:@selector(iconClicked:) forControlEvents:UIControlEventTouchUpInside];
               newButtonIcon.alpha = 0;
               [newButtonIcon setImage:image forState:UIControlStateNormal];
               [labelBackground addSubview:newButtonIcon];
               
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
        
        // 增加文字
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
