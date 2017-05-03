//
//  RadioPlayListCell.m
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/13.
//  Copyright © 2017年 彭平军. All rights reserved.
//

//#define kCornerRadius 5.0

#import "RadioPlayListCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIButton+PT_FixMultiClick.h"

#import "MoefmAPIConst.h"

@implementation RadioPlayListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [UIButton load];
    self.playSongButton.pt_acceptEventInterval = 1.5;
//    self.radioSongCoverImageView.layer.cornerRadius = kCornerRadius;
//    [self.radioSongCoverImageView.layer setMasksToBounds:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setRadioPlaySong:(RadioPlaySong *)radioPlaySong {
    _radioPlaySong = radioPlaySong;
    
    // 重设默认图片，防止cell复用时错误显示图片
    _radioSongCoverImageView.image = [UIImage imageNamed:@"cover_default_image.png"];
    
    NSString *coverURLString = _radioPlaySong.cover[MoePictureSizeSquareKey];
    if (![coverURLString isEqualToString:MoeDefaultPictureURL]) {
        NSURL *coverURL = [NSURL URLWithString:coverURLString];
        [_radioSongCoverImageView sd_setImageWithURL:coverURL];
    }

    _radioSongTitleLabel.text = _radioPlaySong.sub_title;
    _radioSongAlbumLabel.text = _radioPlaySong.wiki_title;
    _radioSongArtistLabel.text = _radioPlaySong.artist;
    _radioSongTimeLabel.text = _radioPlaySong.stream_time;
}

@end
