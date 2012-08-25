//
//  BPBTool.h
//  bpblaunch
//
//  Created by BigPolarBear on 7/27/12.
//  Copyright (c) 2012 BigPolarBear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface BPBTool : NSObject

#pragma mark 颜色相关
// 十六进制设置颜色
#define Color_HEX(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define Color_RGB(r,g,b,a) [UIColor colorWithRed:(float)r green:(float)g blue:(float)b alpha:a]
#define Color_RGB255(r,g,b,a) [UIColor colorWithRed:(float)r/255 green:(float)g/255 blue:(float)b/255 alpha:a]

#pragma mark 图片加载相关 Image Loading Related
/** 如果图片的url以给定的地址前缀开头，则尝试加载bundle里去除前缀的同名图片 when imageUrl has given urlPrefix then load bundle image with the same name without prefix */
+(UIImage*)loadBundleImageWhenImageUrl:(NSString*)imageUrl withPrefix:(NSArray*)arrayPrefix;

/** 加载缓存的url地址对应的图片  loading cached image url */
+(UIImage*)loadCacheImage:(NSString*)urlStr;

/** 异步加载url地址对应的图片  loading remote image url */
+(void)loadRemoteImage:(NSString*)urlStr
           usingBundle:(BOOL)usingBundle
   prefixArrayOfBundle:(NSArray*)arrayPrefix
            usingCache:(BOOL)usingCache
            completion:(void(^)(BOOL success,UIImage* image,NSError* error))completionHander;

/** 截取当前view作为UIImage */
+(UIImage*)imageFromView:(UIView *)fromView;
/** 缩放 */
+(UIImage *)image:(UIImage *)image toScale:(float)scale;
+(UIImage *)image:(UIImage *)image toSize:(CGSize)newSize;


#pragma mark 文本相关   Text Related
+(CGSize)textSize:(NSString*)text font:(UIFont*)font;
+(CGFloat)textHeight:(NSString*)text width:(CGFloat)width font:(UIFont*)font;
+(NSInteger)textLineNumbers:(NSString*)text width:(float)width font:(UIFont*)font;

@end
