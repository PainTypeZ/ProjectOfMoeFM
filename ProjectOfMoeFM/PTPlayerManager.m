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

#import "PTResourceLoader.h"
#import "PTFileHandle.h"
#import "NSURL+PTLoader.h"

#define kStatus @"status"
#define kLoadedTimeRanges @"loadedTimeRanges"
#define kPlaybackBufferEmpty @"playbackBufferEmpty"
#define kPlaybackLikelyToKeepUp @"playbackLikelyToKeepUp"

@interface PTPlayerManager()<PTResourceLoaderDelegate>

@property (copy, nonatomic) NSString *currentRadioID;
@property (assign, nonatomic) NSUInteger playIndex;
@property (assign, nonatomic) NSUInteger currentPage;
@property (assign, nonatomic) NSUInteger perpage;
@property (strong, nonatomic) NSMutableArray <RadioPlaySong *>* playList;
@property (assign, nonatomic) NSUInteger count;
@property (strong, nonatomic) AVPlayer *player;

@property (strong, nonatomic) PlayerData *playerData;

@property (strong, nonatomic) PTResourceLoader *loader;

@property (assign, nonatomic) BOOL isPlay;
@property (assign, nonatomic) BOOL isUIEnable;

@end

@implementation PTPlayerManager

+ (instancetype)sharedPlayerManager {
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
        _playIndex = 0;
        _currentPage = 1;
        _perpage = 9;
        
        _playerData = [[PlayerData alloc] init];// 不能省略，因为后面的playerData赋值是用的weakself，如果没有进行初始化，则weakself.playerData会被释放掉，传值结果全是nil
        _isPlay = NO;
        _isUIEnable = NO;
        // 注册播放结束的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playDidEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        
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
    if ([keyPath isEqualToString:kStatus]) {
        AVPlayerStatus status= [[change objectForKey:@"new"] intValue];
        if(status == AVPlayerStatusReadyToPlay){
                [self.player play];
                NSLog(@"start to play");
                [self setupNowPlayingInfoCenterWithPlayTime:CMTimeGetSeconds(self.player.currentItem.currentTime)];// 后台播放所需的信息,开始播放时间是0.0
                self.isPlay = YES;
                self.isUIEnable =YES;
        }else if(status == AVPlayerStatusUnknown){
            NSLog(@"AVPlayerStatusUnknown");
        }else if (status == AVPlayerStatusFailed){
            NSLog(@"AVPlayerStatusFailed");
        }
    }else if([keyPath isEqualToString:kLoadedTimeRanges]){
        
    }else if ([keyPath isEqualToString:kPlaybackBufferEmpty]){
        
    }else if ([keyPath isEqualToString:kPlaybackLikelyToKeepUp]){
        
    }
}

// 添加新观察者
- (void)addNewOberserverToPlayerItem:(AVPlayerItem *)item {
    // avplayer的KVO
    [item addObserver:self forKeyPath:kStatus options:NSKeyValueObservingOptionNew context:nil];
    //监控网络加载情况属性
    [item addObserver:self forKeyPath:kLoadedTimeRanges options:NSKeyValueObservingOptionNew context:nil];
    //监听播放的区域缓存是否为空
    [item addObserver:self forKeyPath:kPlaybackBufferEmpty options:NSKeyValueObservingOptionNew context:nil];
    //缓存可以播放的时候调用
    [item addObserver:self forKeyPath:kPlaybackLikelyToKeepUp options:NSKeyValueObservingOptionNew context:nil];
}
// 移除旧观察者
- (void)removeOldOberserverFromPlayerItem:(AVPlayerItem *)item {
    [item removeObserver:self forKeyPath:kStatus];
    [item removeObserver:self forKeyPath:kLoadedTimeRanges];
    [item removeObserver:self forKeyPath:kPlaybackBufferEmpty];
    [item removeObserver:self forKeyPath:kPlaybackLikelyToKeepUp];
}

