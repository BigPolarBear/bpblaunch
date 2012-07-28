//
//  ViewController.m
//  bpblaunch
//
//  Created by BigPolarBear on 7/27/12.
//  Copyright (c) 2012 BigPolarBear. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic,strong) BPBLaunchScrollView* launchScrollView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // add a BPBLaunchScrollView
    self.launchScrollView = [[BPBLaunchScrollView alloc]initWithFrame:self.view.frame];
    // set default image
    self.launchScrollView.defaultIconImage = [UIImage imageNamed:@"gravatar"];
    self.launchScrollView.contentInset = UIEdgeInsetsMake(12, 12, 16, 16);
    
    // set max icon number in a row
    self.launchScrollView.numberOfColumns = 4;
    
    // set datasource and delegate must be put in the end
    self.launchScrollView.dataSource = self;
    self.launchScrollView.delegate = self;
    
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
// 有多少元素要显示
-(NSInteger)numberOfUserInfoInBPBLaunchController:(BPBLaunchScrollView*)launchController
{
    return 100;
}


// 要显示的图标url
-(NSString*)imageUrlAtIndex:(NSInteger)index
{
    return @"http://a1.mzstatic.com/us/r1000/116/Purple/v4/87/60/7c/87607c4c-b38f-0b4e-ecc3-f3655b9855b9/mzl.szkfctue.175x175-75.jpg";
}
// 要显示的名称
-(NSString*)titleAtIndex:(NSInteger)index
{
    return [NSString stringWithFormat:@"title:%d",index];
}

#pragma mark BPBLaunchScrollViewDelegate
// 列表开始滚动
-(void)BPBLaunchControllerWillBeginDragging:(BPBLaunchScrollView *)launchController
{
    NSLog(@"BPBLaunchControllerWillBeginDragging");
}
// 点击图标
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
