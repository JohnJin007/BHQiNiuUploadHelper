//
//  BHQiNiuUploadHelper.m
//  BHQiNiuUploadHelper
//
//  Created by libohao on 17/2/15.
//  Copyright © 2017年 libohao. All rights reserved.
//

#import "BHQiNiuUploadHelper.h"

@interface TDQiNiuUploadHelper : NSObject

@property (copy, nonatomic) void (^singleSuccessBlock)(NSDictionary *);
@property (copy, nonatomic)  void (^singleFailureBlock)();

+ (instancetype)sharedInstance;
@end

@implementation TDQiNiuUploadHelper

+ (instancetype)sharedInstance
{
    static TDQiNiuUploadHelper *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[TDQiNiuUploadHelper alloc] init];
    });
    return _sharedInstance;
}

@end

@implementation BHQiNiuUploadHelper

+ (void)uploadDatas:(NSArray* )datas TokenArray:(NSArray *)tokenArray progress:(void (^)(float))progress success:(void (^)(NSArray *))success failure:(void (^)())failure {
    
    if (!datas.count || !tokenArray.count) {
        failure();
        return;
    }
    
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    __block float totalProgress = 0.0f;
    __block float partProgress = 1.0f / [datas count];
    
    __block NSUInteger currentIndex = 0;
    
    
    TDQiNiuUploadHelper *uploadHelper = [TDQiNiuUploadHelper sharedInstance];
    __weak typeof(uploadHelper) weakHelper = uploadHelper;
    
    uploadHelper.singleFailureBlock = ^() {
        failure();
        return;
    };
    uploadHelper.singleSuccessBlock  = ^(NSDictionary *imgDic) {
        [array addObject:imgDic];
        
        currentIndex++;
        
        //加入随机数，让等分进度不相等
        float random;
        int x = 2 + arc4random() % 9;
        random =  (x / 100.0);
        
        if ([array count] == [datas count]) {
            success([array copy]);
            return;
        }
        else {
            [BHQiNiuUploadHelper uploadData:datas[currentIndex] WithToken:tokenArray[currentIndex] progress:^(NSString *key, float percent) {
                totalProgress = currentIndex*partProgress + percent*partProgress;
                
                totalProgress += random;
                
                if(totalProgress > 1.0) {
                    totalProgress = 1.0;
                }
                
                //NSLog(@"%f",totalProgress);
                if (progress) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        progress(totalProgress);
                    });
                }
            } success:weakHelper.singleSuccessBlock failure:weakHelper.singleFailureBlock];
        }
    };
    
    [BHQiNiuUploadHelper uploadData:datas[0] WithToken:tokenArray[0] progress:^(NSString *key, float percent) {
        totalProgress = currentIndex*partProgress + percent*partProgress;
        if (progress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                progress(totalProgress);
            });
        }
    } success:weakHelper.singleSuccessBlock failure:weakHelper.singleFailureBlock];

}


+ (void)uploadData:(NSData*)data WithToken:(NSString*)token progress:(QNUpProgressHandler)progress success:(void (^)(NSDictionary *responseDic))success failure:(void (^)())failure {
    
    QNUploadOption *opt = [[QNUploadOption alloc] initWithMime:nil progressHandler:progress params:nil checkCrc:NO cancellationSignal:nil];
    QNUploadManager *uploadManager = [[QNUploadManager alloc]init];
    
    [uploadManager putData:data key:nil token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        if (info.statusCode == 200 && resp) {
            if (success) {
                success(resp);
            }
        }
        else {
            if (failure) {
                failure();
            }
        }
    } option:opt];
    
}

@end
