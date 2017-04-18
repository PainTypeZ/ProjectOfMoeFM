//
//  PTAVPlayerManager.m
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/16.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import "PTAVPlayerManager.h"
#import "PTWebUtils.h"
#import "MoefmAPIConst.h"
#import <SVProgressHUD.h>

#import "PTMusicPlayerBottomView.h"

#import "PlayerData.h"

#import "AppDelegate.h"

@interface PTAVPlayerManager()<PTAVPlayerBottomViewDelegate>


@property (copy, nonatomic) NSString *currentRadioID;
@property (assign, nonatomic) NSUInteger playIndex;
@property (assign, nonatomic) NSUInteger currentPage;
@property (assign, nonatomic) NSUInteger perpage;
@property (strong, nonatomic) NSMutableArray <RadioPlaySong *>* playList;
@property (strong, nonatomic) AVPlayer *player;

@property (strong, nonatomic) PlayerData *playerData;

@property (assign, nonatomic) BOOL isUIEnable;
@property (assign, nonatomic) BOOL isPlay;
@property (assign, nonatomic) BOOL isFavourite;
@property (assign, nonatomic) BOOL isDislike;
//@property (assign, nonatomic) BOOL isNextEnable;

@end

@implementation PTAVPlayerManager

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
        _isUIEnable = NO;
        _isPlay = NO;
        _isFavourite = NO;
        _isDislike = NO;
//        _isNextEnable = NO;
        AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        app.playerBottomView.delegate = self;
        // 在通知中心注册一个事件中断的通知：
        //处理中断事件的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterreption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    }
    return self;
}

