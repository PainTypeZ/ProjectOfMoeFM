//
//  PTMusicPlayerView.m
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/14.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import "PTMusicPlayerView.h"
#import "RadioPlaySong.h"
#import "PTWebUtils.h"

@implementation PTMusicPlayerView {
    NSMutableArray<AVPlayerItem *> *_playerItemsList;
    AVPlayer *_avPlayer;
    NSUInteger _playIndex;
    BOOL _isPlay;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.musicPlayList = [NSMutableArray array];
    _playerItemsList = [NSMutableArray array];
    
    _isPlay = NO;
    
    [PTWebUtils requestRadioPlayListWithRadio_id:@"11138" callback:^(id object) {
        self.musicPlayList = object;// 走setter方法
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playDidEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        [_avPlayer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        
    }];
};

// 播放结束通知处理方法, 可能有BUG
- (void)playDidEnd {
    if (_playIndex < _playerItemsList.count) {
        AVPlayerItem *item = _playerItemsList[_playIndex + 1];
        [_avPlayer replaceCurrentItemWithPlayerItem:item];
        NSLog(@"%ld", _avPlayer.status);
        _playIndex++;
        [_avPlayer play];
    }
}

// 观察者播放器状态方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        // 这个不知道意义何在，status文档介绍的是这个属性是用看playback状态的
        if (_avPlayer.status == AVPlayerStatusReadyToPlay) {
            _isPlay = YES;
            [_avPlayer play];
        }
    }
}

// 单例构造方法，window启动就创建对象
+ (instancetype)sharedMuiscPlayerview {
    static dispatch_once_t onceToken;
    static id musicPlayerView;
    dispatch_once(&onceToken, ^{
        musicPlayerView = [[[NSBundle mainBundle] loadNibNamed:@"PTMusicPlayerView" owner:self options:nil] lastObject];
    });
    return musicPlayerView;
}

// 重写setter方法处理拿到的播放列表数据
- (void)setMusicPlayList:(NSMutableArray *)musicPlayList {
    _musicPlayList = musicPlayList;
    for (RadioPlaySong *radioPlaySong in _musicPlayList) {
        NSURL *url = [NSURL URLWithString:radioPlaySong.url];
        AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
        [_playerItemsList addObject:item];
    }
    _playIndex = 0;
    _avPlayer = [[AVPlayer alloc] initWithPlayerItem:_playerItemsList[_playIndex]];
        
}



@end
