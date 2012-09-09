//
//  BPBTool.m
//  bpblaunch
//
//  Created by BigPolarBear on 7/27/12.
//  Copyright (c) 2012 BigPolarBear. All rights reserved.
//

#import "BPBTool.h"

@interface BPBTool()
{
}

@end

static NSArray* s_arrayPrefix;

@implementation BPBTool

/** 设置哪些图片url的前缀优先使用本地bundle里的图片资源 set when imageUrl has given urlPrefix then load bundle image with the same name without prefix */
+(void)setImageUrlPrefixesUsingBundle:(NSArray*)arrayPrefix
{
    s_arrayPrefix = arrayPrefix;
}
+(NSArray*)imageUrlPrefixesUsingBundle
{
    return s_arrayPrefix;
}

+(UIImage*)loadBundleImage:(NSString*)imageUrl
{
    // imageUrl is a file name
    NSRange range = [imageUrl rangeOfString:@"."];
    if(range.location != NSNotFound && range.location < imageUrl.length)
    {
        NSString* fileName = [imageUrl substringToIndex:range.location];
        NSString* extensionName = [imageUrl substringFromIndex:range.location+1];
        NSString* imagePath = [[NSBundle mainBundle] pathForResource:fileName ofType:extensionName];
        if(imagePath != nil)
        {
            // imageUrl is a file name and exist in bundle
            return [UIImage imageNamed:imageUrl];
        }
    }
    
    for (NSString* pre in [self imageUrlPrefixesUsingBundle]) {
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

+(UIImage*)loadLocalImage:(NSString*)urlStr
{
    UIImage* img = [self loadBundleImage:urlStr];
    if(!img)
    {
        img = [self loadCacheImage:urlStr];
    }
    
    return img;
}

+(void)loadRemoteImage:(NSString*)urlStr
           usingBundle:(BOOL)usingBundle
            usingCache:(BOOL)usingCache
            completion:(void(^)(BOOL success,UIImage* image,NSError* error))completionHander
{
    NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSAllDomainsMask, YES) objectAtIndex:0];
    filePath = [filePath stringByAppendingFormat:@"/%@",[urlStr lastPathComponent]];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    UIImage* imageLocal = nil;
    if(usingBundle && [self imageUrlPrefixesUsingBundle].count > 0)
    {
        imageLocal = [self loadBundleImage:urlStr];
    }
    
    if (usingCache && [fileManager fileExistsAtPath:filePath])
    {
        // 使用缓存的图片  using cached image
        imageLocal = [UIImage imageWithContentsOfFile:filePath];
    }
        
    if(imageLocal)
    {
        // 缓存图片可用   cached image loaded successfully
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(){
            dispatch_sync(dispatch_get_main_queue(), ^(){
                completionHander(YES,imageLocal,nil);
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

+(UIImage *)image:(UIImage *)image toScale:(float)scale
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width*scale,image.size.height*scale));
    [image drawInRect:CGRectMake(0, 0,image.size.width * scale, image.size.height *scale)];
    UIImage *scaledImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}
+ (UIImage *)image:(UIImage *)image toSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
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

/** 判断字符串形式的版本号大小，例如：1.2.1 vs 1.1.2 */
+(BOOL)version:(NSString*)v1 isGreaterThanVersion:(NSString*)v2
{
    NSNumberFormatter* nf = [[NSNumberFormatter alloc] init];
    
    NSCharacterSet* separatorSet = [NSCharacterSet characterSetWithCharactersInString:@".,"];
    
    NSArray* array2 = [v2 componentsSeparatedByCharactersInSet:separatorSet];
    NSArray* array1 = [v1 componentsSeparatedByCharactersInSet:separatorSet];
    
    
    for(int iCnt = 0; iCnt < array1.count; iCnt++)
    {
        BOOL isGreater = NO;

        if(iCnt >= array2.count)
        {
            return YES;
        }
        
        NSString* str1 = [array1 objectAtIndex:iCnt];
        NSString* str2 = [array2 objectAtIndex:iCnt];
        NSNumber* val1 = [nf numberFromString:str1];
        NSNumber* val2 = [nf numberFromString:str2];
        if(val1 != nil && val2 != nil)
        {
            isGreater = ([val1 compare:val2] == NSOrderedDescending);
        }
        else
        {
            isGreater = (str1 > str2);
        }
                
        
        if(isGreater)
        {
            return YES;
        }
    }
    
    return NO;
}

@end
