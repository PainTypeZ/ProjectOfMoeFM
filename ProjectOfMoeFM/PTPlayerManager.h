//
//  PTPlayerManager.h
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/21.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MoefmSong.h"
#import "PlayerData.h"

// 回调成功信息
typedef void(^callbackBOOL)(BOOL isSuccess);
//typedef void(^callbackSongInfo)(RadioPlaySong *song);

@protocol PTPlayerManagerDelegate <NSObject>
@required
// 发送播放信息：播放时间，缓冲进度等
- (void)sendPlayerDataInRealTime:(PlayerData *)playerData;
// 缓冲进度单独发送
- (void)sendBufferData:(CGFloat)progress;
// 自动开始播放和换歌时，发送歌曲信息
- (void)sendCurrentSongInfo:(MoefmSong *)song;
// 发送非自动播放时的播放状态改变
- (void)sendPlayOrPauseStateWhenIsPlayChanged:(BOOL)isPlay;
// 发送用户交互状态
- (void)sendUIEnableState:(BOOL)isUIEnable;
@end


@interface PTPlayerManager : UIResponder

@property (strong, nonatomic) MoefmSong *currentSong;// 公开当前播放的歌曲信息

@property (weak, nonatomic) id<PTPlayerManagerDelegate> delegate;// 不是父子关系一般不使用weak修饰，父子关系才容易造成循环引用

// 播放
- (void)play;
// 暂停
- (void)pause;
// 停止
- (void)stop;
// 下一曲
- (void)playNextSong;
// 添加收藏
- (void)addToFavourite;
// 取消收藏
- (void)deleteFromFavourite;

// 改变播放列表
- (void)changeToPlayList:(NSArray<MoefmSong *> *)playList andPlayType:(NSString *_Nullable)playType andSongIDs:(NSArray *_Nullable)songIDs;

// 登录时调用，更新收藏状态信息，登出时不需要
- (void)updateFavInfoWhileLoginOAuth;

// 清理缓存文件
- (BOOL)cleanCaches;

// 单例构造方法
+ (instancetype)sharedPlayerManager;

@end
