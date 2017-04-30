//
//  PTPlayerManager.m
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/21.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import "PTPlayerManager.h"
#import "PTWebUtils.h"
#import "MoefmAPIConst.h"
#import <SVProgressHUD.h>
#import <MediaPlayer/MediaPlayer.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface PTPlayerManager()

@property (copy, nonatomic) NSString *currentRadioID;
@property (assign, nonatomic) NSUInteger playIndex;
@property (assign, nonatomic) NSUInteger currentPage;
@property (assign, nonatomic) NSUInteger perpage;
@property (strong, nonatomic) NSMutableArray <RadioPlaySong *>* playList;
@property (strong, nonatomic) AVPlayer *player;

@property (strong, nonatomic) PlayerData *playerData;

@property (assign, nonatomic) BOOL isPlay;
@property (assign, nonatomic) BOOL isUIEnable;

@end

@implementation PTPlayerManager

+ (instancetype)sharedAVPlayerManager {
    static dispatch_once_t onceToken;
    static id avPlayerManager;
    dispatch_once(&onceToken, ^{
        avPlayerManager = [[self alloc]init];
    });
    return avPlayerManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _playList = [NSMutableArray array];
        _currentRadioID = @"11138";
        _currentSong = [[RadioPlaySong alloc] init];
        _playIndex = 0;
        _currentPage = 1;
        _perpage = 9;
        
        _playerData = [[PlayerData alloc] init];
        _isPlay = NO;
        _isUIEnable = NO;
        // 在通知中心注册一个事件中断的通知：
        // 处理中断事件的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterreption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    }
    return self;
}
// 实现接收到中断通知时的方法
// 处理中断事件，需要发送代理告知view播放状态
-(void)handleInterreption:(NSNotification *)sender
{
    if(self.isPlay == YES)
    {
        [self.player pause];
        self.isPlay = NO;
    }
    else
    {
        [self.player play];
        self.isPlay = YES;
    }
}
#pragma mark - 重写setter方法发送播放状态和歌曲信息代理消息
- (void)setCurrentSong:(RadioPlaySong *)currentSong {
    _currentSong = currentSong;
    [self.delegate sendCurrentSongInfo:_currentSong];
}

- (void)setIsPlay:(BOOL)isPlay {
    _isPlay = isPlay;
    [self.delegate sendPlayOrPauseStateWhenIsPlayChanged:_isPlay];
}

- (void)setIsUIEnable:(BOOL)isUIEnable {
    _isUIEnable = isUIEnable;
    [self.delegate sendUIEnableState:_isUIEnable];
}
#pragma mark - private methods
// KVO方法，播放全是从这里控制开始
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status= [[change objectForKey:@"new"] intValue];
        if(status == AVPlayerStatusReadyToPlay){
            [self.player play];
            [self setupNowPlayingInfoCenterWithPlayTime:0.0];// 后台播放所需的信息,开始播放时间是0.0
            self.isPlay = YES;
            self.isUIEnable =YES;
        }else if(status == AVPlayerStatusUnknown){
            NSLog(@"AVPlayerStatusUnknown");
        }else if (status == AVPlayerStatusFailed){
            NSLog(@"AVPlayerStatusFailed");
        }
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){
        
    }else if ([keyPath isEqualToString:@"playbackBufferEmpty"]){
        
    }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]){
        
    }
}

