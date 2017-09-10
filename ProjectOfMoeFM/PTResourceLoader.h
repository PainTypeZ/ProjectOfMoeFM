//
//  PTResourceLoader.h
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/9/5.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "PTRequestTask.h"

@class PTResourceLoader;
@protocol PTResourceLoaderDelegate <NSObject>

@required
- (void)loader:(PTResourceLoader *)loader cacheProgress:(CGFloat)progress;

@optional
- (void)loader:(PTResourceLoader *)loader failLoadingWithError:(NSError *)error;

@end

@interface PTResourceLoader : NSObject<AVAssetResourceLoaderDelegate, PTRequestTaskDelegate>

@property (weak, nonatomic) id<PTResourceLoaderDelegate> delegate;
@property (assign, atomic) BOOL seekRequired;
@property (assign, nonatomic) BOOL cacheFinished;

- (void)stopLoading;

@end
