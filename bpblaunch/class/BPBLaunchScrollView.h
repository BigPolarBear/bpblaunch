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
-(NSInteger)numberOfUserInfoInBPBLaunchController:(BPBLaunchScrollView*)launchController;
// 要显示的图标url    The image url at index
-(NSString*)imageUrlAtIndex:(NSInteger)index;
// 要显示的名称       The title at index
-(NSString*)titleAtIndex:(NSInteger)index;

@end

@protocol BPBLaunchScrollViewDelegate <NSObject,UIScrollViewDelegate>

// 点击图标
-(void)BPBLaunchController:(BPBLaunchScrollView*)launchController didClicked:(NSInteger)index;

@end



@interface BPBLaunchScrollView : UIScrollView

@property (weak,nonatomic) id<BPBLaunchScrollViewDelegate>    delegate;
@property (weak,nonatomic) id<BPBLaunchScrollViewDataSource>  dataSource;

@property (assign,nonatomic) NSInteger numberOfColumns;
@property (strong,nonatomic) UIImage* defaultIconImage;

-(void)setBorderTop:(float)top bottom:(float)bottom left:(float)left right:(float)right;
// 重新加载数据
-(void)reloadData;


@end
