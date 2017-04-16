//
//  AppDelegate.h
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/8.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTMusicPlayerBottomView.h"
#import "PTAVPlayerManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, PTAVPlayerBottomViewDelegate>

@property (strong, nonatomic) PTMusicPlayerBottomView *playerBottomView;
@property (strong, nonatomic) PTAVPlayerManager *avPlayerManager;

@property (strong, nonatomic) UIWindow *window;


@end

