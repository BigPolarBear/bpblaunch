//
//  BPBLaunchItemView.m
//  bpblaunch
//
//  Created by BigPolarBear on 8/15/12.
//  Copyright (c) 2012 BigPolarBear. All rights reserved.
//

#import "BPBLaunchItemView.h"
#import <QuartzCore/QuartzCore.h>




@implementation BPBLaunchItemView

@synthesize buttonIcon,labelName;

-(void)setTag:(NSInteger)tag
{
    // all subview with the same tag value
    self.buttonIcon.tag = tag;
    self.labelName.tag = tag;
    
    [super setTag:tag];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
            // 承载的背景标签 label that will contain icon and title
        self.frame = frame;

        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        self.clipsToBounds = NO;
        
            
        // 添加图标按钮 add icon button
        self.buttonIcon = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, icon_width, icon_height)];
        buttonIcon.clipsToBounds = YES;
        
        buttonIcon.layer.shadowColor = [UIColor blackColor].CGColor;
        buttonIcon.layer.shadowOffset = CGSizeMake(0.0, 1.0);
        buttonIcon.layer.shadowOpacity = 1;
        buttonIcon.layer.masksToBounds = NO;


        // 增加文字     add title
        self.labelName = [[UILabel alloc]initWithFrame:CGRectMake(0, icon_height + between_title_icon, title_width, title_height)];
        self.labelName.font = title_font;
        self.labelName.textAlignment = UITextAlignmentCenter;
        self.labelName.textColor = [UIColor whiteColor];
        self.labelName.shadowColor = [UIColor darkGrayColor];
        self.labelName.shadowOffset = CGSizeMake(0, 1);
        self.labelName.backgroundColor = [UIColor clearColor];
        
        
        self.buttonIcon.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        self.labelName.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.buttonIcon];
        [self addSubview:self.labelName];
    }
    return self;
}

@end
