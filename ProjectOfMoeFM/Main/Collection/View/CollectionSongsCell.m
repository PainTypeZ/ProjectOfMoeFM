//
//  CollectionSongsCell.m
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/5/2.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import "CollectionSongsCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "MoefmAPIConst.h"
#import "UIControl+PTFixMultiClick.h"

@implementation CollectionSongsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // 利用runtime修改button响应事件
    self.playSongButton.pt_acceptEventInterval = 2;
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
    
    NSString *timestamp = _radioPlaySong.fav_sub.fav_date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd"]; // （@"yyyy-MM-dd hh:mm:ss"）----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    NSDate *resultDate = [NSDate dateWithTimeIntervalSince1970:timestamp.integerValue];
    NSString *resultDateString = [formatter stringFromDate:resultDate];
    
    _collectionDateLabel.text = resultDateString;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
