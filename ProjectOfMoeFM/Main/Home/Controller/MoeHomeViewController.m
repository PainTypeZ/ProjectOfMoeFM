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
#import "HotAlbumView.h"
#import "HomeFooterView.h"
#import "HomeHeaderView.h"
#import "SliderSettingView.h"
#import "MoefmWikiCollectionViewCell.h"
#import "MoefmHotAlbumCollectionViewCell.h"

#import "HomeViewController.h"

#import "MoefmAPIConst.h"
#import "PTWebUtils.h"

#define kBottomPlayerViewHeight 60
#define kDistanceHeight 15*4

#define kNumberOfItemsPerRow 3
#define kSectionSpacing 10.0
#define kItemSpacing 15.0

// tag和类型标记都用同一个枚举表示
typedef enum : NSUInteger {
    WikiTypeRadio,
    WikiTypeAlbum,
    WikiTypeFavourite,
} WikiType;

@interface MoeHomeViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UserHeadPictureView *userHeadPictureView;
@property (weak, nonatomic) IBOutlet HotRadioView *hotRadioView;
@property (weak, nonatomic) IBOutlet HotAlbumView *hotAlbumView;
@property (weak, nonatomic) IBOutlet HomeHeaderView *homeHeaderView;
@property (weak, nonatomic) IBOutlet UICollectionView *hotRadioCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hotRadioCollectionViewHeightConstraint;// 根据内容设置高度约束
@property (weak, nonatomic) IBOutlet UICollectionView *hotAlbumCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hotAlbumCollectionViewHeightConstarint;// 根据内容设置高度约束

@property (strong, nonatomic) SliderSettingView *settingView;
@property (strong, nonatomic) UIView *maskView;// 滑出settingView时将剩余main view的可视部分覆盖

@property (strong, nonatomic) NSMutableArray *hotRadioList;
@property (strong, nonatomic) NSMutableArray *hotAlbumList;

@end

@implementation MoeHomeViewController
{
    CGFloat _settingViewWidth;
    CGFloat _settingViewHeight;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [app.window bringSubviewToFront:app.playerBottomView];
    self.title = @"主页";
    
    // 设置全局变量值，初始化侧滑设置栏
    _settingViewWidth = self.view.bounds.size.width * 0.6;
    _settingViewHeight = self.view.bounds.size.height - 80;
    
    // 发送网络请求
    [self sendRequest];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.hidden = YES;
}

#pragma mark - lazy loading

- (NSMutableArray *)hotRadioList {
    if (!_hotRadioList) {
        _hotRadioList = [NSMutableArray array];
    }
    return _hotRadioList;
}

- (NSMutableArray *)hotAlbumList {
    if (!_hotAlbumList) {
        _hotAlbumList = [NSMutableArray array];
    }
    return _hotAlbumList;
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
//    [self sendHotAlbumListRequest];
    // 判断登录状态决定是否请求用户信息

}

- (void)sendHotRadioListRequest {
    [PTWebUtils requestHotRadiosWithCompletionHandler:^(id object) {
        NSDictionary *dict = object;
        if (dict[MoeCallbackDictRadioKey]) {
            self.hotRadioList = dict[MoeCallbackDictRadioKey];
            dispatch_async(dispatch_get_main_queue(), ^{
                // 传值给HotRadioView，并刷新
                [self.hotRadioCollectionView reloadData];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                // 传值给HotRadioView，并刷新
                [self.hotRadioCollectionView reloadData];
            });
            NSLog(@"热门电台获取失败");
        }
    } errorHandler:^(id error) {
        NSLog(@"%@", error);
    }];
}

//- (void)sendHotAlbumListRequest {
//    [PTWebUtils requestHotAlbumWithCompletionHandler:^(id object) {
//        NSDictionary *dict = object;
//        if (dict[MoeCallbackDictAlbumKey]) {
//            self.hotAlbumList = dict[MoeCallbackDictAlbumKey];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                // 传值给HotRadioView，并刷新
//                [self.hotAlbumCollectionView reloadData];
//            });
//        } else {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                // 传值给HotRadioView，并刷新
//                [self.hotAlbumCollectionView reloadData];
//            });
//            NSLog(@"热门专辑获取失败");
//        }
//    } errorHandler:^(id error) {
//        NSLog(@"%@", error);
//    }];
//}

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
        self.maskView.alpha = 0.8;
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

- (IBAction)refreshButtonAction:(UIButton *)sender {
    if (sender.tag == WikiTypeRadio) {
        [self sendHotRadioListRequest];
    }
//    [self sendHotAlbumListRequest];
}

- (IBAction)viewMoreButtonAction:(UIButton *)sender {    
    [self performSegueWithIdentifier:@"WikiList" sender:sender];
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView.tag == WikiTypeRadio) {
        return self.hotRadioList.count;
    }
    return self.hotAlbumList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView.tag == WikiTypeRadio) {
        MoefmWikiCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HotRadioItem" forIndexPath:indexPath];
        cell.wiki = self.hotRadioList[indexPath.item];
        return cell;
    }
    MoefmHotAlbumCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HotAlbumItem" forIndexPath:indexPath];
    cell.wiki = self.hotAlbumList[indexPath.item];
    return cell;
}
#pragma mark - UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // 传值并推出详情页
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat itemWidth = (collectionView.bounds.size.width - 4 * kItemSpacing) / kNumberOfItemsPerRow;
    CGFloat itemHeight = itemWidth + 24;
    
    if (collectionView.tag == WikiTypeRadio) {
        self.hotRadioCollectionViewHeightConstraint.constant = (self.hotRadioList.count / kNumberOfItemsPerRow + 1) * (itemHeight + kSectionSpacing);
    } else {
        self.hotAlbumCollectionViewHeightConstarint.constant = (self.hotAlbumList.count / kNumberOfItemsPerRow + 1) * (itemHeight + kSectionSpacing);
    }
    
    return CGSizeMake(itemWidth, itemHeight);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return kItemSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return kSectionSpacing;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(kSectionSpacing, kItemSpacing, kSectionSpacing, kItemSpacing);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"WikiList"]) {
        HomeViewController *oldHomeVC = [segue destinationViewController];
        UIButton *button = sender;
        oldHomeVC.wikiType = button.tag;
    }
}

@end
