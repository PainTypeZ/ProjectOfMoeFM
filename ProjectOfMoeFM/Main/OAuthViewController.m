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
NSString * const kRequestTokenURL = @"http://api.moefou.org/oauth/request_token";
NSString * const kRequestAuthorizeURL = @"http://api.moefou.org/oauth/authorize";
NSString * const kRequestAccessTokenURL = @"http://api.moefou.org/oauth/access_token";

@interface OAuthViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *authorizeWebView;
@end

@implementation OAuthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.title = @"OAuth授权";
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [app.window bringSubviewToFront:app.playerBottomView];
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
// 点击cancel跳转回home
- (IBAction)cancelAction:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *path = [request.URL description];
    NSLog(@"%@", path);
    // 截取url字符串获取验证码
    if ([path containsString:@"verifier="]) {
        NSString *subString = [[path componentsSeparatedByString:@"&"] firstObject];
        NSString *verifier = [[subString componentsSeparatedByString:@"="] lastObject];
        
        __weak OAuthViewController *weakSelf = self;
        // OAuth授权第三步
        [PTOAuthTool requestAccessOAuthTokenAndSecretWithURL:kRequestAccessTokenURL andVerifier:verifier completionHandler:^{
            //得到的accessToken和Secret已保存存到偏好设置
            // 此处可以返回主线程添加提示信息等效果
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([PTPlayerManager sharedPlayerManager].currentSong) {
                    [[PTPlayerManager sharedPlayerManager] updateFavInfoWhileLoginOAuth];
                }
                // 更新当前播放列表的歌曲信息
                weakSelf.view.userInteractionEnabled = NO;
                [SVProgressHUD showSuccessWithStatus:@"登录OAuth授权成功,即将自动跳转回主页"];
                [SVProgressHUD dismissWithDelay:2 completion:^{
                    weakSelf.view.userInteractionEnabled = YES;
                    [weakSelf dismissViewControllerAnimated:YES completion:nil];
                }];
            });
        }];
        return NO;
    }
    return YES;
}

- (void)dealloc {
    NSLog(@"授权界面被销毁了");
}

@end
