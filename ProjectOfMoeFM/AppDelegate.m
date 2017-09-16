//
//  AppDelegate.m
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/8.
//  Copyright © 2017年 彭平军. All rights reserved.
//


#define kPTMusicPlayerBottomViewHeight 60.0

#import "AppDelegate.h"
#import "PTOAuthTool.h"
#import "MoefmAPIConst.h"
#import "PTPlayerManager.h"
#import <UMMobClick/MobClick.h>

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

#define IOS10_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0)
#define IOS9_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
#define IOS8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define IOS7_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)

NSString * const kConsumerKey = @"2a964c3a6cf90dcb31fccd75703bafbc058e8e3ba";
NSString * const kConsumerSecret = @"8af19f17b8f7494853b8e2a3ea5f4669";
NSString * const kUMMobClickKey = @"59acc8c975ca352eb80009ec";

@interface AppDelegate ()<UNUserNotificationCenterDelegate>
@property (assign, nonatomic) UIBackgroundTaskIdentifier bgTaskId;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    // 设置button不会同时响应多个按钮同时点击
    [[UIButton appearance] setExclusiveTouch:YES];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];    
    if (![userDefaults objectForKey:@"consumer_key"]) {
        [userDefaults setObject:kConsumerKey forKey:@"consumer_key"];
        [userDefaults setObject:kConsumerSecret forKey:@"consumer_secret"];
        [userDefaults synchronize];
    }
    if (![userDefaults objectForKey:@"oauth_token"]) {
        [userDefaults setBool:NO forKey:@"isLogin"];
        [userDefaults synchronize];
    }
    
    [self replyPushNotificationAuthorization:application];// 注册APNs
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];// 手动初始化window
    
    // 创建bottomView，可以选择懒加载
    self.playerBottomView = [[[NSBundle mainBundle] loadNibNamed:@"PTMusicPlayerBottomView" owner:self options:nil] firstObject];// 这里要注意添加手势后，xib中有两个对象，手势变成了lastobject
    self.playerBottomView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - kPTMusicPlayerBottomViewHeight, [UIScreen mainScreen].bounds.size.width, kPTMusicPlayerBottomViewHeight);
    [self.window addSubview:self.playerBottomView];
//    [self.window bringSubviewToFront:_playerBottomView];
    
    // 创建MusicPlayerDetailView
    self.playerDetailView = [[[NSBundle mainBundle] loadNibNamed:@"MusicPlayerDetailView" owner:self options:nil] firstObject];
    self.playerDetailView.frame = CGRectMake(0, 2*[UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 20);
    [self.window addSubview:self.playerDetailView];
    
    // 友盟sdk配置
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [MobClick setAppVersion:version];
    
    UMConfigInstance.appKey = kUMMobClickKey;
    UMConfigInstance.channelId = @"App Store";
    [MobClick startWithConfigure:UMConfigInstance];//配置以上参数后调用此方法初始化SDK！
    
    UIStoryboard *welcomeStoryBoard = [UIStoryboard storyboardWithName:@"Welcome" bundle:[NSBundle mainBundle]];
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    BOOL isDoneWithWelcomeView = [[NSUserDefaults standardUserDefaults] boolForKey:@"isDoneWithWelcomeView"];
    if (isDoneWithWelcomeView) {
        UINavigationController *homeNavigationController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"HomeNavigation"];
//        [mainStoryBoard instantiateInitialViewController];
        self.window.rootViewController = homeNavigationController;
    } else {
        UIViewController *welcomeViewController = [welcomeStoryBoard instantiateViewControllerWithIdentifier:@"Welcome"];
//        [welcomeStoryBoard instantiateInitialViewController];
        self.window.rootViewController = welcomeViewController;
    }
    [self.window makeKeyAndVisible];
    
    return YES;
}
#pragma mark - APNs申请通知权限
// 申请通知权限
- (void)replyPushNotificationAuthorization:(UIApplication *)application{
    
    if (IOS10_OR_LATER) {
        //iOS 10 later
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        //必须写代理，不然无法监听通知的接收与点击事件
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (!error && granted) {
                //用户点击允许
                NSLog(@"APNs注册成功");
            }else{
                //用户点击不允许
                NSLog(@"APNs注册失败");
            }
        }];
        
        // 可以通过 getNotificationSettingsWithCompletionHandler 获取权限设置
        //之前注册推送服务，用户点击了同意还是不同意，以及用户之后又做了怎样的更改我们都无从得知，现在 apple 开放了这个 API，我们可以直接获取到用户的设定信息了。注意UNNotificationSettings是只读对象哦，不能直接修改！
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            NSLog(@"========%@",settings);
        }];
    }else if (IOS8_OR_LATER){
        //iOS 8 - iOS 10系统
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [application registerUserNotificationSettings:settings];
    }else{
        //iOS 8.0系统以下
        [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    }
    
    //注册远端消息通知获取device token
    [application registerForRemoteNotifications];
}

