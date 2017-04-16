//
//  PTMusicPlayerBottomView.m
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/14.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import "PTMusicPlayerBottomView.h"
#import <SDWebImage/UIImageView+WebCache.h>

#import "MoefmAPIConst.h"

@interface PTMusicPlayerBottomView()

@property (weak, nonatomic) IBOutlet UIImageView *radioSongCoverImageView;
@property (weak, nonatomic) IBOutlet UILabel *radioSongTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *radioSongPlayTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *favouriteButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *dislikeButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIProgressView *bufferProgressView;
@property (weak, nonatomic) IBOutlet UISlider *playSliderView;
@property (weak, nonatomic) IBOutlet UIProgressView *playProgressView;

@property (strong, nonatomic) RadioPlaySong *radioPlaySong;
//@property (assign, nonatomic) BOOL isPlay;
//@property (assign, nonatomic) BOOL isDislike;
//@property (assign, nonatomic) BOOL isFavourite;

@end

@implementation PTMusicPlayerBottomView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self initProperties];
};

// 初始化私有属性和播放按钮状态
- (void)initProperties {

    self.playButton.selected = NO;
    self.userInteractionEnabled = NO; // avplayer准备好之前关闭用户交互
//    self.isPlay = NO;
//    self.isFavourite = NO;
//    self.isDislike = NO;

}


// 重写setter方法处理拿到的playerData
- (void)setPlayerData:(PlayerData *)playerData {
    
    _playerData = playerData;// 这句可能多余了。。待定
    
    // 异步主线程展示数据
    dispatch_async(dispatch_get_main_queue(), ^{
//        self.playProgressView.progress = _playerData.playProgress;
        self.playSliderView.value = _playerData.playTimeValue;
        self.bufferProgressView.progress = _playerData.bufferProgress;
        self.radioSongPlayTimeLabel.text = _playerData.playTime;
        self.radioPlaySong = _playerData.song;
        self.playButton.selected = _playerData.isPlay;
        self.userInteractionEnabled = _playerData.isEnableUI;
    });    
}

// 重写setter方法处理拿到的单首歌曲数据,已异步回到主线程执行
- (void)setRadioPlaySong:(RadioPlaySong *)radioPlaySong {
    _radioPlaySong = radioPlaySong;
    if (radioPlaySong.cover[MoeCoverSizeSquareKey]) {
        NSURL *url = radioPlaySong.cover[MoeCoverSizeSquareKey];
        [_radioSongCoverImageView sd_setImageWithURL:url];
    }
    _radioSongTitleLabel.text = _radioPlaySong.title;
    _playSliderView.maximumValue = radioPlaySong.stream_length.floatValue;
    
    
}
#pragma mark - UI action methods, send action to delegate
- (IBAction)favouriteAction:(UIButton *)sender {
    self.favouriteButton.selected = !self.favouriteButton.selected;

//    self.isFavourite = !self.isFavourite;
    [self.delegate didClickFavouriteButton];
}

- (IBAction)playAciton:(UIButton *)sender {
    self.playButton.selected = !self.playButton.selected;

//    self.isPlay = !self.isPlay;
    [self.delegate didClickPlayButton];
}

- (IBAction)dislikeAction:(UIButton *)sender {
    self.dislikeButton.selected = !self.dislikeButton.selected;

//    self.isDislike = !self.isDislike;
    [self.delegate didClickDislikeButton];
    
}

- (IBAction)nextAction:(UIButton *)sender {
    // 写一个方法或者代理？
    [self.delegate didClickNextButton];
}

@end
