//
//  BPBTool.h
//  bpblaunch
//
//  Created by BigPolarBear on 7/27/12.
//  Copyright (c) 2012 BigPolarBear. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BPBTool : NSObject

/** loading remote image url */
+(void)loadRemoteImage:(NSString*)urlStr
            usingCache:(BOOL)usingCache
            completion:(void(^)(BOOL success,UIImage* image,NSError* error))completionHander;

@end
