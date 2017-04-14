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

@implementation PTMusicPlayerBottomView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setRadioPlaySong:(RadioPlaySong *)radioPlaySong {
    _radioPlaySong = radioPlaySong;
    if (radioPlaySong.cover[MoeCoverSizeSquareKey]) {
        NSURL *url = radioPlaySong.cover[MoeCoverSizeSquareKey];
        [_radioSongCoverImageView sd_setImageWithURL:url];
    }
    _radioSongTitleLabel.text = _radioPlaySong.title;
    _radioSongPlayTimeLabel.text = _radioPlaySong.stream_length;
    
}

@end
