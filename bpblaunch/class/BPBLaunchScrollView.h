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

// 点击图标     iCon Clicked
-(void)BPBLaunchController:(BPBLaunchScrollView*)launchController didClicked:(NSInteger)index;

@end


@interface BPBLaunchScrollView : UIScrollView

@property (weak,nonatomic) id<BPBLaunchScrollViewDataSource>  dataSource;


@property (assign,nonatomic) NSInteger numberOfColumns;
@property (strong,nonatomic) UIImage* defaultIconImage;
// 图片地址含给定的前缀的，则尝试去除前缀，加载在bundle内同名文件
// when imageUrl has given urlPrefix in array then should try load bundle image with the same name without prefix
@property (strong,nonatomic) NSArray* imageUrlPrefixArray;

// 重新加载数据 reloadData
-(void)reloadData;


@end
