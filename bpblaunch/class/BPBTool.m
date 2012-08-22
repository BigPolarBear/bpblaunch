//
//  BPBTool.m
//  bpblaunch
//
//  Created by BigPolarBear on 7/27/12.
//  Copyright (c) 2012 BigPolarBear. All rights reserved.
//

#import "BPBTool.h"

@implementation BPBTool

+(UIImage*)loadBundleImageWhenImageUrl:(NSString*)imageUrl withPrefix:(NSArray*)arrayPrefix
{
    for (NSString* pre in arrayPrefix) {
        if([imageUrl rangeOfString:pre].location == 0)
        {
            NSString* imageName = [imageUrl stringByReplacingOccurrencesOfString:pre withString:@""];
            NSArray* array = [imageName componentsSeparatedByString:@"."];
            if(array.count != 2)
            {
                continue;
            }
            
            if([[NSBundle mainBundle] pathForResource:[array objectAtIndex:0] ofType:[array objectAtIndex:1]])
            {
                // 图片已打包在bundle里
                return [UIImage imageNamed:imageName];
            }
        }
    }
    
    return nil;
}

+(UIImage*)loadCacheImage:(NSString*)urlStr
{
    NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSAllDomainsMask, YES) objectAtIndex:0];
    filePath = [filePath stringByAppendingFormat:@"/%@",[urlStr lastPathComponent]];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    UIImage* imageCached = nil;
    if ([fileManager fileExistsAtPath:filePath])
    {
        // 使用缓存的图片  using cached image
        imageCached = [UIImage imageWithContentsOfFile:filePath];
        return imageCached;
    }
    else
    {
        return nil;
    }
}

+(void)loadRemoteImage:(NSString*)urlStr
           usingBundle:(BOOL)usingBundle
   prefixArrayOfBundle:(NSArray*)arrayPrefix
            usingCache:(BOOL)usingCache
            completion:(void(^)(BOOL success,UIImage* image,NSError* error))completionHander
{
    NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSAllDomainsMask, YES) objectAtIndex:0];
    filePath = [filePath stringByAppendingFormat:@"/%@",[urlStr lastPathComponent]];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    UIImage* imageBundle = nil;
    if(usingBundle && arrayPrefix.count > 0)
    {
        imageBundle = [self loadBundleImageWhenImageUrl:urlStr withPrefix:arrayPrefix];
    }
    
    UIImage* imageCached = nil;
    if (usingCache && [fileManager fileExistsAtPath:filePath])
    {
        // 使用缓存的图片  using cached image
        imageCached = [UIImage imageWithContentsOfFile:filePath];
    }
        
    if(imageCached)
    {
        // 缓存图片可用   cached image loaded successfully
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(){
            dispatch_sync(dispatch_get_main_queue(), ^(){
                completionHander(YES,imageCached,nil);
                return;
            });
        });
    }
    else
    {
        // 异步加载图片 asyn load image by url
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(){

            NSError* error = nil;            
            NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr] options:NSDataReadingMappedIfSafe error:&error];
            
            if (error != nil)
            {
                // 加载图片失败   load image by url failed
                NSLog(@"download image file failed: %@", [error localizedDescription]);
                dispatch_sync(dispatch_get_main_queue(), ^(){
                        completionHander(NO,nil,error);                  
                });
            } else
            {
                if ([data writeToFile:filePath options:NSDataWritingAtomic error:&error])
                {
//                    NSLog(@"write cahce file success");
                }
                else
                {
                    NSLog(@"write cache file failed:%@", [error localizedDescription]);
                }
                                
                dispatch_sync(dispatch_get_main_queue(), ^(){
                    UIImage* image = [UIImage imageWithData:data];
                    if(image)
                    {
                        completionHander(YES,image,nil);
                    }
                    else
                    {
                        completionHander(NO,nil,nil);
                    }
                });
            }            
        });
    }
}

/** 截取当前view */
+(UIImage*)imageFromView:(UIView *)fromView
{
    UIGraphicsBeginImageContext(fromView.bounds.size);
    [fromView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark 文本相关   Text Related
+(CGSize)textSize:(NSString*)text font:(UIFont*)font
{
    CGSize containSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
    CGSize strSize = [text sizeWithFont:font constrainedToSize:containSize
                          lineBreakMode:UILineBreakModeCharacterWrap];
    return strSize;
}

+(CGFloat)textHeight:(NSString*)text width:(CGFloat)width font:(UIFont*)font
{
    CGSize containSize = CGSizeMake(width, CGFLOAT_MAX);
    CGSize strSize = [text sizeWithFont:font constrainedToSize:containSize
                          lineBreakMode:UILineBreakModeCharacterWrap];
    return strSize.height;
}

+(NSInteger)textLineNumbers:(NSString*)text width:(float)width font:(UIFont*)font
{
    CGSize containSize = CGSizeMake(width, CGFLOAT_MAX);
    containSize.width = width;
    CGSize textSize = [text sizeWithFont:font constrainedToSize:containSize lineBreakMode:UILineBreakModeWordWrap];
    CGFloat lineHeight = [BPBTool textSize:text font:font].height;
    
    NSInteger lineNumber = textSize.height / lineHeight;
    if(lineNumber * lineHeight < textSize.height)
    {
        lineNumber++;
    }
    return textSize.height / lineHeight;
}

@end
