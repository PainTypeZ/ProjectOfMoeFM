//
//  PTRequestTask.h
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/9/5.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PTFileHandle.h"

@class PTRequestTask;
@protocol PTRequestTaskDelegate <NSObject>

@required
- (void)requestTaskDidUpdateCache; // 更新缓冲进度

@optional
- (void)requestTaskDidReceiveResponse;
- (void)requestTaskDidFinishLoadingWithCache:(BOOL)cache;
- (void)requestTaskDidFailWithError:(NSError *)error;
- (void)requestTask404ByMoeFM;

@end

@interface PTRequestTask : NSObject

@property (weak, nonatomic) id<PTRequestTaskDelegate> delegate;
@property (strong, nonatomic) NSURL *requestURL; // 请求地址
@property (assign, nonatomic) NSUInteger requestOffset; // 请求起始位置
@property (assign, nonatomic) NSUInteger fileLength; // 文件长度
@property (assign, nonatomic) NSUInteger cacheLength; // 缓冲长度
@property (assign, nonatomic) BOOL isCache; // 是否缓存文件
@property (assign, nonatomic) BOOL isCancel; // 是否取消请求

// 开始请求
- (void)start;

@end
