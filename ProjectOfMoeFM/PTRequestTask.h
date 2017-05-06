//
//  PTRequestTask.h
//  OAuthTest
//
//  Created by 彭平军 on 2017/5/4.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PTRequestTask;

@protocol PTRequestTaskDelegate <NSObject>

- (void)requestTaskDidUpdateCache; // 更新缓冲进度
- (void)requestTaskDidReceiveResponse:(NSHTTPURLResponse *)response;// 收到服务器响应
- (void)requestTaskDidFinishDownloadWithCache:(BOOL)isCache;// 完成缓冲后是否缓存文件
- (void)requestTaskDidFailWithError:(NSError *)error;// 缓冲失败的错误

@end
@interface PTRequestTask : NSObject

@property (weak, nonatomic) id <PTRequestTaskDelegate> delegate;
@property (strong, nonatomic) NSURL *requestURL;
@property (nonatomic, assign) NSUInteger requestOffset; //请求起始位置
@property (nonatomic, assign) NSUInteger fileLength; //文件长度
@property (nonatomic, assign) NSUInteger cacheLength; //缓冲长度
@property (nonatomic, assign) BOOL isCache; //是否缓存文件
@property (nonatomic, assign) BOOL isCancel; //是否取消请求

- (void)startTask;

@end
