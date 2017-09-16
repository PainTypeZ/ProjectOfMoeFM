//
//  WikiCollectionViewCell.m
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/12.
//  Copyright © 2017年 彭平军. All rights reserved.
//

//#define kCornerRadius 10.0

#import "WikiCollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "PTOAuthTool.h"
#import "MoefmResponse.h"

#import "MoefmAPIConst.h"

@implementation WikiCollectionViewCell
- (void)awakeFromNib {
    [super awakeFromNib];
//    self.radioCoverImageView.layer.cornerRadius = kCornerRadius;用IB的运行时属性实现
//    [self.radioCoverImageView.layer setMasksToBounds:YES];
    
}

- (void)setRadioWiki:(MoefmWiki *)radioWiki {
    _radioWiki = radioWiki;
    _radioTitleLabel.text = _radioWiki.wiki_title;
    
    // 重设默认图片，防止cell复用时错误显示图片
    _radioCoverImageView.image = [UIImage imageNamed:@"cover_default_image.png"];
    
    NSString *coverURLString = _radioWiki.wiki_cover[MoePictureSizeSquareKey];
    if (![coverURLString isEqualToString:MoeDefaultPictureURL]) {
        NSURL *coverURL = [NSURL URLWithString:coverURLString];
        [_radioCoverImageView sd_setImageWithURL:coverURL];
    }
    
    NSString *timestamp = _radioWiki.wiki_date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd"]; // （@"yyyy-MM-dd hh:mm:ss"）----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    NSDate *resultDate = [NSDate dateWithTimeIntervalSince1970:timestamp.integerValue];
    NSString *resultDateString = [formatter stringFromDate:resultDate];
    
    _radioDateLabel.text = resultDateString;
    
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    [params setObject:MoeObjTypeValue forKey:MoeObjTypeKey];
//    [params setObject:_radioWiki.wiki_id forKey:MoeWikiIdKey];
    _radioSongCountLabel.hidden = YES;// 暂时不知道怎么正常显示歌曲总数
    
}

@end
