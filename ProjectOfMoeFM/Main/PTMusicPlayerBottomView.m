//
//  PTMusicPlayerBottomView.m
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/14.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import "PTMusicPlayerBottomView.h"
#import "MoefmAPIConst.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "PTWebUtils.h"

@interface PTMusicPlayerBottomView()

@property (strong, nonatomic) RadioPlaySong *radioPlaySong;

@end

@implementation PTMusicPlayerBottomView {
//    NSMutableArray<AVPlayerItem *> *_playerItemsList;
    AVPlayer *_avPlayer;
    NSUInteger _playIndex;
    BOOL _isPlay;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _radioPlayList = [NSMutableArray array];
    
    self.playButton.selected = NO;
    _isPlay = NO;
    
    // 测试启动时就请求11138电台的歌曲
    [PTWebUtils requestRadioPlayListWithRadio_id:@"11138" andPage:@"1" andPerpage:@"30" callback:^(id object) {
        self.radioPlayList = object;// 走setter方法
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playDidEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        [_avPlayer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        __weak PTMusicPlayerBottomView *weakSelf = self;
        __weak AVPlayer *_weakAVPlayer = _avPlayer;
        [_avPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            // 播放进度
            float currentPlayTime = _weakAVPlayer.currentItem.currentTime.value;
            float currenTimeScale = _weakAVPlayer.currentItem.currentTime.timescale;
            CMTime duration = _weakAVPlayer.currentItem.duration;
            float currenPlayTimeSeconds = currentPlayTime / currenTimeScale;
            float currenPlayTimeProgress = currenPlayTimeSeconds / CMTimeGetSeconds(_weakAVPlayer.currentItem.duration);
            weakSelf.playProgressView.progress = currenPlayTimeProgress;
            
            NSInteger reducePlayerTime = CMTimeGetSeconds(duration) - currenPlayTimeSeconds;
            weakSelf.radioSongPlayTimeLabel.text = [NSString stringWithFormat:@"-%02ld:%02ld", reducePlayerTime / 60, reducePlayerTime % 60];
            
            
            // 缓冲进度
            CMTimeRange timeRange = [_weakAVPlayer.currentItem.loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓存区域
            float startSeconds = CMTimeGetSeconds(timeRange.start);
            float durationSeconds = CMTimeGetSeconds(timeRange.duration);
            NSTimeInterval currentTimeInterval = startSeconds + durationSeconds;
            
            CGFloat totalDuration = CMTimeGetSeconds(duration);
            float currentBufferProgress = currentTimeInterval / totalDuration;
            weakSelf.bufferProgressView.progress = currentBufferProgress;
            
        }];
    }];
};

// 播放结束通知处理方法, 可能有BUG
- (void)playDidEnd {
    _isPlay = NO;
    self.playButton.selected = NO;
    if (_playIndex < self.radioPlayList.count) {
        RadioPlaySong *radioPlaySong = self.radioPlayList[_playIndex];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.radioPlaySong = radioPlaySong;// 调用setter方法显示歌曲信息
        });
        
        NSURL *url = [NSURL URLWithString:radioPlaySong.url];
        AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
        [_avPlayer replaceCurrentItemWithPlayerItem:item];
        NSLog(@"%ld", _avPlayer.status);
        _playIndex++;
        [self observeValueForKeyPath:@"status" ofObject:nil change:nil context:nil];
//        [_avPlayer play];
    }
}

// 观察者播放器状态方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        // 这个不知道意义何在，status文档介绍的是这个属性是用看playback状态的
        if (_avPlayer.status == AVPlayerStatusReadyToPlay) {
            [_avPlayer play];
            _isPlay = YES;
            self.playButton.selected = YES;
        }
    }
}

// 重写setter方法处理拿到的播放列表数据
- (void)setRadioPlayList:(NSMutableArray *)radioPlayList {
    _radioPlayList = radioPlayList;

    _playIndex = 0;
    
    RadioPlaySong *radioPlaySong = _radioPlayList[_playIndex];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.radioPlaySong = radioPlaySong;// 调用setter方法显示歌曲信息
    });
    
    NSURL *url = [NSURL URLWithString:radioPlaySong.url];
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
    
    _avPlayer = [[AVPlayer alloc] initWithPlayerItem:item];
}

// 重写setter方法处理拿到的单首歌曲数据,要异步回到主线程执行
- (void)setRadioPlaySong:(RadioPlaySong *)radioPlaySong {
    _radioPlaySong = radioPlaySong;
    if (radioPlaySong.cover[MoeCoverSizeSquareKey]) {
        NSURL *url = radioPlaySong.cover[MoeCoverSizeSquareKey];
        [_radioSongCoverImageView sd_setImageWithURL:url];
    }
    _radioSongTitleLabel.text = _radioPlaySong.title;
    
    // 时间和播放/缓存进度在观察者方法中处理，见42行
    
}

@end
