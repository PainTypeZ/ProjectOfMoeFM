//
//  MoefmWikiCollectionViewCell.m
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/9/13.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import "MoefmWikiCollectionViewCell.h"
#import "MoefmAPIConst.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface MoefmWikiCollectionViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *wikiImageView;
@property (weak, nonatomic) IBOutlet UILabel *wikiTitleLabel;

@end

@implementation MoefmWikiCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setWiki:(MoefmWiki *)wiki {
    
    _wiki = wiki;
    _wikiTitleLabel.text = _wiki.wiki_title;
    
    // 重设默认图片，防止cell复用时错误显示图片
    _wikiImageView.image = [UIImage imageNamed:@"cover_default_image.png"];
    
    NSString *coverURLString = _wiki.wiki_cover[MoePictureSizeSquareKey];
    if (![coverURLString isEqualToString:MoeDefaultPictureURL]) {
        NSURL *coverURL = [NSURL URLWithString:coverURLString];
        [_wikiImageView sd_setImageWithURL:coverURL];
    }
    
    NSString *timestamp = _wiki.wiki_date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd"]; // （@"yyyy-MM-dd hh:mm:ss"）----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    NSDate *resultDate = [NSDate dateWithTimeIntervalSince1970:timestamp.integerValue];
    NSString *resultDateString = [formatter stringFromDate:resultDate];
    
//    _radioDateLabel.text = resultDateString;
    
    //    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    //    [params setObject:MoeObjTypeValue forKey:MoeObjTypeKey];
    //    [params setObject:_radioWiki.wiki_id forKey:MoeWikiIdKey];
//    _radioSongCountLabel.hidden = YES;// 暂时不知道怎么正常显示歌曲总数
}

@end
