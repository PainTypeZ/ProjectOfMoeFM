//
//  MusicPlayerDetailView.m
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/9/15.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import "MusicPlayerDetailView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SVProgressHUD.h>
#import "MoefmSong.h"
#import "MoefmAPIConst.h"
#import "PlayerData.h"
#import "PTPlayerManager.h"
#import "UIControl+PTFixMultiClick.h"
#import "AppDelegate.h"

@interface MusicPlayerDetailView()<PTPlayerManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *albumLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bottomImageView;
@property (weak, nonatomic) IBOutlet UIProgressView *bufferProgressView;
@property (weak, nonatomic) IBOutlet UISlider *playSliderView;

@property (strong, nonatomic) PlayerData *playerData;
@property (strong, nonatomic) MoefmSong *playingSong;

@end

@implementation MusicPlayerDetailView

- (void)awakeFromNib {
    [super awakeFromNib];
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    //必须给effcetView的frame赋值,因为UIVisualEffectView是一个加到UIIamgeView上的子视图.
    effectView.frame = self.frame;
    [self.bottomImageView addSubview:effectView];
    
    // 设置代理，接收播放数据
    [PTPlayerManager sharedPlayerManager].delegate_second = self;
    
    [self initProperties];
}

// 初始化属性和播放按钮状态
- (void)initProperties {
    // 利用runtime修改button响应事件
    self.favouriteButton.pt_acceptEventInterval = 3;
    self.playButton.pt_acceptEventInterval = 0.5;
    self.nextButton.pt_acceptEventInterval = 2;
    
    self.playButton.selected = NO;
    self.userInteractionEnabled = NO; // avplayer准备好之前关闭用户交互
    // 初始状态设置
    self.favouriteButton.enabled = NO;
    
    self.playSliderView.userInteractionEnabled = NO;// 不能拖动播放进度
}

#pragma mark - UI action methods
// 点击收藏按钮
- (IBAction)favouriteAction:(UIButton *)sender {
    if (self.playingSong) {
        if (self.favouriteButton.selected) {
            [[PTPlayerManager sharedPlayerManager] deleteFromFavourite];
        }else{
            [[PTPlayerManager sharedPlayerManager] addToFavourite];
        }
        self.favouriteButton.selected = !self.favouriteButton.selected;
    }
}
// 点击播放/暂停按钮,按钮的选中状态更新由代理方法控制
- (IBAction)playAciton:(UIButton *)sender {
    if (self.playingSong) {
        if (self.playButton.selected) {
            [[PTPlayerManager sharedPlayerManager] pause];
        }else{
            [[PTPlayerManager sharedPlayerManager] play];
        }
    }
}

// 点击下一曲
- (IBAction)nextAction:(UIButton *)sender {
    if (self.playingSong) {
        [[PTPlayerManager sharedPlayerManager] playNextSong];
    }
}

// 点击图片手势action
- (IBAction)tapGestureAction:(UITapGestureRecognizer *)sender {
    [UIView animateWithDuration:0.5 animations:^{
        self.frame = CGRectMake(0, 2*[UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 20);
    }];
}

#pragma mark - PTAVPlayerManagerDelegate
// 接收缓冲进度
- (void)sendBufferData:(CGFloat)progress {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.bufferProgressView.progress = progress;
    });
}
// 接收实时播放数据
- (void)sendPlayerDataInRealTime:(PlayerData *)playerData {
    self.playerData = playerData;// 不重写setter方法更新数据
    // 需要返回主线程改变UI显示
    dispatch_async(dispatch_get_main_queue(), ^{
        // 播放进度，未实现拖动播放进度
        self.playSliderView.value = self.playerData.playProgress;
        // 播放时间显示
        self.timeLabel.text = self.playerData.playTime;
    });
}
// 接收当前播放歌曲信息(播放开始时会收到信息)，注意与播放过程中的播放/暂停状态要分开处理
- (void)sendCurrentSongInfo:(MoefmSong *)song {
    self.playingSong = song;// 不重写setter方法更新数据
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // 显示歌曲标题
        self.titleLabel.text = self.playingSong.sub_title;
        self.albumLabel.text = self.playingSong.wiki_title;
        self.artistLabel.text = self.playingSong.artist;
        // 显示歌曲收藏信息
        if ([self.playingSong.fav_sub.fav_type isEqualToString:@"1"]) {
            self.favouriteButton.selected = self.playingSong.fav_sub.fav_type.boolValue;
        }else{
            self.favouriteButton.selected = NO;
        }
        // 改变播放按钮状态
        self.playButton.selected = YES;
        
        // 显示歌曲图片，SDWebImage方法
        if (self.playingSong.cover[MoePictureSizeLargeKey]) {
            NSURL *url = self.playingSong.cover[MoePictureSizeLargeKey];
            [self.coverImageView sd_setImageWithURL:url];
            [self.bottomImageView sd_setImageWithURL:url];
        }
    });
}

// 接收非初次播放时的播放状态信息
- (void)sendPlayOrPauseStateWhenIsPlayChanged:(BOOL)isPlay {
    self.playButton.selected = isPlay;
}

// 接收用户交互状态
- (void)sendUIEnableState:(BOOL)isUIEnable {
    self.userInteractionEnabled = isUIEnable;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
