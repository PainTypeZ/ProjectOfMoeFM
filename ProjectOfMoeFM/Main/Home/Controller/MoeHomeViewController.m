//
//  MoeHomeViewController.m
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/9/10.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import "MoeHomeViewController.h"
#import "AppDelegate.h"
#import "UserHeadPictureView.h"
#import "HotRadioView.h"
#import "LatestAlbumView.h"
#import "HomeFooterView.h"
#import "HomeHeaderView.h"
#import "SliderSettingView.h"

#import "MoefmAPIConst.h"
#import "PTWebUtils.h"

#define kBottomPlayerViewHeight 60
#define kDistanceHeight 15*4

@interface MoeHomeViewController ()<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UserHeadPictureView *userHeadPictureView;
@property (weak, nonatomic) IBOutlet HotRadioView *hotRadioView;
@property (weak, nonatomic) IBOutlet LatestAlbumView *latestAlbumView;
@property (weak, nonatomic) IBOutlet HomeHeaderView *homeHeaderView;
@property (strong, nonatomic) SliderSettingView *settingView;
@property (strong, nonatomic) UIView *maskView;// 滑出settingView时将剩余main view的可视部分覆盖

@property (strong, nonatomic) NSMutableArray *hotRadioList;
@property (strong, nonatomic) NSMutableArray *latestAlbumList;

@end

@implementation MoeHomeViewController
{
    CGFloat _settingViewWidth;
    CGFloat _settingViewHeight;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [app.window bringSubviewToFront:app.playerBottomView];
    
    // 设置全局变量值，初始化侧滑设置栏
    _settingViewWidth = self.view.bounds.size.width * 0.6;
    _settingViewHeight = self.view.bounds.size.height - 80;
    
    // 发送网络请求
    [self sendRequest];
}

#pragma mark - lazy loading

- (NSMutableArray *)hotRadioList {
    if (!_hotRadioList) {
        _hotRadioList = [NSMutableArray array];
    }
    return _hotRadioList;
}

- (NSMutableArray *)latestAlbumList {
    if (!_latestAlbumList) {
        _latestAlbumList = [NSMutableArray array];
    }
    return _latestAlbumList;
}

- (SliderSettingView *)settingView {
    if (!_settingView) {
        _settingView = [[NSBundle mainBundle] loadNibNamed:@"SliderSettingView" owner:nil options:nil].firstObject;
        _settingView.frame = CGRectMake(-_settingViewWidth, 20, _settingViewWidth, _settingViewHeight);
        [self.view addSubview:_settingView];
    }
    return _settingView;
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, _settingViewHeight)];
        _maskView.backgroundColor = [UIColor grayColor];
        _maskView.alpha = 0;
        [self.view addSubview:_maskView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMaskView)];
        [_maskView addGestureRecognizer:tap];
        
        [self.view bringSubviewToFront:self.settingView];// 防止侧滑栏被maskView覆盖
    }
    return _maskView;
}

#pragma mark - privte methods

- (void)sendRequest {
    [self sendHotRadioListRequest];
    [self sendLatestRadioListRequest];
    // 判断登录状态决定是否请求用户信息

}

- (void)sendHotRadioListRequest {
    [PTWebUtils requestHotRadiosWithCompletionHandler:^(id object) {
        NSDictionary *dict = object;
        if (dict[MoeCallbackDictRadioKey]) {
            self.hotRadioList = dict[MoeCallbackDictRadioKey];
            dispatch_async(dispatch_get_main_queue(), ^{
                // 传值给HotRadioView，并刷新
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                // 传值给HotRadioView，并刷新
//                [self.radioCollectionView reloadData];
            });
            NSLog(@"热门电台获取失败");
        }
    } errorHandler:^(id error) {
        NSLog(@"%@", error);
    }];
}

- (void)sendLatestRadioListRequest {
    [PTWebUtils requestLatestAlbumWithCompletionHandler:^(id object) {
        
    } errorHandler:^(id error) {
        
    }];
}

- (void)tapMaskView {
    self.maskView.alpha = 0;
    self.maskView.hidden = YES;
    [UIView animateWithDuration:0.2 animations:^{
        self.settingView.frame = CGRectMake(-_settingViewWidth, 20, _settingViewWidth, _settingViewHeight);
    }];
}

#pragma mark - button action

- (IBAction)settingButtonAction:(UIButton *)sender {
    self.maskView.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.settingView.frame = CGRectMake(0, 20, _settingViewWidth, _settingViewHeight);
    }];
    [UIView animateWithDuration:1 animations:^{
        self.maskView.alpha = 0.7;
    }];
}

- (IBAction)loginButtonAction:(UIButton *)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"登录或注册" message:@"已有账号请选择登录，无账号请选择注册,取消则返回主页" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionLogin = [UIAlertAction actionWithTitle:@"登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        [self performSegueWithIdentifier:@"OAuthLogin" sender:nil];
    }];
    UIAlertAction *actionRegister = [UIAlertAction actionWithTitle:@"注册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        [self performSegueWithIdentifier:@"Register" sender:nil];
    }];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:actionLogin];
    [alertController addAction:actionRegister];
    [alertController addAction:actionCancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)randomPlayButtonAciton:(UIButton *)sender {
}

- (IBAction)favouriteButtonAction:(UIButton *)sender {
}



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
