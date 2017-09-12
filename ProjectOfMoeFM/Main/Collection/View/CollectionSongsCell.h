//
//  CollectionSongsCell.h
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/5/2.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoefmSong.h"

@interface CollectionSongsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *radioSongCoverImageView;
@property (weak, nonatomic) IBOutlet UILabel *radioSongTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *radioSongArtistLabel;
@property (weak, nonatomic) IBOutlet UILabel *radioSongTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *collectionDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *radioSongAlbumLabel;
@property (weak, nonatomic) IBOutlet UIButton *playSongButton;

@property (strong, nonatomic) MoefmSong *radioPlaySong;

@end
