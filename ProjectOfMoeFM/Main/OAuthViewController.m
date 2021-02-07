//
//  OAuthViewController.m
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/10.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import "OAuthViewController.h"
#import "PTOAuthTool.h"
#import <SVProgressHUD.h>
#import "PTPlayerManager.h"
#import "AppDelegate.h"
//#import <UMMobClick/MobClick.h>
#import <WebKit/WebKit.h>

NSString * const kRequestTokenURL = @"http://api.moefou.org/oauth/request_token";
NSString * const kRequestAuthorizeURL = @"http://api.moefou.org/oauth/authorize";
NSString * const kRequestAccessTokenURL = @"http://api.moefou.org/oauth/access_token";

//@interface OAuthViewController ()<UIWebViewDelegate>
@interface OAuthViewController ()<WKNavigationDelegate>
@property (weak, nonatomic) IBOutlet WKWebView *authorizeWebView;
@end

@implementation OAuthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置代理
    self.authorizeWebView.navigationDelegate = self;
    
    [self oauthStepsBegin];
}

- (void)oauthStepsBegin {
    // OAuth授权第一步
    PTOAuthModel *oauthModel = [[PTOAuthModel alloc] init];
    oauthModel.oauthURL = kRequestTokenURL;
    __weak OAuthViewController *weakSelf = self;
    [PTOAuthTool requestOAuthTokenWithURL:kRequestTokenURL completionHandler:^{
        // OAuth授权第二步
        NSURL *requestURL = [PTOAuthTool getAuthorizeURLWithURL:kRequestAuthorizeURL];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
        [weakSelf.authorizeWebView loadRequest:request];
    }];
}

#pragma makr - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSString *path = [webView.URL description];
    NSLog(@"%@", path);
    // 截取url字符串获取验证码
    if ([path containsString:@"verifier="]) {
        NSString *subString = [[path componentsSeparatedByString:@"&"] firstObject];
        NSString *verifier = [[subString componentsSeparatedByString:@"="] lastObject];
        
        __weak OAuthViewController *weakSelf = self;
        // OAuth授权第三步
        [PTOAuthTool requestAccessOAuthTokenAndSecretWithURL:kRequestAccessTokenURL andVerifier:verifier completionHandler:^{
            // 得到的accessToken和Secret已保存存到偏好设置
            // 此处可以返回主线程添加提示信息等效果
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([PTPlayerManager sharedPlayerManager].currentSong) {
                    [[PTPlayerManager sharedPlayerManager] updateFavInfoWhileLoginOAuth];
                }
                // 更新当前播放列表的歌曲信息
                weakSelf.view.userInteractionEnabled = NO;
                [SVProgressHUD showSuccessWithStatus:@"登录OAuth授权成功,即将自动跳转回主页"];
//                [MobClick profileSignInWithPUID:@"我不会拿用户账号信息的" provider:@"萌否账号"];
                [SVProgressHUD dismissWithDelay:2 completion:^{
                    weakSelf.view.userInteractionEnabled = YES;
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }];
            });
        }];
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

//#pragma mark - UIWebViewDelegate
//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
//    NSString *path = [request.URL description];
//    NSLog(@"%@", path);
//    // 截取url字符串获取验证码
//    if ([path containsString:@"verifier="]) {
//        NSString *subString = [[path componentsSeparatedByString:@"&"] firstObject];
//        NSString *verifier = [[subString componentsSeparatedByString:@"="] lastObject];
//
//        __weak OAuthViewController *weakSelf = self;
//        // OAuth授权第三步
//        [PTOAuthTool requestAccessOAuthTokenAndSecretWithURL:kRequestAccessTokenURL andVerifier:verifier completionHandler:^{
//            // 得到的accessToken和Secret已保存存到偏好设置
//            // 此处可以返回主线程添加提示信息等效果
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if ([PTPlayerManager sharedPlayerManager].currentSong) {
//                    [[PTPlayerManager sharedPlayerManager] updateFavInfoWhileLoginOAuth];
//                }
//                // 更新当前播放列表的歌曲信息
//                weakSelf.view.userInteractionEnabled = NO;
//                [SVProgressHUD showSuccessWithStatus:@"登录OAuth授权成功,即将自动跳转回主页"];
////                [MobClick profileSignInWithPUID:@"我不会拿用户账号信息的" provider:@"萌否账号"];
//                [SVProgressHUD dismissWithDelay:2 completion:^{
//                    weakSelf.view.userInteractionEnabled = YES;
//                    [weakSelf.navigationController popViewControllerAnimated:YES];
//                }];
//            });
//        }];
//        return NO;
//    }
//    return YES;
//}

- (void)dealloc {
    NSLog(@"授权界面被销毁了");
}

@end
