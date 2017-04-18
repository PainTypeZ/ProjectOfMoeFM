//
//  PTMusicPlayerBottomView.m
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/14.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import "PTMusicPlayerBottomView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "RadioPlaySong.h"
#import "MoefmAPIConst.h"
#import "PlayerData.h"
#import "PTAVPlayerManager.h"
@interface PTMusicPlayerBottomView()

@property (weak, nonatomic) IBOutlet UIImageView *radioSongCoverImageView;
@property (weak, nonatomic) IBOutlet UILabel *radioSongTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *radioSongPlayTimeLabel;

@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property (weak, nonatomic) IBOutlet UIProgressView *bufferProgressView;
@property (weak, nonatomic) IBOutlet UISlider *playSliderView;
@property (weak, nonatomic) IBOutlet UIProgressView *playProgressView;

@property (strong, nonatomic) PlayerData *playerData;
@property (strong, nonatomic) RadioPlaySong *playingSong;

@end

@implementation PTMusicPlayerBottomView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self observeNoti];
    [self initProperties];
};
// 注册通知接收
- (void)observeNoti {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playDataObserve:) name:@"playerData" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(songInfoObserve:) name:@"songInfo" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isUIEnableObserve:) name:@"isUIEnable" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playButtonObserve:) name:@"playButton" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favouriteButtonObserve:) name:@"favouriteButton" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dislikeButtonObserve:) name:@"dislikeButton" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nextButtonObserve:) name:@"nextButton" object:nil];
}

// 初始化属性和播放按钮状态
- (void)initProperties {

    self.playButton.selected = NO;
    self.userInteractionEnabled = NO; // avplayer准备好之前关闭用户交互
    // 初始状态设置
    self.favouriteButton.enabled = NO;
    self.dislikeButton.enabled = NO;
    self.playSliderView.userInteractionEnabled = NO;// 还未实现拖动播放
    self.playingSong = [[RadioPlaySong alloc] init];
    self.playerData = [[PlayerData alloc] init];
}


// 重写setter方法处理拿到的playerData
- (void)setPlayerData:(PlayerData *)playerData {
    _playerData = playerData;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.playSliderView.value = _playerData.playTimeValue;
        self.bufferProgressView.progress = _playerData.bufferProgress;
        self.radioSongPlayTimeLabel.text = _playerData.playTime;
    });
}
// 重写setter方法处理拿到的单首歌曲数据
- (void)setPlayingSong:(RadioPlaySong *)playingSong {
    _playingSong = playingSong;
    if (_playingSong.cover[MoeCoverSizeSquareKey]) {
        NSURL *url = _playingSong.cover[MoeCoverSizeSquareKey];
        [_radioSongCoverImageView sd_setImageWithURL:url];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.radioSongTitleLabel.text = _playingSong.title;
        if (_playingSong.stream_length.floatValue) {
            self.playSliderView.maximumValue = _playingSong.stream_length.floatValue  / self.playSliderView.bounds.size.width * (self.playSliderView.bounds.size.width - 30);
        }
        
        if ([_playingSong.fav_sub.fav_type isEqualToString:@"1"]) {
            self.favouriteButton.selected = _playingSong.fav_sub.fav_type;
        }else{
            self.favouriteButton.selected = NO;
        }
        // 还差个dislike状态待实现
    });
}
#pragma makr - notification observe methods
- (void)playDataObserve:(NSNotification *)noti {
    self.playerData = noti.object;
}
- (void)songInfoObserve:(NSNotification *)noti {
    self.playingSong = noti.object;
}
- (void)isUIEnableObserve:(NSNotification *)noti {
    NSNumber *notiNumber = noti.object;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.userInteractionEnabled = notiNumber.boolValue;
    });
}
- (void)playButtonObserve:(NSNotification *)noti {
    NSNumber *notiNumber = noti.object;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.playButton.selected = notiNumber.boolValue;
        self.userInteractionEnabled = YES;
    });
}
- (void)favouriteButtonObserve:(NSNotification *)noti {
    NSNumber *notiNumber = noti.object;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.favouriteButton.selected = notiNumber.boolValue;
        self.favouriteButton.enabled = YES;
    });
}
- (void)dislikeButtonObserve:(NSNotification *)noti {
    NSNumber *notiNumber = noti.object;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.dislikeButton.selected = notiNumber.boolValue;
    });    
}
#pragma mark - UI action methods, send action to delegate
- (IBAction)favouriteAction:(UIButton *)sender {
    self.favouriteButton.selected = !self.favouriteButton.selected;
    self.favouriteButton.enabled = NO;
//    self.isFavourite = !self.isFavourite;
    // 发送代理
    [self.delegate didClickFavouriteButtonAndSendState:self.favouriteButton.selected];
}

- (IBAction)playAciton:(UIButton *)sender {
    self.playButton.selected = !self.playButton.selected;
    self.userInteractionEnabled = NO;
//    self.isPlay = !self.isPlay;
    // 发送代理
    [self.delegate didClickPlayButtonAndSendState:self.playButton.selected];
}

- (IBAction)dislikeAction:(UIButton *)sender {
    self.dislikeButton.selected = !self.dislikeButton.selected;

//    self.isDislike = !self.isDislike;
    // 发送代理
    [self.delegate didClickDislikeButtonAndSendState:self.dislikeButton.selected];
    
}

- (IBAction)nextAction:(UIButton *)sender {
    self.userInteractionEnabled = NO;
    // 发送代理
    [self.delegate didClickNextButton];
}

@end
