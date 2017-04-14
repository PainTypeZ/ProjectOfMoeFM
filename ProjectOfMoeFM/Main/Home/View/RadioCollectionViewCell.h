//
//  RadioCollectionViewCell.h
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/12.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RadioWiki.h"

@interface RadioCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) RadioWiki *radioWiki;
//@property (strong, nonatomic) RadioInformation *radioInformation;
@property (weak, nonatomic) IBOutlet UIImageView *radioCoverImageView;
@property (weak, nonatomic) IBOutlet UILabel *radioTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *radioDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *radioSongCountLabel;

@end
