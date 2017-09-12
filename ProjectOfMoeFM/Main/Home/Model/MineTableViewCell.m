//
//  MineTableViewCell.m
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/5/9.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import "MineTableViewCell.h"

@implementation MineTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setFav:(MoefmFavourite *)fav {
    _fav = fav;
    _songTitleLabel.text = _fav.obj.sub_title;
    _albumLabel.text = _fav.obj.wiki.wiki_title;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
