//
//  PTAVPlayerManager.h
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/16.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "RadioPlaySong.h"
#import "PlayerData.h"

@interface PTAVPlayerManager : NSObject
//@property (strong, nonatomic) AVPlayer *avPlayer;
@property (strong, nonatomic) PlayerData *playerData;
@property (assign, nonatomic) BOOL isFavourite;
@property (assign, nonatomic) BOOL isPlay;
@property (assign, nonatomic) BOOL isDislike;

// 添加初始播放列表或改变播放列表的方法
- (void)changeToPlayList:(NSMutableArray <RadioPlaySong *>*)playList andRadioWikiID:(NSString *)wiki_id;
// 下一曲
- (void)playNextSong;
//+ (instancetype)sharedAVPlayerManager;
@end
