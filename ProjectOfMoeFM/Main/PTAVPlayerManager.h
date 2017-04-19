//
//  PTAVPlayerManager.h
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/16.
//  Copyright © 2017年 彭平军. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "RadioPlaySong.h"
#import "PlayerData.h"

// 回调成功信息
typedef void(^callbackBOOL)(BOOL isSuccess);
//typedef void(^callbackSongInfo)(RadioPlaySong *song);

@protocol PTAVPlayerManagerDelegate <NSObject>
@required
// 发送播放信息：播放时间，缓冲进度等
- (void)sendPlayerDataInRealTime:(PlayerData *)playerData;
// 自动开始播放和换歌时，发送歌曲信息
- (void)sendCurrentSongInfo:(RadioPlaySong *)song;
// 发送非自动播放时的播放状态改变
- (void)sendPlayOrPauseStateWhenIsPlayChanged:(BOOL)isPlay;
@end


@interface PTAVPlayerManager : NSObject
@property (strong, nonatomic) RadioPlaySong *currentSong;// 公开当前播放的歌曲信息

@property (strong, nonatomic) id<PTAVPlayerManagerDelegate> delegate;

// 播放
- (void)play;
// 暂停
- (void)pause;
// 下一曲
- (void)playNextSongWithCompletionHandler:(callbackBOOL)callbackBOOL;
// 添加收藏
- (void)addToFavouriteWithCompletionHandler:(callbackBOOL)callbackBOOL;
// 取消收藏
- (void)deleteFromFavouriteWithCompletionHandler:(callbackBOOL)callbackBOOL;

// 播放某首单曲
- (void)playSingleSong:(RadioPlaySong *)song completionHandler:(callbackBOOL)callbackBOOL;
// 添加初始播放列表或改变播放列表的方法
- (void)changeToPlayList:(NSMutableArray <RadioPlaySong *>*)playList andRadioWikiID:(NSString *)wiki_id completionHandler:(callbackBOOL)callbackBOOL;
// 登录或退出登录是调用，更新收藏状态信息
- (void)updateFavInfo;

// 单例构造方法
+ (instancetype)sharedAVPlayerManager;

@end
