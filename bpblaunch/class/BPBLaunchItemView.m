//
//  BPBLaunchItemView.m
//  bpblaunch
//
//  Created by BigPolarBear on 8/15/12.
//  Copyright (c) 2012 BigPolarBear. All rights reserved.
//

#import "BPBLaunchItemView.h"




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
            
        // 增加文字     add title
        self.labelName = [[UILabel alloc]initWithFrame:CGRectMake(0, icon_height + between_title_icon, title_width, title_height)];
        self.labelName.font = title_font;
        self.labelName.textAlignment = UITextAlignmentCenter;
        self.labelName.textColor = [UIColor whiteColor];
        self.labelName.shadowColor = [UIColor darkGrayColor];
        self.labelName.shadowOffset = CGSizeMake(0, 1);
        self.labelName.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.buttonIcon];
        [self addSubview:self.labelName];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end