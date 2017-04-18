//
//  PlayerData.m
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/16.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import "PlayerData.h"

@implementation PlayerData
- (instancetype)init
{
    self = [super init];
    if (self) {
        _playTime = @"-00:00";
        _playProgress = 0.0;
        _bufferProgress = 0.0;
    }
    return self;
}
@end
