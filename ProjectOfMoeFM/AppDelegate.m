//
//  AppDelegate.m
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/8.
//  Copyright © 2017年 彭平军. All rights reserved.
//


#define kPTMusicPlayerBottomViewHeight 70.0
#define kTestRadioID @"11138"

#import "AppDelegate.h"
#import "PTOAuthTool.h"
#import "PTWebUtils.h"
#import "MoefmAPIConst.h"

NSString * const kConsumerKey = @"2a964c3a6cf90dcb31fccd75703bafbc058e8e3ba";
NSString * const kConsumerSecret = @"8af19f17b8f7494853b8e2a3ea5f4669";

@interface AppDelegate ()
@property (strong, nonatomic) PlayerData *playerData;
@end

@implementation AppDelegate
#pragma makr - custom methods
- (void)updateModeldataForPlayerView:(NSNotification *)noti {
    self.playerBottomView.playerData = noti.object;
    
}
// 懒加载
- (PTMusicPlayerBottomView *)playerBottomView {
    if (!_playerBottomView) {
        _playerBottomView = [[[NSBundle mainBundle] loadNibNamed:@"PTMusicPlayerBottomView" owner:self options:nil] lastObject];
        _playerBottomView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - kPTMusicPlayerBottomViewHeight, [UIScreen mainScreen].bounds.size.width, kPTMusicPlayerBottomViewHeight);
        [self.window addSubview:_playerBottomView];
        [self.window bringSubviewToFront:_playerBottomView];
        
        _playerBottomView.delegate = self;// 设置代理
    }
    return _playerBottomView;
}

// 懒加载方式创建manager，实际上管理类并不需要单例
- (PTAVPlayerManager *)avPlayerManager {
    if (!_avPlayerManager) {
        _avPlayerManager = [[PTAVPlayerManager alloc] init];
    }
    return _avPlayerManager;
}

#pragma makr - PTAVPlayerBottomViewDelegate
// 这些方法去控制manager中的对应方法
- (void)didClickFavouriteButton {
    
}

- (void)didClickPlayButton {
    self.avPlayerManager.isPlay = !self.avPlayerManager.isPlay;
}

- (void)didClickDislikeButton {
    
}

- (void)didClickNextButton {
    [self.avPlayerManager playNextSong];
}

#pragma mark - default Methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];    
    if (![userDefaults objectForKey:@"consumer_key"]) {
        [userDefaults setObject:kConsumerKey forKey:@"consumer_key"];
        [userDefaults setObject:kConsumerSecret forKey:@"consumer_secret"];
        [userDefaults synchronize];
    }
    
    // 启动时默认开始播放，测试用
    [PTWebUtils requestRadioPlayListWithRadio_id:kTestRadioID andPage:MoePageValue andPerpage:MoePerPageValue CompletionHandler:^(id object) {
        [self.avPlayerManager changeToPlayList:object andRadioWikiID:kTestRadioID];
    } errorHandler:^(id error) {
        NSLog(@"%@", error);
    }];
    
    // 注册通知，接收playerdata
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateModeldataForPlayerView:) name:@"playerDataNotification" object:nil];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
