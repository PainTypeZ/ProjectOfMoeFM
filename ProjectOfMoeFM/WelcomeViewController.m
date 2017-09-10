//
//  WelcomeViewController.m
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/9/4.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import "WelcomeViewController.h"
#import "AppDelegate.h"
@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

- (IBAction)jumpToHomeAction:(UIButton *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isDoneWithWelcomeView"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UITabBarController *mainTabbarController = [mainStoryboard instantiateViewControllerWithIdentifier:@"MainTabBarController"];
//    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication];
//    appDelegate.window.rootViewController = mainTabbarController;
//    [self presentViewController:mainTabbarController animated:YES completion:nil];
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    app.window.rootViewController = mainTabbarController;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"welcome被销毁了");
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
