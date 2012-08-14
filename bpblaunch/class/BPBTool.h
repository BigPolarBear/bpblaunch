//
//  BPBTool.h
//  bpblaunch
//
//  Created by BigPolarBear on 7/27/12.
//  Copyright (c) 2012 BigPolarBear. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BPBTool : NSObject

/** 如果图片的url以给定的地址前缀开头，则尝试加载bundle里去除前缀的同名图片 when imageUrl has given urlPrefix then load bundle image with the same name without prefix */
+(UIImage*)loadBundleImageWhenImageUrl:(NSString*)imageUrl withPrefix:(NSArray*)arrayPrefix;


/** 加载缓存的url地址对应的图片  loading cached image url */
+(UIImage*)loadCacheImage:(NSString*)urlStr;

/** 异步加载url地址对应的图片  loading remote image url */
+(void)loadRemoteImage:(NSString*)urlStr
            usingCache:(BOOL)usingCache
            completion:(void(^)(BOOL success,UIImage* image,NSError* error))completionHander;

@end
