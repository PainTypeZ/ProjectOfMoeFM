//
//  PlayerData.h
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/16.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RadioPlaySong.h"
@interface PlayerData : NSObject
@property (copy, nonatomic) NSString *playTime;
@property (assign, nonatomic) float playProgress;
@property (assign, nonatomic) float bufferProgress;


@end