// 歌曲结束时的处理
- (void)playDidEnd {
    [self.loader stopLoading];

    
    self.isPlay = NO;// 改变播放状态
//    self.isUIEnable = NO;// 改变用户交互状态
    // 如果是单曲就循环播放
    if ([self.currentRadioID isEqualToString:MoeSingleSong]) {
        [self.player seekToTime:kCMTimeZero];
        [self.player play];
        self.isPlay = YES;
        return;
    }
    
    if (self.playIndex == self.playList.count - 1) {
        // 判断是不是顺序播放的收藏歌曲
        BOOL isLogin = [[NSUserDefaults standardUserDefaults] objectForKey:@"isLogin"];// 判断登录状态
        if ([self.currentRadioID isEqualToString:MoeOrderedFavList] && isLogin) {
            if (self.playIndex >= self.count - 1) {
                self.playIndex = 0;
                self.currentPage = 1;
                self.playList = [NSMutableArray array]; //重置播放列表
            } else {
                self.playIndex++;
                self.currentPage++;
            }
            
//            __weak PTPlayerManager *weakSelf = self;
            [PTWebUtils requestFavSongListWithPage:self.currentPage andPerPage:0 completionHandler:^(id object) {
                NSDictionary *dict = object;
                NSNumber *count = dict[MoeCallbackDictCountKey];
                NSArray *songIDs = dict[MoeCallbackDictSongIDKey];
                self.count = count.integerValue;
                [PTWebUtils requestPlaylistWithSongIDs:songIDs CompletionHandler:^(id object) {
                    NSDictionary *dict = object;
                    NSArray *songs = dict[MoeCallbackDictSongKey];
                    [self.playList addObjectsFromArray:songs];
                    [self readyToPlayNewSong:self.playList[self.playIndex]];
                } errorHandler:^(id error) {
                    NSLog(@"%@", error);
                }];
            } errorHandler:^(id error) {
                NSLog(@"%@", error);
            }];
        } else {
            if ([self.currentRadioID isEqualToString:MoeRandomList]) {
                self.playIndex = 0;
                [PTWebUtils requestRandomPlaylistWithCompletionHandler:^(id object) {
                    NSDictionary *dict = object;
                    NSArray *songs = dict[MoeCallbackDictSongKey];
                    self.playList = [NSMutableArray arrayWithArray:songs];
                    [self readyToPlayNewSong:self.playList[self.playIndex]];
                } errorHandler:^(id error) {
                    NSLog(@"%@", error);
                }];
            } else if ([self.currentRadioID isEqualToString:MoeFavRandomList]) {
                self.playIndex = 0;
                [PTWebUtils requestFavRandomPlaylistWithCompletionHandler:^(id object) {
                    NSDictionary *dict = object;
                    NSArray *songs = dict[MoeCallbackDictSongKey];
                    self.playList = [NSMutableArray arrayWithArray:songs];
                    [self readyToPlayNewSong:self.playList[self.playIndex]];
                } errorHandler:^(id error) {
                    NSLog(@"%@", error);
                }];
            } else {
                if (self.playIndex >= self.count - 1) {
                    self.playIndex = 0;
                    self.currentPage = 1;
                    self.playList = [NSMutableArray array]; //重置播放列表
                } else {
                    self.playIndex++;
                    self.currentPage++;
                }
                [PTWebUtils requestPlaylistWithRadioId:self.currentRadioID andPage:self.currentPage andPerpage:0 completionHandler:^(id object) {
                    NSDictionary *dict = object;
                    NSArray *songs = dict[MoeCallbackDictSongKey];
                    [self.playList addObjectsFromArray:songs];
                } errorHandler:^(id error) {
                    NSLog(@"%@", error);
                }];
            }
        }
    }else{
        self.playIndex++;// 播放序号+1
        RadioPlaySong *song = self.playList[self.playIndex];
        [self readyToPlayNewSong:song];
    }
}

// 处理换歌,包括对resourceLoader的设置
- (void)readyToPlayNewSong:(RadioPlaySong *)radioPlaySong {
    self.currentSong = radioPlaySong;
    //    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:self.currentSong.url]];
    // 检查缓存文件
    NSString *cacheFilePath = [PTFileHandle cacheFileExistsWithURL:[NSURL URLWithString:self.currentSong.url]];
    AVPlayerItem *item;
    if (cacheFilePath) {
        NSURL *url = [NSURL fileURLWithPath:cacheFilePath];
        item = [AVPlayerItem playerItemWithURL:url];
        NSLog(@"有缓存，播放已缓存的文件");
    }else{
        self.loader = [[PTResourceLoader alloc] init];
        self.loader.delegate = self;
        NSURL *url = [[NSURL URLWithString:self.currentSong.url] customSchemeURL];
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
        [asset.resourceLoader setDelegate:self.loader queue:dispatch_get_main_queue()];
        item = [AVPlayerItem playerItemWithAsset:asset];
        NSLog(@"无缓存，请求网络");
    }
    // 判断是否正在播放item
    if (self.player.currentItem) {
        [self removeOldOberserverFromPlayerItem:self.player.currentItem];// 移除旧观察者
        [self.player replaceCurrentItemWithPlayerItem:item];
    }else{
        // 初始化player的时候要更新时间观察者
        self.player = [[AVPlayer alloc] initWithPlayerItem:item];
        
        __weak PTPlayerManager *weakSelf = self;
        
        // queue传null是默认dispatch_get_mainQueeu, 不能传一个并发队列
        // 获取一个全局串行队列
        [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 5) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            // 处理播放时间、播放进度、缓冲进度
            [weakSelf handlePlayTimeAndPlayProgressAndBufferProgressWithWeakSelf:weakSelf andWeakAVPlayer:weakSelf.player];
        }];
    }
    // 添加新观察者
    [self addNewOberserverToPlayerItem:self.player.currentItem];
}

