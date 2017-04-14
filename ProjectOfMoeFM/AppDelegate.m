//
//  AppDelegate.m
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/8.
//  Copyright © 2017年 彭平军. All rights reserved.
//



#import "AppDelegate.h"
#import "PTOAuthTool.h"
#import "PTMusicPlayerView.h"

NSString * const kConsumerKey = @"2a964c3a6cf90dcb31fccd75703bafbc058e8e3ba";
NSString * const kConsumerSecret = @"8af19f17b8f7494853b8e2a3ea5f4669";

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];    
    if (![userDefaults objectForKey:@"consumer_key"]) {
        [userDefaults setObject:kConsumerKey forKey:@"consumer_key"];
        [userDefaults setObject:kConsumerSecret forKey:@"consumer_secret"];
        [userDefaults synchronize];
    }
    PTMusicPlayerView *musicPlayerView = [PTMusicPlayerView sharedMuiscPlayerview];
    musicPlayerView.backgroundColor = [UIColor clearColor];
    [self.window addSubview:musicPlayerView];
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
