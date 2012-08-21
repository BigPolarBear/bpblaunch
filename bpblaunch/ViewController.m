//
//  ViewController.m
//  bpblaunch
//
//  Created by BigPolarBear on 7/27/12.
//  Copyright (c) 2012 BigPolarBear. All rights reserved.
//

#import "ViewController.h"
#import "BPBTool.h"

@interface ViewController ()

@property (nonatomic,strong) BPBLaunchScrollView* launchScrollView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // 添加一个BPBLaunchScrollView add a BPBLaunchScrollView
    self.launchScrollView = [[BPBLaunchScrollView alloc]initWithFrame:self.view.frame];
    // 设置默认的icon图片  set default icon image
    self.launchScrollView.defaultIconImage = [UIImage imageNamed:@"gravatar"];
    self.launchScrollView.imageOfDeleteButton = [UIImage imageNamed:@"gravatar"];
    self.launchScrollView.contentInset = UIEdgeInsetsMake(12, 12, 16, 16);
    self.launchScrollView.iconCornerRadius = 8;
    self.launchScrollView.nameColor = [UIColor blackColor];
    
    // 设置一行最多放置多少个icon  set max icon number in a row
    self.launchScrollView.numberOfColumns = 4;
    
    // 设置datasource和delegate    set datasource and delegate must be put in the end
    self.launchScrollView.dataSource = self;
    self.launchScrollView.delegate = self;
    
    self.launchScrollView.bounces = YES;
    self.launchScrollView.alwaysBounceVertical = YES;
    
    NSString* text = @"abceefghijklmnopqrstuvwxyz";
    UIFont* font = [UIFont boldSystemFontOfSize:20];
    font = [UIFont systemFontOfSize:20];
    
    CGFloat lineHeight = [BPBTool textHeight:text width:160 font:font];
    NSInteger lineNumber = [BPBTool textLineNumbers:text width:160 font:font];
    CGFloat textWidth = [BPBTool textSize:text font:font].width;
    NSLog(@"\nlineHeight:%f\n"
          "lineNumber:%d\n"
          "textWidth:%f"
          ,lineHeight
          ,lineNumber
          ,textWidth);
    
    [self.view addSubview:self.launchScrollView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark BPBLaunchScrollViewDataSource

-(BOOL)canDeleteItemInEditModeAtIndex:(NSInteger)index
{
    return index%2 == 0;
}

// 移动元素位置       move item
-(void)moveItemFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex
{
    NSLog(@"moveItemFromIndex:toIndex:");
}

// 有多少元素要显示    How many items need
-(NSInteger)numberOfItemsInBPBLaunchController:(BPBLaunchScrollView*)launchController
{
    return 10;
}


// 要显示的图标url    The image url at index
-(NSString*)imageUrlAtIndex:(NSInteger)index
{
    return @"http://a1.mzstatic.com/us/r1000/116/Purple/v4/87/60/7c/87607c4c-b38f-0b4e-ecc3-f3655b9855b9/mzl.szkfctue.175x175-75.jpg";
}
// 要显示的名称       The title at index
-(NSString*)titleAtIndex:(NSInteger)index
{
    return [NSString stringWithFormat:@"title:%d",index];
}

#pragma mark BPBLaunchScrollViewDelegate
// 点击图标     icon clicked
-(void)BPBLaunchController:(BPBLaunchScrollView*)launchController didClicked:(NSInteger)index
{
    [[[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"button %d clicked",index] delegate:nil cancelButtonTitle:@"Confirm" otherButtonTitles:nil, nil] show];
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)sv
{
    NSLog(@"scrollViewDidScroll:(%f,%f)",sv.contentOffset.x,sv.contentOffset.y);
}

@end
