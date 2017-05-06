//
//  PTResourceLoader.m
//  OAuthTest
//
//  Created by 彭平军 on 2017/5/4.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import "PTResourceLoader.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "PTFileHandle.h"
@interface PTResourceLoader()

@property (strong, nonatomic) NSMutableArray *requestList;
@property (strong, nonatomic) PTRequestTask *requestTask;

@end

@implementation PTResourceLoader

static NSString *mimeType;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.requestList = [NSMutableArray array];
    }
    return self;
}

- (void)stopLoading {
    self.requestTask.isCancel = YES;
}

- (void)addLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    [self.requestList addObject:loadingRequest];
    @synchronized (self) {
        if (self.requestTask) {
            if (loadingRequest.dataRequest.requestedOffset >= self.requestTask.requestOffset && loadingRequest.dataRequest.requestedOffset <= self.requestTask.requestOffset + self.requestTask.cacheLength) {
                // 数据已经缓存，继续请求
                NSLog(@"需要的数据已经缓存，直接返回已完成");
                [self processRequestList];
            } else {
                //数据还没缓存，则等待数据下载；如果是Seek操作，则重新请求
                if (self.isSeek) {
                    NSLog(@"seek操作,重新请求");
                    [self newTaskWithLoadingRequest:loadingRequest isCache:NO];
                }
            }
        }else{
            [self newTaskWithLoadingRequest:loadingRequest isCache:YES];
        }
    }
}

- (void)newTaskWithLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest isCache:(BOOL)isCache {
    NSUInteger fileLength = 0;
    if (self.requestTask) {
        fileLength = self.requestTask.fileLength;
        self.requestTask.isCancel = YES;
    }
    self.requestTask = [[PTRequestTask alloc] init];
    self.requestTask.requestURL = loadingRequest.request.URL;
    self.requestTask.requestOffset = loadingRequest.dataRequest.requestedOffset;
    self.requestTask.isCache = isCache;
    if (fileLength > 0) {
        self.requestTask.fileLength = fileLength;
    }
    self.requestTask.delegate = self;
    [self.requestTask startTask];
    self.isSeek = NO;
}

- (void)removeLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    [self.requestList removeObject:loadingRequest];
}

- (void)processRequestList {
    NSMutableArray *finishRequestList = [NSMutableArray array];
    for (AVAssetResourceLoadingRequest *loadingRequest in self.requestList) {
        if ([self finishLoadingWithLoadingRequest:loadingRequest]) {
            [finishRequestList addObject:loadingRequest];
        }
    }
    [self.requestList removeObjectsInArray:finishRequestList];
}

- (BOOL)finishLoadingWithLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    // 填充信息
    CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)(mimeType), NULL);
    loadingRequest.contentInformationRequest.contentType = CFBridgingRelease(contentType);
    loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
    loadingRequest.contentInformationRequest.contentLength = self.requestTask.fileLength;
    // 读文件，填充数据
    NSUInteger cacheLength = self.requestTask.cacheLength;
    NSUInteger requestedOffset = loadingRequest.dataRequest.requestedOffset;
    if (loadingRequest.dataRequest.currentOffset != 0) {
        requestedOffset = loadingRequest.dataRequest.currentOffset;
    }
    NSUInteger readableLength = cacheLength - (requestedOffset - self.requestTask.requestOffset);
    NSUInteger respondLength = MIN(readableLength, loadingRequest.dataRequest.requestedLength);
    [loadingRequest.dataRequest respondWithData:[PTFileHandle readTempFileDataWithOffset:requestedOffset andLength:respondLength]];
    // 如果完全响应了所需要的数据，则完成缓冲
    NSUInteger currentOffset = requestedOffset + readableLength;
    NSUInteger expectOffset = requestedOffset + loadingRequest.dataRequest.requestedLength;
    if (currentOffset >= expectOffset) {
        [loadingRequest finishLoading];
        return YES;
    }
    return NO;
}

#pragma mark - AVAssetResourceLoaderDelegate
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    NSLog(@"WaitingLoadingRequest < requestedOffset = %lld, currentOffset = %lld, requestedLength = %ld", loadingRequest.dataRequest.requestedOffset, loadingRequest.dataRequest.currentOffset, loadingRequest.dataRequest.requestedLength);
    [self addLoadingRequest:loadingRequest];
    return YES;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    NSLog(@"CancelLoadingRequest  < requestedOffset = %lld, currentOffset = %lld, requestedLength = %ld >", loadingRequest.dataRequest.requestedOffset, loadingRequest.dataRequest.currentOffset, loadingRequest.dataRequest.requestedLength);
    [self removeLoadingRequest:loadingRequest];
}

#pragma mark - PTRequestTaskDelegate
- (void)requestTaskDidReceiveResponse:(NSHTTPURLResponse *)response {
    // mimeType
    mimeType = response.MIMEType;
}

- (void)requestTaskDidUpdateCache {
    [self processRequestList];
    if (self.delegate && [self.delegate respondsToSelector:@selector(loader:cacheProgress:)]) {
        CGFloat cacheProgress = (CGFloat)self.requestTask.cacheLength / (self.requestTask.fileLength -self.requestTask.requestOffset);
        [self.delegate loader:self cacheProgress:cacheProgress];
    }
}

- (void)requestTaskDidFinishDownloadWithCache:(BOOL)isCache {
    self.isCacheFinished = isCache;
}

- (void)requestTaskDidFailWithError:(NSError *)error {
    // 处理数据加载错误
}

@end
