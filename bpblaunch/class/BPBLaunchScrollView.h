//
//  BPBLaunchControllerViewController.h
//  bpblaunch
//
//  Created by BigPolarBear on 7/9/12.
//
//

#import <UIKit/UIKit.h>

@class BPBLaunchScrollView;


@protocol BPBLaunchScrollViewDataSource <NSObject>

// 有多少元素要显示    How many items need
-(NSInteger)numberOfItemsInBPBLaunchController:(BPBLaunchScrollView*)launchController;
// 要显示的图标url    The image url at index
-(NSString*)imageUrlAtIndex:(NSInteger)index;
// 要显示的名称       The title at index
-(NSString*)titleAtIndex:(NSInteger)index;

@optional
// 允许在编辑模式下删除，不实现则默认为YES
// the item at index allowed be deleted while in edit mode, if not implemented then default value is YES
-(BOOL)canDeleteItemInEditModeAtIndex:(NSInteger)index;
// 删除此位置的元素    Delete the item at index
-(void)deleteItemAtIndex:(NSInteger)index;
// 移动元素位置       move item
-(void)moveItemFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;

@end

@protocol BPBLaunchScrollViewDelegate <NSObject,UIScrollViewDelegate>

// 点击图标     icon Clicked
-(void)BPBLaunchController:(BPBLaunchScrollView*)launchController didClicked:(NSInteger)index;


@end


@interface BPBLaunchScrollView : UIScrollView

@property (weak,nonatomic) id<BPBLaunchScrollViewDataSource>  dataSource;


@property (assign,nonatomic) NSInteger numberOfColumns;
@property (strong,nonatomic) UIImage* defaultIconImage;
@property (strong,nonatomic) UIImage* imageOfDeleteButton;
@property (strong,nonatomic) UIColor* nameColor;
@property (strong,nonatomic) UIColor* nameShadowColor;
@property (strong,nonatomic) UIColor* iconShadowColor;


// 重新加载数据 reloadData
-(void)reloadData;

#pragma mark 可选的    optional

// 编辑模式（默认为NO）     edit mode, default is NO
@property (assign,nonatomic) BOOL editMode;
// 允许进入编辑模式（默认为长按图标）    allow entering edit mode while long pressed icon
@property (assign,nonatomic) BOOL allowEnableEditMode;

// 设置图标的圆角 set icon‘s corner radius
@property (assign,nonatomic) CGFloat iconCornerRadius;





@end
