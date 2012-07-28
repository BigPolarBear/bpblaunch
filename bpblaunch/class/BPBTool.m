//
//  BPBTool.m
//  bpblaunch
//
//  Created by BigPolarBear on 7/27/12.
//  Copyright (c) 2012 BigPolarBear. All rights reserved.
//

#import "BPBTool.h"

@implementation BPBTool

+(void)loadRemoteImage:(NSString*)urlStr
            usingCache:(BOOL)usingCache
            completion:(void(^)(BOOL success,UIImage* image,NSError* error))completionHander
{
    NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSAllDomainsMask, YES) objectAtIndex:0];
    filePath = [filePath stringByAppendingFormat:@"/%@",[urlStr lastPathComponent]];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
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

@end
