//
//  BPBLaunchControllerViewController.m
//  bpblaunch
//
//  Created by BigPolarBear on 7/9/12.
//
//

#import "BPBLaunchScrollView.h"
#import "BPBLaunchItemView.h"

#import "BPBTool.h"
#import <QuartzCore/QuartzCore.h>


#define default_numberOfColumns 4



@interface BPBLaunchScrollView ()
{
}
@property (nonatomic,retain) NSMutableArray* itemViews;

-(void)buttonIconLongPressed:(id)sender;





@end

@implementation BPBLaunchScrollView

@synthesize dataSource;

@synthesize defaultIconImage;

@synthesize allowEnableEditMode;
@synthesize iconCornerRadius;
@synthesize imageUrlPrefixArray;


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
@synthesize editMode;
-(void)setEditMode:(BOOL)newEditMode
{
    if(editMode == newEditMode)
    {
        return;
    }
    editMode = newEditMode;
    
    // 所有图标左上角的删除按钮显示 show the cancel top left cancel button of icon
    for (BPBLaunchItemView* item in self.itemViews) {
        [UIView animateWithDuration:cancel_button_show_animation_duration animations:^{
            if(editMode)
            {
                item.buttonDelete.alpha = 1;
            }
            else
            {
                item.buttonDelete.alpha = 0;
            }
        }];
    }
 }

@synthesize itemViews;
-(NSMutableArray*)itemViews
{
    if(!itemViews)
    {
        itemViews = [[NSMutableArray alloc]init];
    }
    
    return itemViews;
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

-(void)buttonIconClicked:(UIView*)sender
{
    if(self.editMode)
    {
        // 编辑模式下，点击图标事件无效   in edit mode，ignore icon click event
        return;
    }
    
    if(self.delegate && [self.delegate conformsToProtocol:@protocol(BPBLaunchScrollViewDelegate)])
    {
        id<BPBLaunchScrollViewDelegate> bpbLaunchDelegate = (id<BPBLaunchScrollViewDelegate>)self.delegate;
        [bpbLaunchDelegate BPBLaunchController:self didClicked:sender.tag];
    }
}
-(void)buttonDeleteClicked:(UIButton*)sender
{
    NSInteger index = sender.tag;
    
    // 删除此位置的按钮
    if(index < self.itemViews.count)
    {
        [UIView animateWithDuration:item_delete_animation_duration animations:^{
            BPBLaunchItemView* currentItem = [self.itemViews objectAtIndex:index];
            [currentItem removeFromSuperview];
            
            for (int iCnt = self.itemViews.count - 1; iCnt > index; iCnt--)
            {
                BPBLaunchItemView* item = (BPBLaunchItemView*)[self.itemViews objectAtIndex:iCnt];
                BPBLaunchItemView* preItem = (BPBLaunchItemView*)[self.itemViews objectAtIndex:iCnt-1];
                item.frame = preItem.frame;
                item.tag = preItem.tag;
                NSLog(@"tag:%d",item.tag);
            }
            [self.itemViews removeObject:currentItem];
        }];
        
        
        if(self.dataSource && [self.dataSource respondsToSelector:@selector(deleteItemAtIndex:)])
        {
            id<BPBLaunchScrollViewDataSource> bpbLaunchDataSource = (id<BPBLaunchScrollViewDataSource>)self.dataSource;
            [bpbLaunchDataSource deleteItemAtIndex:index];
            NSLog(@"buttonDeleteClicked:%d",index);
        }
    }
    

}
-(void)buttonIconLongPressed:(UIButton*)sender
{
    if(!self.editMode)
    {
        self.editMode = YES;
    }
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(BPBLaunchController:longPressed:)])
    {
        id<BPBLaunchScrollViewDelegate> bpbLaunchDelegate = (id<BPBLaunchScrollViewDelegate>)self.delegate;
        [bpbLaunchDelegate BPBLaunchController:self longPressed:sender.tag];
        NSLog(@"longPressedIcon:%d",sender.tag);
    }
}



-(void)reloadData
{
    // 移除所有的subview     remove all subviews
    for (BPBLaunchItemView* item in self.itemViews) {
        [item removeFromSuperview];
    }
    [self.itemViews removeAllObjects];
    
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
        
        // create itemView
        CGRect frame = CGRectZero;
        frame.size = CGSizeMake(total_width, total_height);
        BPBLaunchItemView* item = [[BPBLaunchItemView alloc]initWithFrame:frame];
        item.tag = iCnt;

        // 计算位置 caculate center point
        CGFloat centerX = total_width / 2 + spaceCenter*iCol;
        CGFloat centerY = total_height / 2 + (total_height + spaceBorder)*iRow;
        item.center = CGPointMake(centerX, centerY);        
        NSLog(@"iCnt:%d (%f,%f)",iCnt,centerX,centerY);
        
        // 设置删除按钮   set delete button
        if(editMode)
        {
            item.buttonDelete.alpha = 1;
        }
        else
        {
            item.buttonDelete.alpha = 0;
        }
        [item.buttonDelete addTarget:self action:@selector(buttonDeleteClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        // 设置图标按钮   set icon button
        [item.buttonIcon addTarget:self action:@selector(buttonIconClicked:) forControlEvents:UIControlEventTouchUpInside];
        item.buttonIcon.layer.cornerRadius = self.iconCornerRadius;
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(buttonIconLongPressed:)];
        [item.buttonIcon addGestureRecognizer:longPress];
        

        // 设置图标图片 set icon image by url
        BOOL imgAlreadySet = NO;
        NSString* imgUrl = [self.dataSource imageUrlAtIndex:iCnt];
        // 如果bundle里有这个图片则直接加载  if bundle has same image file then use it
        UIImage* bundleImg = [BPBTool loadBundleImageWhenImageUrl:imgUrl withPrefix:imageUrlPrefixArray];
        if(bundleImg)
        {
            [item.buttonIcon setImage:bundleImg forState:UIControlStateNormal];
            imgAlreadySet = YES;
        }
 
        if(!imgAlreadySet)
        {
            UIImage* cachedImg = [BPBTool loadCacheImage:imgUrl];
            if(cachedImg)
            {
                [item.buttonIcon setImage:cachedImg forState:UIControlStateNormal];
                imgAlreadySet = YES;
            }
        }
        
        if(!imgAlreadySet)
        {
            if(self.defaultIconImage)
            {
                [item.buttonIcon setImage:self.defaultIconImage forState:UIControlStateNormal];
            }
            
            [BPBTool loadRemoteImage:imgUrl usingCache:YES completion:^(BOOL success, UIImage *image, NSError *error) {
                if(success)
                {
                    // 替换图标图片    use new button with loaded image
                    [item.buttonIcon setImage:image forState:UIControlStateNormal];
                }
            }];

        }
             
        // 增加文字     add title
        item.labelName.text = [self.dataSource titleAtIndex:iCnt];
        
        
        [self.itemViews addObject:item];
        [self addSubview:item];
    }
}

#pragma mark 触控
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    self.editMode = NO;
}

@end
