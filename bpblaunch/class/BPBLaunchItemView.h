//
//  BPBLaunchItemView.h
//  bpblaunch
//
//  Created by BigPolarBear on 8/15/12.
//  Copyright (c) 2012 BigPolarBear. All rights reserved.
//

#import <UIKit/UIKit.h>

#define cancel_button_width     20
#define cancel_button_height    20
#define cancel_button_font      [UIFont boldSystemFontOfSize:20]
#define cancel_button_show_animation_duration   0.3

#define item_delete_animation_duration 0.3

#define icon_width     57
#define icon_height     57
#define title_width     57
#define title_height    17
#define title_font      [UIFont boldSystemFontOfSize:12]
#define between_title_icon  4

#define total_width     icon_width
#define total_height    (icon_height + title_height + between_title_icon)

@interface BPBLaunchItemView : UIView

@property (nonatomic,retain) UIButton* buttonIcon;
@property (nonatomic,retain) UILabel* labelName;

@end
