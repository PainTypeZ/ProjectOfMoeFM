//
//  RegisterViewController.m
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/5/24.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#define kRegisterURL @"http://moefou.org/register?redirect=http%3A%2F%2Fmoe.fm%2Flogin"

#import "RegisterViewController.h"
#import <SVProgressHUD.h>
#import <WebKit/WebKit.h>

//@interface RegisterViewController ()<UIWebViewDelegate>
@interface RegisterViewController ()<WKNavigationDelegate>
@property (weak, nonatomic) IBOutlet WKWebView *registerWebView;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置WKWebView代理
    self.registerWebView.navigationDelegate = self;
    
    NSURL *url = [NSURL URLWithString:kRegisterURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [self.registerWebView loadRequest:request];
}

#pragma makr - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    //    http://moe.fm/login
    NSString *path = [webView.URL description];
    NSLog(@"%@", path);
    // 截取url字符串获取验证码
    if ([path isEqualToString:@"http://moe.fm/login"]) {
        self.view.userInteractionEnabled = NO;
        [SVProgressHUD showSuccessWithStatus:@"注册成功,即将自动跳转回主页"];
        [SVProgressHUD dismissWithDelay:2 completion:^{
            self.view.userInteractionEnabled = YES;
            [self.navigationController popViewControllerAnimated:YES];
        }];
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

//#pragma mark - UIWebViewDelegate
//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
//    //    http://moe.fm/login
//    NSString *path = [request.URL description];
//    NSLog(@"%@", path);
//    // 截取url字符串获取验证码
//    if ([path isEqualToString:@"http://moe.fm/login"]) {
//        self.view.userInteractionEnabled = NO;
//        [SVProgressHUD showSuccessWithStatus:@"注册成功,即将自动跳转回主页"];
//        [SVProgressHUD dismissWithDelay:2 completion:^{
//            self.view.userInteractionEnabled = YES;
//            [self.navigationController popViewControllerAnimated:YES];
//        }];
//        return NO;
//    }
//    return YES;
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
