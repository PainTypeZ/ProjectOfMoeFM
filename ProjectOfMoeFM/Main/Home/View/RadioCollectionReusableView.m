//
//  RadioCollectionReusableView.m
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/18.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#define kCornerRadius 5.0

#import "RadioCollectionReusableView.h"

@implementation RadioCollectionReusableView
- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.playButton.layer.cornerRadius = kCornerRadius;
    self.browseButton.layer.cornerRadius = kCornerRadius;
    self.playButton.layer.masksToBounds = YES;
    self.browseButton.layer.masksToBounds = YES;
}
@end