// 将得到的deviceToken传给SDK
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
    NSString *deviceString = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    deviceString = [deviceString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSLog(@"deviceToken : %@",deviceString);
    // 需要发往自己的服务器
    
}

// 注册deviceToken失败
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    
    NSLog(@"deviceToken error : %@",error.description);
    
}

#pragma mark - iOS 10 收到通知（本地和远端） UNUserNotificationCenterDelegate
//App处于前台接收通知时
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    
    //收到推送的请求
    UNNotificationRequest *request = notification.request;
    
    //收到推送的内容
    UNNotificationContent *content = request.content;
    
    //收到用户的基本信息
    NSDictionary *userInfo = content.userInfo;
    
    //收到推送消息的角标
    NSNumber *badge = content.badge;
    
    //收到推送消息body
    NSString *body = content.body;
    
    //推送消息的声音
    UNNotificationSound *sound = content.sound;
    
    // 推送消息的副标题
    NSString *subtitle = content.subtitle;
    
    // 推送消息的标题
    NSString *title = content.title;
    
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //此处省略一万行需求代码。。。。。。
        NSLog(@"iOS10 收到远程通知:%@",userInfo);
        
    }else {
        // 判断为本地通知
        //此处省略一万行需求代码。。。。。。
        NSLog(@"iOS10 收到本地通知:{\\\\nbody:%@，\\\\ntitle:%@,\\\\nsubtitle:%@,\\\\nbadge：%@，\\\\nsound：%@，\\\\nuserInfo：%@\\\\n}",body,title,subtitle,badge,sound,userInfo);
    }
    
    
    // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
    completionHandler(UNNotificationPresentationOptionBadge|
                      UNNotificationPresentationOptionSound|
                      UNNotificationPresentationOptionAlert);
    
}

//App通知的点击事件
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler{
    //收到推送的请求
    UNNotificationRequest *request = response.notification.request;
    
    //收到推送的内容
    UNNotificationContent *content = request.content;
    
    //收到用户的基本信息
    NSDictionary *userInfo = content.userInfo;
    
    //收到推送消息的角标
    NSNumber *badge = content.badge;
    
    //收到推送消息body
    NSString *body = content.body;
    
    //推送消息的声音
    UNNotificationSound *sound = content.sound;
    
    // 推送消息的副标题
    NSString *subtitle = content.subtitle;
    
    // 推送消息的标题
    NSString *title = content.title;
    
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"iOS10 收到远程通知:%@",userInfo);
        //此处省略一万行需求代码。。。。。。
        
    }else {
        // 判断为本地通知
        //此处省略一万行需求代码。。。。。。
        NSLog(@"iOS10 收到本地通知:{\\\\nbody:%@，\\\\ntitle:%@,\\\\nsubtitle:%@,\\\\nbadge：%@，\\\\nsound：%@，\\\\nuserInfo：%@\\\\n}",body,title,subtitle,badge,sound,userInfo);
    }
    
    //2016-09-27 14:42:16.353978 UserNotificationsDemo[1765:800117] Warning: UNUserNotificationCenter delegate received call to -userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler: but the completion handler was never called.
    completionHandler(); // 系统要求执行这个方法
}

#pragma mark - iOS 10之前收到通知

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"iOS6及以下系统，收到通知:%@", userInfo);
    //此处省略一万行需求代码。。。。。。
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"iOS7及以上系统，收到通知:%@", userInfo);
    completionHandler(UIBackgroundFetchResultNewData);
    //此处省略一万行需求代码。。。。。。
}

#pragma mark - 后台播放处理
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
// 实现backgroundPlayerID:这个方法:
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
                [[PTPlayerManager sharedPlayerManager] playNextSong];
                break;
                
            case UIEventSubtypeRemoteControlPlay:
                [[PTPlayerManager sharedPlayerManager] play];
                break;
                
            case UIEventSubtypeRemoteControlPause:
                [[PTPlayerManager sharedPlayerManager] pause];
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
