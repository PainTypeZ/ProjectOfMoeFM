//
//  PTResourceLoader.h
//  OAuthTest
//
//  Created by 彭平军 on 2017/5/4.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "PTRequestTask.h"

@class PTResourceLoader;
@protocol PTResourceLoaderDelegate <NSObject>
- (void)loader:(PTResourceLoader *)loader cacheProgress:(CGFloat)progress;
- (void)loader:(PTResourceLoader *)loader failLoadingWithError:(NSError *)error;

@end

@interface PTResourceLoader : NSObject <AVAssetResourceLoaderDelegate, PTRequestTaskDelegate>
@property (nonatomic, weak) id<PTResourceLoaderDelegate> delegate;
@property (atomic, assign) BOOL isSeek; //Seek标识
@property (nonatomic, assign) BOOL isCacheFinished;

- (void)stopLoading;
@end
