//
//  MainTabBarController.m
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/8.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#define kPTMusicPlayerBottomViewHeight 70.0


#import "MainTabBarController.h"
#import "PTMusicPlayerBottomView.h"


@interface MainTabBarController ()
@property (strong, nonatomic) PTMusicPlayerBottomView *playerBottomView;
@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBar.tintColor = [UIColor whiteColor];
    self.tabBar.barTintColor = [UIColor colorWithRed:72.0/255 green:170.0/255 blue:245.0/255 alpha:1.0];
    // 暂时隐藏
    self.tabBar.hidden = YES;   
    // 创建底部播放条,换到window下了
//    [self initPlayerBottomView];
    
}

// 创建底部播放条
//- (void)initPlayerBottomView {
//    self.playerBottomView = [[[NSBundle mainBundle] loadNibNamed:@"PTMusicPlayerBottomView" owner:self options:nil] lastObject];
//    self.playerBottomView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - kPTMusicPlayerBottomViewHeight, [UIScreen mainScreen].bounds.size.width, kPTMusicPlayerBottomViewHeight);
//    [self.view addSubview:self.playerBottomView];
//    [self.view bringSubviewToFront:self.playerBottomView];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
