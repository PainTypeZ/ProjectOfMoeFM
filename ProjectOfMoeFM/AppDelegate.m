//
//  AppDelegate.m
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/8.
//  Copyright © 2017年 彭平军. All rights reserved.
//


#define kPTMusicPlayerBottomViewHeight 60.0
#define kTestRadioID @"11138"

#import "AppDelegate.h"
#import "PTOAuthTool.h"
#import "PTWebUtils.h"
#import "MoefmAPIConst.h"
#import "PTPlayerManager.h"

NSString * const kConsumerKey = @"2a964c3a6cf90dcb31fccd75703bafbc058e8e3ba";
NSString * const kConsumerSecret = @"8af19f17b8f7494853b8e2a3ea5f4669";

@interface AppDelegate ()
@property (assign, nonatomic) UIBackgroundTaskIdentifier bgTaskId;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[UIButton appearance] setExclusiveTouch:YES];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];    
    if (![userDefaults objectForKey:@"consumer_key"]) {
        [userDefaults setObject:kConsumerKey forKey:@"consumer_key"];
        [userDefaults setObject:kConsumerSecret forKey:@"consumer_secret"];
        [userDefaults synchronize];
    }
    
    // 创建bottomView，可以选择懒加载
    self.playerBottomView = [[[NSBundle mainBundle] loadNibNamed:@"PTMusicPlayerBottomView" owner:self options:nil] lastObject];
    self.playerBottomView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - kPTMusicPlayerBottomViewHeight, [UIScreen mainScreen].bounds.size.width, kPTMusicPlayerBottomViewHeight);
    [self.window addSubview:_playerBottomView];
    [self.window bringSubviewToFront:_playerBottomView];
    
    // 用单例构造方法初始化playerManager实例
    PTPlayerManager *playerManager = [PTPlayerManager sharedAVPlayerManager];
    // 启动时默认开始播放，测试用
    [PTWebUtils requestRadioPlayListWithRadio_id:kTestRadioID andPage:1 andPerpage:9 completionHandler:^(id object) {
        [playerManager changeToPlayList:object andRadioWikiID:kTestRadioID];
    } errorHandler:^(id error) {
        NSLog(@"%@", error);
    }];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    //开启后台处理多媒体事件
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    //后台播放
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    //这样做，可以在按home键进入后台后 ，播放一段时间，几分钟吧。但是不能持续播放网络歌曲，若需要持续播放网络歌曲，还需要申请后台任务id，具体做法是：
    self.bgTaskId = [AppDelegate backgroundPlayerID:self.bgTaskId];
    //其中的_bgTaskId是后台任务UIBackgroundTaskIdentifier _bgTaskId;
}
// 实现一下backgroundPlayerID:这个方法:
+ (UIBackgroundTaskIdentifier)backgroundPlayerID:(UIBackgroundTaskIdentifier)backTaskId
{
    //设置并激活音频会话类别
    AVAudioSession *session=[AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
    //允许应用程序接收远程控制
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    //设置后台任务ID
    UIBackgroundTaskIdentifier newTaskId=UIBackgroundTaskInvalid;
    newTaskId=[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
    if(newTaskId!=UIBackgroundTaskInvalid&&backTaskId!=UIBackgroundTaskInvalid)
    {
        [[UIApplication sharedApplication] endBackgroundTask:backTaskId];
    }
    return newTaskId;
}
//重写父类方法，接受外部事件的处理
- (void) remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        switch (receivedEvent.subtype) {
                
//            case UIEventSubtypeRemoteControlTogglePlayPause:
//                [self playAndStopSong:self.playButton];
//                break;
                
//            case UIEventSubtypeRemoteControlPreviousTrack:
//                [self playLastButton:self.lastButton];
//                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
                [[PTPlayerManager sharedAVPlayerManager] playNextSong];
                break;
                
            case UIEventSubtypeRemoteControlPlay:
                [[PTPlayerManager sharedAVPlayerManager] play];
                break;
                
            case UIEventSubtypeRemoteControlPause:
                [[PTPlayerManager sharedAVPlayerManager] pause];
                break;
                
            default:
                break;
        }
    }
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
