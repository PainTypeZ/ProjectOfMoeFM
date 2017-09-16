//
//  WikiPlayListCell.h
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/13.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoefmSong.h"
@interface WikiPlayListCell : UITableViewCell

@property (strong, nonatomic) MoefmSong *radioPlaySong;

@property (weak, nonatomic) IBOutlet UIImageView *radioSongCoverImageView;
@property (weak, nonatomic) IBOutlet UILabel *radioSongTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *radioSongArtistLabel;
@property (weak, nonatomic) IBOutlet UILabel *radioSongTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *radioSongAlbumLabel;
@property (weak, nonatomic) IBOutlet UIButton *playSongButton;

@end
