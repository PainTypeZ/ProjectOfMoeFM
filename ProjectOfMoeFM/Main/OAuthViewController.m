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
#import "PTAVPlayerManager.h"
NSString * const kRequestTokenURL = @"http://api.moefou.org/oauth/request_token";
NSString * const kRequestAuthorizeURL = @"http://api.moefou.org/oauth/authorize";
NSString * const kRequestAccessTokenURL = @"http://api.moefou.org/oauth/access_token";

@interface OAuthViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *authorizeWebView;
@end

@implementation OAuthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self oauthStepsBegin];
}

- (void)oauthStepsBegin {
    // OAuth授权第一步
    PTOAuthModel *oauthModel = [[PTOAuthModel alloc] init];
    oauthModel.oauthURL = kRequestTokenURL;
    [PTOAuthTool requestOAuthTokenWithURL:kRequestTokenURL completionHandler:^{
        // OAuth授权第二步
        NSURL *requestURL = [PTOAuthTool getAuthorizeURLWithURL:kRequestAuthorizeURL];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
        [self.authorizeWebView loadRequest:request];
    }];
}

- (IBAction)clickCancelAction:(UIBarButtonItem *)sender {
    // 跳转回mainStoryBoard初始界面
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UIApplication *application = [UIApplication sharedApplication];
    application.keyWindow.rootViewController = [mainStoryBoard instantiateInitialViewController];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *path = [request.URL description];
    NSLog(@"%@", path);
    // 截取url字符串获取验证码
    if ([path containsString:@"verifier="]) {
        NSString *subString = [[path componentsSeparatedByString:@"&"] firstObject];
        NSString *verifier = [[subString componentsSeparatedByString:@"="] lastObject];
        // OAuth授权第三步
        [PTOAuthTool requestAccessOAuthTokenAndSecretWithURL:kRequestAccessTokenURL andVerifier:verifier completionHandler:^{
            //得到的accessToken和Secret已保存存到偏好设置
            // 此处可以添加提示信息等效果
            [SVProgressHUD showSuccessWithStatus:@"登录OAuth授权成功"];
            [SVProgressHUD dismissWithDelay:1];
            // 更新当前播放列表的歌曲信息
            [[PTAVPlayerManager sharedAVPlayerManager] updateFavInfo];
            // 跳转回mainStoryBoard初始界面
            UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            UIApplication *application = [UIApplication sharedApplication];
            application.keyWindow.rootViewController = [mainStoryBoard instantiateInitialViewController];

        }];
        return NO;
    }
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
