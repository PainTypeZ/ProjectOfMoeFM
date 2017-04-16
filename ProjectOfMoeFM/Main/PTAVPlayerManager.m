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


@interface PTAVPlayerManager()

@property (strong, nonatomic) AVPlayer *player;
@property (copy, nonatomic) NSString *currentRadioID;
@property (assign, nonatomic) NSUInteger playIndex;
@property (assign, nonatomic) NSUInteger currentPage;
@property (strong, nonatomic) NSMutableArray <RadioPlaySong *>* playList;
@property (strong, nonatomic) NSNotification *dataNotification;

@end

@implementation PTAVPlayerManager

//+ (instancetype)sharedAVPlayerManager {
//    static dispatch_once_t onceToken;
//    static id avPlayerManager;
//    dispatch_once(&onceToken, ^{
//        avPlayerManager = [[self alloc]init];
//    });
//    return avPlayerManager;
//}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _playList = [NSMutableArray array];
        // 通过通知中心发送data,此处注册通知
        _playerData = [[PlayerData alloc] init];
        _dataNotification = [[NSNotification alloc] initWithName:@"playerDataNotification" object:_playerData userInfo:nil];
        _currentPage = 1;
    }
    return self;
}

#pragma mark - 重写getter方法

// 重写playerData的getter方法发送通知
//- (PlayerData *)playerData {
//    [[NSNotificationCenter defaultCenter] postNotification:self.dataNotification];
//    return _playerData;
//}
#pragma mark - 重写setter方法
- (void)setIsFavourite:(BOOL)isFavourite {
    // 标记喜欢
}

- (void)setIsPlay:(BOOL)isPlay {
    _isPlay = isPlay;
    // 播放或者暂停判断
    if (_isPlay) {
        [self.player play];
        self.playerData.isPlay = YES;
    }else{
        [self.player pause];
        self.playerData.isPlay = NO;
    }
}

- (void)setIsDislike:(BOOL)isDislike {
    // 标记不喜欢，此功能待定
}
#pragma mark - 简化代码的方法
// 根据RadioPlaySong生成AVPlayerItem，并更新playerData
- (AVPlayerItem *)handleRadioPlaySong:(RadioPlaySong *)song {
    self.playerData.song = song;// 更新数据传递model的song实例，不能少
    NSURL *url = [NSURL URLWithString:song.url];
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
    return item;
}

// 处理播放时间、播放进度、缓冲进度
- (void)handlePlayTimeAndPlayProgressAndBufferProgressWithWeakSelf:(__weak PTAVPlayerManager *)weakSelf andWeakAVPlayer:(__weak AVPlayer *)weakAVPlayer {
    // 播放进度
    CGFloat currentPlayTime = weakAVPlayer.currentItem.currentTime.value;// 当前播放器时间
    CGFloat currenTimeScale = weakAVPlayer.currentItem.currentTime.timescale;// 当前播放时间的比例,用于转换value为float格式的秒数，float = value / scale
    
    CMTime duration = weakAVPlayer.currentItem.duration;
    CGFloat totalDuration = CMTimeGetSeconds(duration);
    CGFloat currenPlayTimeSeconds = currentPlayTime / currenTimeScale;
    weakSelf.playerData.playTimeValue = currenPlayTimeSeconds;
    
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
        weakSelf.playerData.playProgress = 0.0;
        weakSelf.playerData.playTime = @"-00:00";
        weakSelf.playerData.bufferProgress = 0.0;
    }else{
        weakSelf.playerData.playProgress = currenPlayTimeProgress;
        weakSelf.playerData.playTime = playTimeText;
        weakSelf.playerData.bufferProgress = totalBufferProgress;
    }
    // 发送data通知
    [[NSNotificationCenter defaultCenter] postNotification:weakSelf.dataNotification];
}

#pragma mark - 业务逻辑

// 改变播放列表，也是初始播放的方法
- (void)changeToPlayList:(NSMutableArray<RadioPlaySong *> *)playList andRadioWikiID:(NSString *)wiki_id {
    
    self.playList = [playList mutableCopy];
    self.currentRadioID = wiki_id;// 设置电台id，供自动请求下一页歌曲使用
    self.playIndex = 0;// 播放序号归0
    
    // 第一次获得播放列表数据时添加通知和观察者
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        RadioPlaySong *song = _playList.firstObject;
        AVPlayerItem *item = [self handleRadioPlaySong:song];
        self.player = [AVPlayer playerWithPlayerItem:item];
        
        // 注册播放结束的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playDidEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        // avplayer的KVO
        [self.player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        
        __weak PTAVPlayerManager *weakSelf = self;
        __weak AVPlayer *_weakPlayer = self.player;
        
        [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            // 处理播放时间、播放进度、缓冲进度
            [weakSelf handlePlayTimeAndPlayProgressAndBufferProgressWithWeakSelf:weakSelf andWeakAVPlayer:_weakPlayer];
        }];
    });
}
// 添加新项目到现有播放列表中，还未实现
- (void)addObjectToPlaylist:(id)object {
    // 要判断object类型
}

- (void)playNextSong {
    self.playIndex++;
    [self playDidEnd];
}

// 歌曲结束时的处理
- (void)playDidEnd {
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];// 移除旧观察者
    RadioPlaySong *song = self.playList[self.playIndex];
    AVPlayerItem *item = [self handleRadioPlaySong:song];
    [self.player replaceCurrentItemWithPlayerItem:item];
    // 开始播放
    [self.player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];// 添加新观察者
    
    [self observeValueForKeyPath:@"status" ofObject:nil change:nil context:nil];
    
    if (self.playIndex == self.playList.count) {
        self.currentPage++;
        NSString *currentPageString = [NSString stringWithFormat:@"%lu", _currentPage];
        [PTWebUtils requestRadioPlayListWithRadio_id:self.currentRadioID andPage:currentPageString andPerpage:MoePerPageValue CompletionHandler:^(id object) {
            // 需要判断返回的object.count是不是30，如果小于30要作处理
            NSArray *backArray = object;
            if (backArray.count < 30) {
                /* 写判断后的处理 */
            }
            self.playList = [backArray mutableCopy];
        } errorHandler:^(id error) {
            NSLog(@"%@", error);
        }];
    }else{
        self.playIndex++;// 播放序号+1
    }
}

// KVO方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        // 判断player是否准备好播放
        if (self.player.currentItem.status == AVPlayerStatusReadyToPlay) {
            [self.player play];
            self.playerData.isEnableUI = YES;// 更新model状态,允许使用UI
            _isPlay = YES;// 不能走setter方法
            self.playerData.isPlay = YES;// 更新model状态
            [[NSNotificationCenter defaultCenter] postNotification:self.dataNotification];
        }
    }
}

@end
