//
//  BPBLaunchControllerViewController.h
//  lovesearch
//
//  Created by 韩 鑫 on 7/9/12.
//
//

#import <UIKit/UIKit.h>

@class BPBLaunchScrollView;


@protocol BPBLaunchScrollViewDataSource <NSObject,UIScrollViewDelegate>

// 有多少元素要显示
-(NSInteger)numberOfUserInfoInBPBLaunchController:(BPBLaunchScrollView*)launchController;
// 要显示的图标url
-(NSString*)imageUrlAtIndex:(NSInteger)index;
// 要显示的名称
-(NSString*)titleAtIndex:(NSInteger)index;

@end

@protocol BPBLaunchScrollViewDelegate <NSObject>

// 列表开始滚动
-(void)BPBLaunchControllerWillBeginDragging:(BPBLaunchScrollView *)launchController;
// 点击图标
-(void)BPBLaunchController:(BPBLaunchScrollView*)launchController didClicked:(NSInteger)index;

@end



@interface BPBLaunchScrollView : UIScrollView<UIScrollViewDelegate>

@property (weak,nonatomic) id<BPBLaunchScrollViewDelegate>    launchDelegate;
@property (weak,nonatomic) id<BPBLaunchScrollViewDataSource>  launchDataSource;

@property (assign,nonatomic) NSInteger numberOfColumns;
@property (strong,nonatomic) UIImage* defaultIconImage;

-(void)setBorderTop:(float)top bottom:(float)bottom left:(float)left right:(float)right;
// 重新加载数据
-(void)reloadData;


@end