// 处理播放时间、播放进度、缓冲进度,注意要使用weakSelf
- (void)handlePlayTimeAndPlayProgressAndBufferProgressWithWeakSelf:(__weak PTPlayerManager *)weakSelf andWeakAVPlayer:(AVPlayer *)weakAVPlayer {
    // 播放进度
    CGFloat currentTime = CMTimeGetSeconds(weakAVPlayer.currentItem.currentTime);
    CMTime duration = weakAVPlayer.currentItem.duration;
    CGFloat totalDuration = CMTimeGetSeconds(duration);
   
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
    if (weakAVPlayer.currentItem.status == AVPlayerItemStatusUnknown) {
        
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

// 停止
- (void)stop {
    // 暂停歌曲，移除item，销毁player对象?
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
- (void)updateFavInfoWhileLoginOAuth {
    if (self.player.currentItem) {
        NSMutableArray <NSString *> *songIDs = [NSMutableArray array];
        for (RadioPlaySong *song in self.playList) {
            [songIDs addObject:song.wiki_id];
        }
        [PTWebUtils requestPlaylistWithSongIDs:songIDs CompletionHandler:^(id object) {
            NSDictionary *dict = object;
            self.playList = dict[MoeCallbackDictSongKey];
            self.currentSong = self.playList[self.playIndex]; // setter发送代理消息
        } errorHandler:^(id error) {
            NSLog(@"%@", error);
        }];
    }
}

// 改变播放列表
- (void)changeToPlayList:(NSArray<RadioPlaySong *> *)playList andPlayType:(NSString *)playType andSongCount:(NSUInteger)songCount {
    if ([playType isEqualToString:MoeSingleSong]) {
        self.currentRadioID = MoeSingleSong;
    } else if ([playType isEqualToString:MoeRandomList]) {
        self.currentRadioID = MoeRandomList;
        self.count = 9;
    } else if ([playType isEqualToString:MoeFavRandomList]) {
        self.currentRadioID = MoeFavRandomList;
        self.count = 9;
    } else if ([playType isEqualToString:MoeOrderedFavList]) {
        self.currentRadioID = MoeOrderedFavList;
        self.count = songCount;
    } else {
        self.currentRadioID = playType;
        self.count = songCount;
    }
    
    if (playList.count == 0) {
        NSLog(@"无效的播放列表");
        return;
    }
    self.playList = [playList mutableCopy];
    self.playIndex = 0;// 播放序号归0
    [self readyToPlayNewSong:self.playList[self.playIndex]];
}

#pragma mark - PTResourceLoaderDelegate
- (void)loader:(PTResourceLoader *)loader cacheProgress:(CGFloat)progress {
    NSLog(@"%f", progress);
}

- (void)loader:(PTResourceLoader *)loader failLoadingWithError:(NSError *)error {
    NSLog(@"%@", error);
}
#pragma mark - background controller center

// 后台播放和锁屏时在控制中心显示播放信息
- (void)setupNowPlayingInfoCenterWithPlayTime:(float)playTime {
    if (self.currentSong) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [[SDWebImageManager sharedManager] downloadImageWithURL:self.currentSong.cover[MoePictureSizeLargeKey] options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithBoundsSize:CGSizeMake(200, 200) requestHandler:^UIImage * _Nonnull(CGSize size) {
                return image;
            }];
            // 歌曲名称
            if (self.currentSong.sub_title) {
                [dict setObject:self.currentSong.sub_title forKey:MPMediaItemPropertyTitle];
            }
            // 演唱者
            if (self.currentSong.artist) {
                [dict setObject:self.currentSong.artist forKey:MPMediaItemPropertyArtist];
            }
            // 专辑名
            if (self.currentSong.wiki_title) {
                [dict setObject:self.currentSong.wiki_title forKey:MPMediaItemPropertyAlbumTitle];
            }
            // 图片
            if (artwork) {
                [dict setObject:artwork forKey:MPMediaItemPropertyArtwork];
            }
            
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
}

@end

