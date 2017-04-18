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

@interface PTAVPlayerManager : NSObject
@property (strong, nonatomic) RadioPlaySong *currentSong;

// 播放某首单曲
- (void)playSingleSong:(RadioPlaySong *)song;
// 添加初始播放列表或改变播放列表的方法
- (void)changeToPlayList:(NSMutableArray <RadioPlaySong *>*)playList andRadioWikiID:(NSString *)wiki_id;
// 单例构造方法
+ (instancetype)sharedAVPlayerManager;
@end