// 添加新观察者
- (void)addNewOberserverToPlayerItem:(AVPlayerItem *)item {
    // avplayer的KVO
    [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监控网络加载情况属性
    [item addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    //监听播放的区域缓存是否为空
    [item addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    //缓存可以播放的时候调用
    [item addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
}
// 移除旧观察者
- (void)removeOldOberserverFromPlayerItem:(AVPlayerItem *)item {
    [item removeObserver:self forKeyPath:@"status"];
    [item removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [item removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [item removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
}

// 歌曲结束时的处理
- (void)playDidEnd {
    self.isPlay = NO;// 改变播放状态
    self.isUIEnable = NO;// 改变用户交互状态
    
    if (self.playIndex == self.playList.count - 1) {
        self.playIndex = 0;
        self.currentPage++;
        [PTWebUtils requestRadioPlayListWithRadio_id:self.currentRadioID andPage:self.currentPage andPerpage:self.perpage completionHandler:^(id object) {
            // 需要判断返回的object.count是不是9，如果小于9要作处理
            NSArray *backArray = object;
            if (backArray.count < 9) {
                /* 写判断后的处理 */
                self.currentPage = 1;
            }
            self.playList = [backArray mutableCopy];
            RadioPlaySong *song = self.playList[self.playIndex];
            [self readyToPlayNewSong:song];
            //            [self handlePlayChangedAndAddNewOberserver];
        } errorHandler:^(id error) {
            NSLog(@"%@", error);
        }];
    }else{
        self.playIndex++;// 播放序号+1
        RadioPlaySong *song = self.playList[self.playIndex];
        [self readyToPlayNewSong:song];
        //        [self handlePlayChangedAndAddNewOberserver];
    }
}

// 处理换歌
- (void)readyToPlayNewSong:(RadioPlaySong *)radioPlaySong {
    if (self.player.currentItem) {
        [self removeOldOberserverFromPlayerItem:self.player.currentItem];// 移除旧观察者
    }
    self.currentSong = radioPlaySong;
    NSURL *url = [NSURL URLWithString:self.currentSong.url];
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
    // 判断是不是第一次播放
    if (self.player.currentItem) {
        [self.player replaceCurrentItemWithPlayerItem:item];
    }else{
        self.player = [[AVPlayer alloc] initWithPlayerItem:item];
    }
    // 添加新观察者
    [self addNewOberserverToPlayerItem:self.player.currentItem]; // 这句应该能自动处理播放，之前的想法有问题
}

// 处理播放时间、播放进度、缓冲进度,注意要使用weakSelf
- (void)handlePlayTimeAndPlayProgressAndBufferProgressWithWeakSelf:(__weak PTPlayerManager *)weakSelf andWeakAVPlayer:(AVPlayer *)weakAVPlayer {
    // 播放进度
//    CGFloat currentPlayTime = weakAVPlayer.currentItem.currentTime.value;// 当前播放器时间
//    CGFloat currenTimeScale = weakAVPlayer.currentItem.currentTime.timescale;// 当前播放时间的比例,用于转换value为float格式的秒数，float = value / scale
    CGFloat currentTime = CMTimeGetSeconds(weakAVPlayer.currentItem.currentTime);
    CMTime duration = weakAVPlayer.currentItem.duration;
    CGFloat totalDuration = CMTimeGetSeconds(duration);
//    CGFloat currenPlayTimeSeconds = currentPlayTime / currenTimeScale;
    
    
    // 播放时间
    NSInteger reducePlayerTime = totalDuration - currentTime;// 倒计时时间
    NSString *playTimeText = [NSString stringWithFormat:@"-%02ld:%02ld", reducePlayerTime / 60, reducePlayerTime % 60];// 播放时间
    
    // 播放进度
    CGFloat currenPlayTimeProgress = currentTime / totalDuration; // 播放进度
    
    // 缓冲进度
    NSArray *loadedTimeRanges = [weakAVPlayer.currentItem loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    CGFloat startSeconds = CMTimeGetSeconds(timeRange.start);// 缓冲的起点时间数
    CGFloat durationSeconds = CMTimeGetSeconds(timeRange.duration);// 已缓冲时间数
    CGFloat totalBufferSeconds = startSeconds + durationSeconds;// 加起来就是缓冲总时间数
    CGFloat totalBufferProgress = totalBufferSeconds / totalDuration;// 缓冲进度
    
    // 用此方法处理换歌时的错误显示
    if (weakAVPlayer.currentItem.status == 0) {
        
        weakSelf.playerData.playTimeValue = 0.0;
        weakSelf.playerData.playProgress = 0.0;
        weakSelf.playerData.playTime = @"-00:00";
        weakSelf.playerData.bufferProgress = 0.0;
    }else{
        weakSelf.playerData.playTimeValue = currentTime;
        weakSelf.playerData.playProgress = currenPlayTimeProgress;
        weakSelf.playerData.playTime = playTimeText;
        weakSelf.playerData.bufferProgress = totalBufferProgress;
    }
    
    [weakSelf.delegate sendPlayerDataInRealTime:weakSelf.playerData];
    [weakSelf setupNowPlayingInfoCenterWithPlayTime:currentTime];

}
#pragma mark - public methods

// 播放
- (void)play {
    [self.player play];
    self.isPlay = YES;
}

// 暂停
- (void)pause {
    [self.player pause];
    self.isPlay = NO;
}

// 下一曲
- (void)playNextSong {
    [self playDidEnd];
}
// 添加收藏
- (void)addToFavourite {
    NSString *acitonType = @"add";
    NSString *objectType;
    NSString *objectID;
    if (self.currentSong.sub_type && self.currentSong.sub_id) {
        objectType = self.currentSong.sub_type;
        objectID = self.currentSong.sub_id;
    }else{
        objectType = self.currentSong.wiki_type;
        objectID = self.currentSong.wiki_id;
    }
    
    [PTWebUtils requestUpdateToAddOrDelete:acitonType andObjectType:objectType andObjectID:objectID completionHandler:^(id object) {
        NSLog(@"%@", object);
    } errorHandler:^(id error) {
        NSLog(@"%@", error);
    }];
}

// 取消收藏
- (void)deleteFromFavourite {
    NSString *acitonType = @"delete";
    NSString *objectType;
    NSString *objectID;
    if (self.currentSong.sub_type && self.currentSong.sub_id) {
        objectType = self.currentSong.sub_type;
        objectID = self.currentSong.sub_id;
    }else{
        objectType = self.currentSong.wiki_type;
        objectID = self.currentSong.wiki_id;
    }
    
    
    [PTWebUtils requestUpdateToAddOrDelete:acitonType andObjectType:objectType andObjectID:objectID completionHandler:^(id object) {
        NSLog(@"%@", object);
    } errorHandler:^(id error) {
        NSLog(@"%@", error);
    }];
}

// 登录或退出登录是调用，更新收藏状态信息,还没实现保存歌曲播放状态，如播放时间等
- (void)updateFavInfo {
    [PTWebUtils requestRadioPlayListWithRadio_id:self.currentRadioID andPage:self.currentPage andPerpage:self.perpage completionHandler:^(id object) {
        self.playList = object;
        RadioPlaySong *song = self.playList[self.playIndex];
        [self readyToPlayNewSong:song];// 调用处理换歌的方法
    } errorHandler:^(id error) {
        NSLog(@"%@", error);
    }];
}

// 改变播放列表，也是初始播放的方法
- (void)changeToPlayList:(NSMutableArray<RadioPlaySong *> *)playList andRadioWikiID:(NSString *)wiki_id {
    
    self.playList = [playList mutableCopy];
    self.currentRadioID = wiki_id;// 设置电台id，供自动请求下一页歌曲使用
    self.playIndex = 0;// 播放序号归0
    [self readyToPlayNewSong:self.playList[self.playIndex]];
    // 第一次获得播放列表数据时添加通知和观察者
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.isUIEnable = NO;
        RadioPlaySong *song = self.playList[self.playIndex];
        [self readyToPlayNewSong:song];// 包含添加观察者等措施
        
        // 注册播放结束的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playDidEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        
        __weak PTPlayerManager *weakSelf = self;
        
        // queue传null是默认dispatch_get_mainQueeu, 不能传一个并发队列
        // 获取一个全局串行队列
        //        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 2);
        [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 5) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            // 处理播放时间、播放进度、缓冲进度
            [weakSelf handlePlayTimeAndPlayProgressAndBufferProgressWithWeakSelf:weakSelf andWeakAVPlayer:weakSelf.player];
        }];
    });
}
// 添加新项目到现有播放列表中，还未实现
- (void)addObjectToPlaylist:(id)object {
    // 要判断object类型
}

// 播放单曲
- (void)playSingleSong:(RadioPlaySong *)singleSong {
    [self.playList removeObjectAtIndex:self.playIndex];
    [self.playList insertObject:singleSong atIndex:self.playIndex];
    
    RadioPlaySong *song = self.playList[self.playIndex];
    [self readyToPlayNewSong:song];
    //    [self handlePlayChangedAndAddNewOberserver];
}

// 后台播放和锁屏时在控制中心显示播放信息
- (void)setupNowPlayingInfoCenterWithPlayTime:(float)playTime {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [[SDWebImageManager sharedManager] downloadImageWithURL:self.currentSong.cover[MoePictureSizeLargeKey] options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithBoundsSize:CGSizeMake(100, 100) requestHandler:^UIImage * _Nonnull(CGSize size) {
            return image;
        }];
        // 歌曲名称
        [dict setObject:self.currentSong.title forKey:MPMediaItemPropertyTitle];
        // 演唱者
        [dict setObject:self.currentSong.artist forKey:MPMediaItemPropertyArtist];
        // 专辑名
        [dict setObject:self.currentSong.wiki_title forKey:MPMediaItemPropertyAlbumTitle];
        // 图片
        [dict setObject:artwork forKey:MPMediaItemPropertyArtwork];
        // 音乐总时长
        CGFloat duration = CMTimeGetSeconds(self.player.currentItem.duration);
        [dict setObject:@(duration) forKey:MPMediaItemPropertyPlaybackDuration];
        // 设置已经播放时长（初始播放时传的是0.0）
        CGFloat playTime = CMTimeGetSeconds(self.player.currentItem.currentTime);
        
        [dict setObject:@(playTime) forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
        // 设置锁屏状态下屏幕显示播放音乐信息
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
    }];
    
}

@end