#pragma mark - 后台运行时的方法
// 实现接收到中断通知时的方法
//处理中断事件
-(void)handleInterreption:(NSNotification *)sender
{
    if(_isPlay == YES)
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

#pragma mark - 重写setter方法发送通知
- (void)setPlayerData:(PlayerData *)playerData {
    _playerData = playerData;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"playerData" object:_playerData];
}
- (void)setCurrentSong:(RadioPlaySong *)currentSong {
    _currentSong = currentSong;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"songInfo" object:_currentSong];
}
- (void)setIsUIEnable:(BOOL)isUIEnable {
    _isUIEnable = isUIEnable;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"isUIEnable" object:@(_isUIEnable)];
}
- (void)setIsPlay:(BOOL)isPlay {
    _isPlay = isPlay;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"playButton" object:@(_isPlay)];
}
- (void)setIsFavourite:(BOOL)isFavourite {
    _isFavourite = isFavourite;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"favouriteButton" object:@(_isFavourite)];
}
#pragma mark - PTAVPlayerBottomViewDelegate
- (void)didClickFavouriteButtonAndSendState:(BOOL)isSelected {
    NSString *action = isSelected ? @"add" : @"delete";
    NSString *objectType;
    NSString *objectID;
    if (self.currentSong.sub_type && self.currentSong.sub_id) {
        objectType = self.currentSong.sub_type;
        objectID = self.currentSong.sub_id;
    }else{
        objectType = self.currentSong.wiki_type;
        objectID = self.currentSong.wiki_id;
    }

    [PTWebUtils requestUpdateToAddOrDelete:action andObjectType:objectType andObjectID:objectID completionHandler:^(id object) {
        [SVProgressHUD showSuccessWithStatus:object];
        self.isFavourite = isSelected;// 更新状态
    } errorHandler:^(id error) {
        NSLog(@"%@", error);
    }];
}
- (void)didClickPlayButtonAndSendState:(BOOL)isSelected {
    isSelected ? [self.player play] : [self.player pause];
    if (isSelected) {
        [self.player play];
        self.isPlay = YES;
    }else{
        [self.player pause];
        self.isPlay = NO;
    }
}
- (void)didClickDislikeButtonAndSendState:(BOOL)isSelected {
    // 待实现，还没查看接口
}
- (void)didClickNextButton {
    [self playDidEnd];
}
#pragma mark - 简化代码的方法
- (void)handlePlayChangedAndAddNewOberserver {
    self.currentSong = self.playList[self.playIndex];
    NSURL *url = [NSURL URLWithString:self.currentSong.url];
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
    [self.player replaceCurrentItemWithPlayerItem:item];
    // 开始播放
    [self.player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];// 添加新观察者
    [self observeValueForKeyPath:@"status" ofObject:nil change:nil context:nil];
}
// 处理播放时间、播放进度、缓冲进度
- (void)handlePlayTimeAndPlayProgressAndBufferProgressWithWeakSelf:(__weak PTAVPlayerManager *)weakSelf andWeakAVPlayer:(__weak AVPlayer *)weakAVPlayer {
    // 播放进度
    CGFloat currentPlayTime = weakAVPlayer.currentItem.currentTime.value;// 当前播放器时间
    CGFloat currenTimeScale = weakAVPlayer.currentItem.currentTime.timescale;// 当前播放时间的比例,用于转换value为float格式的秒数，float = value / scale
    
    CMTime duration = weakAVPlayer.currentItem.duration;
    CGFloat totalDuration = CMTimeGetSeconds(duration);
    CGFloat currenPlayTimeSeconds = currentPlayTime / currenTimeScale;
    
    
    // 播放时间
    NSInteger reducePlayerTime = totalDuration - currenPlayTimeSeconds;// 倒计时时间
    NSString *playTimeText = [NSString stringWithFormat:@"-%02ld:%02ld", reducePlayerTime / 60, reducePlayerTime % 60];// 播放时间
    
    // 播放进度
    CGFloat currenPlayTimeProgress = currenPlayTimeSeconds / totalDuration; // 播放进度
    
    // 缓冲进度
    NSArray *loadedTimeRanges = [weakAVPlayer.currentItem loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    CGFloat startSeconds = CMTimeGetSeconds(timeRange.start);// 缓冲的起点时间数
    CGFloat durationSeconds = CMTimeGetSeconds(timeRange.duration);// 已缓冲时间数
    CGFloat totalBufferSeconds = startSeconds + durationSeconds;// 加起来就是缓冲总时间数
    CGFloat totalBufferProgress = totalBufferSeconds / totalDuration;// 缓冲进度
    
    // 用此方法处理换歌时的错误显示
    if (weakAVPlayer.currentItem.status == 0) {
        PlayerData *data = [[PlayerData alloc] init];
        data.playTimeValue = 0.0;
        data.playProgress = 0.0;
        data.playTime = @"-00:00";
        data.bufferProgress = 0.0;
        weakSelf.playerData = data;
    }else{
        PlayerData *data = [[PlayerData alloc] init];
        data.playTimeValue = currenPlayTimeSeconds;
        data.playProgress = currenPlayTimeProgress;
        data.playTime = playTimeText;
        data.bufferProgress = totalBufferProgress;
        weakSelf.playerData = data;
    }
}

#pragma mark - 业务逻辑

- (void)updateFavInfo {
    if (self.player.currentItem) {
        [self.player.currentItem removeObserver:self forKeyPath:@"status"];// 移除旧观察者
    }
    [PTWebUtils requestRadioPlayListWithRadio_id:self.currentRadioID andPage:self.currentPage andPerpage:self.perpage completionHandler:^(id object) {
        self.playList = object;
        [self handlePlayChangedAndAddNewOberserver];
    } errorHandler:^(id error) {
        NSLog(@"%@", error);
    }];
}

// 改变播放列表，也是初始播放的方法
- (void)changeToPlayList:(NSMutableArray<RadioPlaySong *> *)playList andRadioWikiID:(NSString *)wiki_id {
    
    self.playList = [playList mutableCopy];
    self.currentRadioID = wiki_id;// 设置电台id，供自动请求下一页歌曲使用
    self.playIndex = 0;// 播放序号归0
    if (self.player.currentItem) {
        [self playDidEnd];
    }
    
    // 第一次获得播放列表数据时添加通知和观察者
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.currentSong = self.playList[self.playIndex];
        NSURL *url = [NSURL URLWithString:self.currentSong.url];
        AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
        self.player = [AVPlayer playerWithPlayerItem:item];
        
        // 注册播放结束的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playDidEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        // avplayer的KVO
        [self.player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        
        __weak PTAVPlayerManager *weakSelf = self;
        __weak AVPlayer *weakPlayer = self.player;
        
        [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            // 处理播放时间、播放进度、缓冲进度
            [weakSelf handlePlayTimeAndPlayProgressAndBufferProgressWithWeakSelf:weakSelf andWeakAVPlayer:weakPlayer];
        }];
    });
}
// 添加新项目到现有播放列表中，还未实现
- (void)addObjectToPlaylist:(id)object {
    // 要判断object类型
}

// 播放单曲
- (void)playSingleSong:(RadioPlaySong *)song {
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];// 移除旧观察者
    [self.playList removeObjectAtIndex:self.playIndex];
    [self.playList insertObject:song atIndex:self.playIndex];
    
    [self handlePlayChangedAndAddNewOberserver];
}

// 歌曲结束时的处理
- (void)playDidEnd {
    // 关闭交互
    self.isUIEnable = NO;
    
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];// 移除旧观察者
        
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
            [self handlePlayChangedAndAddNewOberserver];
        } errorHandler:^(id error) {
            NSLog(@"%@", error);
        }];
    }else{
        self.playIndex++;// 播放序号+1
        [self handlePlayChangedAndAddNewOberserver];
    }
}

// KVO方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        // 判断player是否准备好播放
        if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
            [self.player play];
            self.isPlay = YES;
            self.isUIEnable = YES;

        }
    }
}

@end
