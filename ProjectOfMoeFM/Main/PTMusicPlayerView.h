//
//  PTMusicPlayerView.h
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/14.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface PTMusicPlayerView : UIView

@property (strong, nonatomic) NSMutableArray *musicPlayList;

+ (instancetype)sharedMuiscPlayerview;


@end
