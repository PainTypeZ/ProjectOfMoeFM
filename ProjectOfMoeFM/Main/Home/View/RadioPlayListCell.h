//
//  RadioPlayListCell.h
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/13.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RadioPlaySong.h"
@interface RadioPlayListCell : UITableViewCell

@property (strong, nonatomic) RadioPlaySong *radioPlaySong;

@property (weak, nonatomic) IBOutlet UIImageView *radioSongCoverImageView;
@property (weak, nonatomic) IBOutlet UILabel *radioSongTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *radioSongArtistLabel;
@property (weak, nonatomic) IBOutlet UILabel *radioSongTimeLabel;

@end
