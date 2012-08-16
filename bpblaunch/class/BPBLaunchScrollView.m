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
@property (nonatomic,retain) NSMutableArray* buttonDeletes;

-(void)handleLongPressGesture:(UIGestureRecognizer*)recognizer;






@end

@implementation BPBLaunchScrollView




#pragma mark property
@synthesize defaultIconImage;
@synthesize allowEnableEditMode;
@synthesize iconCornerRadius;
@synthesize imageUrlPrefixArray;

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
@synthesize editMode;
-(void)setEditMode:(BOOL)newEditMode
{
    if(editMode == newEditMode)
    {
        return;
    }
    editMode = newEditMode;
    
    // 所有图标左上角的删除按钮显示 show the cancel top left cancel button of icon
    for (int iCnt = 0; iCnt < self.buttonDeletes.count; iCnt++) {
        UIButton* button = [self.buttonDeletes objectAtIndex:iCnt];
        BOOL canShowDeleteButton = YES;
        if([self.dataSource respondsToSelector:@selector(canDeleteItemInEditModeAtIndex:)])
        {
            id<BPBLaunchScrollViewDataSource> ds = self.dataSource;
            canShowDeleteButton = [ds canDeleteItemInEditModeAtIndex:iCnt];
        }
        [UIView animateWithDuration:cancel_button_show_animation_duration animations:^{
            if(editMode && canShowDeleteButton)
            {
                button.alpha = 1;
            }
            else
            {
                button.alpha = 0;
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
@synthesize buttonDeletes;
-(NSMutableArray*)buttonDeletes
{
    if(!buttonDeletes)
    {
        buttonDeletes = [[NSMutableArray alloc]init];
    }
    return buttonDeletes;
}

#pragma mark life cycle
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

#pragma mark events
-(void)buttonIconClicked:(UIView*)sender
{
    if(self.editMode)
    {
        // 退出编辑模式   exit edit mode
        self.editMode = NO;
        return;
    }
    else
    {
        if(self.delegate && [self.delegate conformsToProtocol:@protocol(BPBLaunchScrollViewDelegate)])
        {
            id<BPBLaunchScrollViewDelegate> bpbLaunchDelegate = (id<BPBLaunchScrollViewDelegate>)self.delegate;
            [bpbLaunchDelegate BPBLaunchController:self didClicked:sender.tag];
        }
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
            UIButton* currentButtonDelete = [self.buttonDeletes objectAtIndex:index];
            [currentButtonDelete removeFromSuperview];
            
            for (int iCnt = self.itemViews.count - 1; iCnt > index; iCnt--)
            {
                BPBLaunchItemView* item = (BPBLaunchItemView*)[self.itemViews objectAtIndex:iCnt];
                BPBLaunchItemView* preItem = (BPBLaunchItemView*)[self.itemViews objectAtIndex:iCnt-1];
                item.frame = preItem.frame;
                item.tag = preItem.tag;
                
                UIButton* buttonDelete = (UIButton*)[self.buttonDeletes objectAtIndex:iCnt];
                UIButton* preButtonDelete = (UIButton*)[self.buttonDeletes objectAtIndex:iCnt-1];
                buttonDelete.frame = preButtonDelete.frame;
                buttonDelete.tag = preButtonDelete.tag;
                
                NSLog(@"tag:%d",item.tag);
            }
            [self.itemViews removeObjectAtIndex:index];
            [self.buttonDeletes removeObjectAtIndex:index];
        }];
        
        
        if(self.dataSource && [self.dataSource respondsToSelector:@selector(deleteItemAtIndex:)])
        {
            id<BPBLaunchScrollViewDataSource> bpbLaunchDataSource = (id<BPBLaunchScrollViewDataSource>)self.dataSource;
            [bpbLaunchDataSource deleteItemAtIndex:index];
            NSLog(@"buttonDeleteClicked:%d",index);
        }
    }
    

}

#pragma mark gesture

-(void)handleLongPressGesture:(UIGestureRecognizer*)recognizer
{
    if(!self.editMode)
    {
        self.editMode = YES;
    }
    
    if(recognizer.state == UIGestureRecognizerStateBegan)
    {
        //if needed do some initial setup or init of views here
    }
    else if(recognizer.state == UIGestureRecognizerStateChanged)
    {
//        //move your views here.
//        if([recognizer.view.superview isKindOfClass:[BPBLaunchItemView class]])
//        {
//            BPBLaunchItemView* currentItem = (BPBLaunchItemView*)recognizer.view.superview;
//            UIButton* currentButtonDelete = (UIButton*)[self.buttonDeletes objectAtIndex:currentItem.tag];
//            
//            currentItem.center = [recognizer locationInView:self];
//            currentButtonDelete.center = currentItem.frame.origin;
//        }
    }
    else if(recognizer.state == UIGestureRecognizerStateEnded)
    {
        //else do cleanup
    }    
}

#pragma mark private
-(CGPoint)getCenterAtIndex:(NSInteger)index
{
    int iRow = index / numberOfColumns;
    int iCol = index % numberOfColumns;
    
    // 中心点间距    space between icon center point
    CGFloat spaceCenter = (self.frame.size.width - self.contentInset.left - self.contentInset.right - total_width)/(self.numberOfColumns - 1);
    
    // 图标间距     space between icon
    CGFloat spaceBorder = spaceCenter - total_width;
    CGFloat centerX = total_width / 2 + spaceCenter*iCol;
    CGFloat centerY = total_height / 2 + (total_height + spaceBorder)*iRow;
    
    return CGPointMake(centerX, centerY);
}

#pragma mark public
-(void)reloadData
{
    // 移除所有的subview     remove all subviews
    for (BPBLaunchItemView* item in self.itemViews) {
        [item removeFromSuperview];
    }
    [self.itemViews removeAllObjects];
    
    for (UIButton* button in self.buttonDeletes) {
        [button removeFromSuperview];
    }
    [self.buttonDeletes removeAllObjects];
    
    
    
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
        // create itemView
        CGRect frame = CGRectZero;
        frame.size = CGSizeMake(total_width, total_height);
        BPBLaunchItemView* item = [[BPBLaunchItemView alloc]initWithFrame:frame];
        item.tag = iCnt;

        // 计算位置 caculate center point
        item.center = [self getCenterAtIndex:iCnt];
        
        // 设置删除按钮   set delete button
        // 添加删除按钮   add delete button
        UIButton* buttonDelete = [[UIButton alloc]initWithFrame:CGRectMake(0,0, cancel_button_width, cancel_button_height)];
        buttonDelete.center = item.frame.origin;
        buttonDelete.tag = iCnt;
        [buttonDelete setBackgroundColor:[UIColor blackColor]];
        buttonDelete.clipsToBounds = NO;
        
        buttonDelete.titleLabel.textAlignment = UITextAlignmentCenter;
        buttonDelete.titleLabel.font = cancel_button_font;
        [buttonDelete setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        buttonDelete.backgroundColor = [UIColor lightGrayColor];
        if(editMode)
        {
            buttonDelete.alpha = 1;
        }
        else
        {
            buttonDelete.alpha = 0;
        }
        [buttonDelete addTarget:self action:@selector(buttonDeleteClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        // 设置图标按钮   set icon button
        [item.buttonIcon addTarget:self action:@selector(buttonIconClicked:) forControlEvents:UIControlEventTouchUpInside];
        item.buttonIcon.layer.cornerRadius = self.iconCornerRadius;
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
        longPress.allowableMovement = YES;
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
        
        
        [self addSubview:item];
        [self addSubview:buttonDelete];
        
        [self.itemViews addObject:item];
        [self.buttonDeletes addObject:buttonDelete];
    }
}

#pragma mark touch


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    self.editMode = NO;
}

@end
