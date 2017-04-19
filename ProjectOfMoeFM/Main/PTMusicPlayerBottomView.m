//
//  PTMusicPlayerBottomView.m
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/14.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import "PTMusicPlayerBottomView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SVProgressHUD.h>
#import "RadioPlaySong.h"
#import "MoefmAPIConst.h"
#import "PlayerData.h"
#import "PTAVPlayerManager.h"
@interface PTMusicPlayerBottomView()<PTAVPlayerManagerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *radioSongCoverImageView;
@property (weak, nonatomic) IBOutlet UILabel *radioSongTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *radioSongPlayTimeLabel;



@property (weak, nonatomic) IBOutlet UIProgressView *bufferProgressView;
@property (weak, nonatomic) IBOutlet UISlider *playSliderView;
@property (weak, nonatomic) IBOutlet UIProgressView *playProgressView;

@property (strong, nonatomic) PlayerData *playerData;
@property (strong, nonatomic) RadioPlaySong *playingSong;

@end

@implementation PTMusicPlayerBottomView

- (void)awakeFromNib {
    [super awakeFromNib];
    // 设置代理，接收播放数据
    [PTAVPlayerManager sharedAVPlayerManager].delegate = self;
    
    [self initProperties];
    
    
};

// 初始化属性和播放按钮状态
- (void)initProperties {

    self.playButton.selected = NO;
    self.userInteractionEnabled = NO; // avplayer准备好之前关闭用户交互
    // 初始状态设置
    self.favouriteButton.enabled = NO;
    self.dislikeButton.enabled = NO;
    self.playSliderView.userInteractionEnabled = NO;// 还未实现拖动播放进度条
    self.playingSong = [[RadioPlaySong alloc] init];
    self.playerData = [[PlayerData alloc] init];// 这句应该可以不要
}

#pragma mark - UI action methods
// 点击收藏按钮
- (IBAction)favouriteAction:(UIButton *)sender {
    self.userInteractionEnabled = NO;// 关闭交互
    if (self.favouriteButton.selected) {
        [[PTAVPlayerManager sharedAVPlayerManager] deleteFromFavouriteWithCompletionHandler:^(BOOL isSuccess) {
            if (isSuccess) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD showSuccessWithStatus:@"取消收藏成功"];
                    [SVProgressHUD dismissWithDelay:1];
                    self.userInteractionEnabled = YES;
                });
            }            
        }];
    }else{
        [[PTAVPlayerManager sharedAVPlayerManager] addToFavouriteWithCompletionHandler:^(BOOL isSuccess) {
            if (isSuccess) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD showSuccessWithStatus:@"添加收藏成功"];
                    [SVProgressHUD dismissWithDelay:1];
                    self.userInteractionEnabled = YES;
                });
            }
        }];
    }
    self.favouriteButton.selected = !self.favouriteButton.selected;
    
    
}
// 点击播放/暂停按钮,按钮的选中状态更新由代理方法控制
- (IBAction)playAciton:(UIButton *)sender {
    if (self.playButton.selected) {
        [[PTAVPlayerManager sharedAVPlayerManager] pause];
    }else{
        [[PTAVPlayerManager sharedAVPlayerManager] play];
    }
}
// 点击不喜欢按钮(垃圾桶)，还未实现相关功能
- (IBAction)dislikeAction:(UIButton *)sender {
    self.dislikeButton.selected = !self.dislikeButton.selected;
    
}
// 点击下一曲
- (IBAction)nextAction:(UIButton *)sender {
    self.userInteractionEnabled = NO;// 关闭可用
    [[PTAVPlayerManager sharedAVPlayerManager] playNextSongWithCompletionHandler:^(BOOL isSuccess) {
        if (isSuccess) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.userInteractionEnabled = YES;
            });
        }
    }];
}
#pragma mark - PTAVPlayerManagerDelegate
// 接收实时播放数据
- (void)sendPlayerDataInRealTime:(PlayerData *)playerData {
    self.playerData = playerData;// 不重写setter方法更新数据
    // 需要返回主线程改变UI显示
    dispatch_async(dispatch_get_main_queue(), ^{
        self.playSliderView.value = self.playerData.playTimeValue;
        self.bufferProgressView.progress = self.playerData.bufferProgress;
        self.radioSongPlayTimeLabel.text = self.playerData.playTime;
    });
}
// 接收当前播放歌曲信息(播放开始时会收到信息)，注意与播放过程中的播放/暂停状态要分开处理
- (void)sendCurrentSongInfo:(RadioPlaySong *)song {
    self.playingSong = song;// 不重写setter方法更新数据
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // 显示歌曲标题
        self.radioSongTitleLabel.text = self.playingSong.title;
        
        // 显示歌曲总时间
        if (self.playingSong.stream_length.floatValue) {
            self.playSliderView.maximumValue = self.playingSong.stream_length.floatValue  / self.playSliderView.bounds.size.width * (self.playSliderView.bounds.size.width - 30);
        }
        // 显示歌曲收藏信息
        if ([self.playingSong.fav_sub.fav_type isEqualToString:@"1"]) {
            self.favouriteButton.selected = self.playingSong.fav_sub.fav_type.boolValue;
        }else{
            self.favouriteButton.selected = NO;
        }
        // 改变播放按钮状态
        self.playButton.selected = YES;
    });
    // 显示歌曲图片，SDWebImage方法
    if (self.playingSong.cover[MoeCoverSizeSquareKey]) {
        NSURL *url = self.playingSong.cover[MoeCoverSizeSquareKey];
        [self.radioSongCoverImageView sd_setImageWithURL:url];
    }   
}

// 接收非自动播放时的播放状态信息
- (void)sendPlayOrPauseStateWhenIsPlayChanged:(BOOL)isPlay {
    self.playButton.selected = isPlay;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.userInteractionEnabled = YES;// 首次加载时的处理
    });
}

@end
