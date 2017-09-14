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

@interface RegisterViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *registerWebView;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"注册";
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.0/255 green:161.0/255 blue:209.0/255 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.hidden = NO;
    
    NSURL *url = [NSURL URLWithString:kRegisterURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [self.registerWebView loadRequest:request];
}
- (IBAction)cancelAction:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    //    http://moe.fm/login
    NSString *path = [request.URL description];
    NSLog(@"%@", path);
    // 截取url字符串获取验证码
    if ([path isEqualToString:@"http://moe.fm/login"]) {
        self.view.userInteractionEnabled = NO;
        [SVProgressHUD showSuccessWithStatus:@"注册成功,即将自动跳转回主页"];
        [SVProgressHUD dismissWithDelay:2 completion:^{
            self.view.userInteractionEnabled = YES;
            [self dismissViewControllerAnimated:YES completion:nil];
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
