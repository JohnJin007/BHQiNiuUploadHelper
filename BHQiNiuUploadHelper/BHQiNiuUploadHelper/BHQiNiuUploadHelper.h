//
//  BHQiNiuUploadHelper.h
//  BHQiNiuUploadHelper
//
//  Created by libohao on 17/2/15.
//  Copyright © 2017年 libohao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QiniuSDK.h"

@interface BHQiNiuUploadHelper : NSObject

+ (void)uploadData:(NSData*)data WithToken:(NSString*)token progress:(QNUpProgressHandler)progress success:(void (^)(NSDictionary *responseDic))success failure:(void (^)())failure;

+ (void)uploadDatas:(NSArray* )datas TokenArray:(NSArray *)tokenArray progress:(void (^)(float))progress success:(void (^)(NSArray *))success failure:(void (^)())failure;

@end
