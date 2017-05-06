//
//  PTRequestTask.m
//  OAuthTest
//
//  Created by 彭平军 on 2017/5/4.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import "PTRequestTask.h"
#import "PTFileHandle.h"
#import "NSURL+PTLoader.h"
#import "NSString+PTLoader.h"
@interface PTRequestTask()<NSURLSessionDataDelegate>
@property (nonatomic, strong) NSURLSession * session; //会话对象
@property (nonatomic, strong) NSURLSessionDataTask * dataTask; //任务
@end
@implementation PTRequestTask

- (instancetype)init
{
    self = [super init];
    if (self) {
        [PTFileHandle createTempFile];
    }
    return self;
}

- (void)startTask {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self.requestURL originalSchemeURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    if (self.requestOffset > 0) {
        [request addValue:[NSString stringWithFormat:@"bytes=%ld-%ld", self.requestOffset, self.fileLength - 1] forHTTPHeaderField:@"Range"];
    }
    self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    self.dataTask = [self.session dataTaskWithRequest:request];
    [self.dataTask resume];
}

- (void)setIsCancel:(BOOL)isCancel {
    _isCancel = isCancel;
    [self.dataTask cancel];
    [self.session invalidateAndCancel];
}
#pragma mark - NSURLSessionDataDelegate
// 服务器响应
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(nonnull NSURLResponse *)response completionHandler:(nonnull void (^)(NSURLSessionResponseDisposition))completionHandler {
    if (self.isCancel) {
        return;
    }
    NSLog(@"response: %@", response);
    completionHandler(NSURLSessionResponseAllow);
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSString *contentRange = [[httpResponse allHeaderFields] objectForKey:@"Content-Range"];
    NSString *fileLength = [[contentRange componentsSeparatedByString:@"/"] lastObject];
    self.fileLength = fileLength.integerValue > 0 ? fileLength.integerValue : response.expectedContentLength;
    if (self.delegate && [self.delegate respondsToSelector:@selector(requestTaskDidReceiveResponse:)]) {
        [self.delegate requestTaskDidReceiveResponse:httpResponse];
    }
}
//服务器返回数据 可能会调用多次
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    if (self.isCancel) return;
    [PTFileHandle writeTempFileData:data];
    self.cacheLength += data.length;
    if (self.delegate && [self.delegate respondsToSelector:@selector(requestTaskDidUpdateCache)]) {
        [self.delegate requestTaskDidUpdateCache];
    }
}

//请求完成会调用该方法，请求失败则error有值
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (self.isCancel) {
        NSLog(@"下载取消");
    }else {
        if (error) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(requestTaskDidFailWithError:)]) {
                [self.delegate requestTaskDidFailWithError:error];
            }
        }else {
            //可以缓存则保存文件
            if (self.isCache) {
                [PTFileHandle cacheTempFileWithFileName:[NSString fileNameWithURL:self.requestURL]];
            }
            if (self.delegate && [self.delegate respondsToSelector:@selector(requestTaskDidFinishDownloadWithCache:)]) {
                [self.delegate requestTaskDidFinishDownloadWithCache:self.isCache];
            }
        }
    }
}
@end
