//
//  MoefmHotAlbumCollectionViewCell.m
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/9/13.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import "MoefmHotAlbumCollectionViewCell.h"
#import "MoefmAPIConst.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface MoefmHotAlbumCollectionViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *wikiImageView;
@property (weak, nonatomic) IBOutlet UILabel *wikiTitleLabel;

@end

@implementation MoefmHotAlbumCollectionViewCell
- (void)awakeFromNib {
    [super awakeFromNib];
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
}

@end
