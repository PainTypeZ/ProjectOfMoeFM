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
#import "SliderSettingView.h"
#import "MoefmWikiCollectionViewCell.h"
#import "MoefmHotAlbumCollectionViewCell.h"
#import "MoefmUser.h"

#import "WikiListViewController.h"
#import "MineViewController.h"
#import "PTPlayerManager.h"
#import "WikiPlayListViewController.h"

#import "MoefmAPIConst.h"
#import "PTWebUtils.h"
#import "UIControl+PTFixMultiClick.h"

#import <SVProgressHUD.h>
#import <SDWebImage/UIImageView+WebCache.h>

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
@property (weak, nonatomic) IBOutlet UICollectionView *hotRadioCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hotRadioCollectionViewHeightConstraint;// 根据内容设置高度约束
@property (weak, nonatomic) IBOutlet UICollectionView *hotAlbumCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hotAlbumCollectionViewHeightConstarint;// 根据内容设置高度约束
@property (weak, nonatomic) IBOutlet UIBarButtonItem *loginBarButtonItem;
@property (weak, nonatomic) IBOutlet UILabel *userNickNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userAvatarImageView;
@property (weak, nonatomic) IBOutlet UIButton *randomPlayButton;
@property (weak, nonatomic) IBOutlet UIButton *myFavouriteButton;
@property (weak, nonatomic) IBOutlet UIButton *hotRadioRefreshButton;
@property (weak, nonatomic) IBOutlet UIButton *hotAlbumRefreshButton;

@property (strong, nonatomic) SliderSettingView *settingView;
@property (strong, nonatomic) UIView *maskView;// 滑出settingView时将剩余main view的可视部分覆盖

@property (strong, nonatomic) NSMutableArray *hotRadioList;
@property (strong, nonatomic) NSMutableArray *hotAlbumList;

@property (strong, nonatomic) MoefmUser *userInfo;
@property (assign, nonatomic) BOOL isRefreshAction;

@end

@implementation MoeHomeViewController
{
    CGFloat _settingViewWidth;
    CGFloat _settingViewHeight;
    CGFloat _settingViewPointY;
    BOOL _settingViewIsShowing;
    NSUInteger _wikiType;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = kMoeFMThemeColor;

    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [app.window bringSubviewToFront:app.playerBottomView];

    // 设置全局变量值，初始化侧滑设置栏
    _settingViewWidth = self.view.bounds.size.width * 0.8;
    _settingViewHeight = self.view.bounds.size.height - 120;
    _settingViewPointY = 60;
    _settingViewIsShowing = NO;
    
    // 利用runtime修改button响应事件
    self.randomPlayButton.pt_acceptEventInterval = 3;
    self.hotRadioRefreshButton.pt_acceptEventInterval = 3;
    self.hotAlbumRefreshButton.pt_acceptEventInterval = 3;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.isRefreshAction = NO;
    [self checkOAuthState];
    [self sendRequest];
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
        _settingView.frame = CGRectMake(-_settingViewWidth, _settingViewPointY, _settingViewWidth, _settingViewHeight);
        [self.view addSubview:_settingView];
    }
    return _settingView;
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, _settingViewPointY, self.view.bounds.size.width, _settingViewHeight)];
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

// 检查是否登录OAuth
- (void)checkOAuthState {
    BOOL isLogin = [[NSUserDefaults standardUserDefaults] boolForKey:@"isLogin"];
    NSLog(@"loginState:%@", isLogin?@"YES":@"NO");
    if (isLogin) {
        [self.loginBarButtonItem setTitle:@"退出登录"];
        AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        app.playerBottomView.favouriteButton.enabled = YES;
        app.playerDetailView.favouriteButton.enabled = YES;

    }else{
        AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        app.playerBottomView.favouriteButton.enabled = NO;
        app.playerDetailView.favouriteButton.enabled = NO;
        [self.loginBarButtonItem setTitle:@"登录"];
    }
}

- (void)sendRequest {
    [self sendHotRadioListRequest];
    [self sendHotAlbumListRequest];
    // 判断登录状态决定是否请求用户信息
    BOOL isLogin = [[NSUserDefaults standardUserDefaults] boolForKey:@"isLogin"];
    if (isLogin) {
        [PTWebUtils requestUserInfoWithCompletionHandler:^(id object) {
            NSDictionary *dict = object;
            
            if ([dict[@"isOAuth"] isEqualToString:@"NO"]) {
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isLogin"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                dispatch_async(dispatch_get_main_queue(), ^{
                    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    app.playerBottomView.favouriteButton.enabled = NO;
                    app.playerDetailView.favouriteButton.enabled = NO;
                    [self.loginBarButtonItem setTitle:@"登录"];
                });
                [self sendHotRadioListRequest];
                [self sendHotAlbumListRequest];
                NSLog(@"OAuthToken已失效");
            }else{
                NSLog(@"%@,%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"oauth_token"], [[NSUserDefaults standardUserDefaults] objectForKey:@"oauth_token_secret"]);
                
                self.userInfo = dict[@"user"];
                if (self.userInfo) {
                    [self.userAvatarImageView sd_setImageWithURL:self.userInfo.user_avatar[MoePictureSizeLargeKey]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.userNickNameLabel.text = self.userInfo.user_nickname;
                        AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
                        app.playerBottomView.favouriteButton.enabled = YES;
                        app.playerDetailView.favouriteButton.enabled = YES;
                        [self.loginBarButtonItem setTitle:@"退出登录"];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                       [self showDefaultUserInfo];
                        NSLog(@"获取用户头像/昵称信息出错");
                    });
                }
            }
        } errorHandler:^(id error) {
            NSLog(@"%@", error);
        }];
    }
}

- (void)showDefaultUserInfo {
    self.userNickNameLabel.text = @"获取失败";
    self.userAvatarImageView.image = [UIImage imageNamed:@"cover_default_image.png"];
}

- (void)sendHotRadioListRequest {
    [PTWebUtils requestHotRadiosWithCompletionHandler:^(id object) {
        NSDictionary *dict = object;
        if (dict[MoeCallbackDictRadioKey]) {
            self.hotRadioList = dict[MoeCallbackDictRadioKey];
            dispatch_async(dispatch_get_main_queue(), ^{
                // 传值给HotRadioView，并刷新
                [self.hotRadioCollectionView reloadData];
                if (self.isRefreshAction == YES) {
                    [SVProgressHUD showSuccessWithStatus:@"热门电台刷新成功"];
                    [SVProgressHUD dismissWithDelay:1];
                }
            });
            NSLog(@"热门电台获取成功");
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                // 传值给HotRadioView，并刷新
                [self.hotRadioCollectionView reloadData];
                if (self.isRefreshAction == YES) {
                    [SVProgressHUD showErrorWithStatus:@"热门电台刷新失败"];
                    [SVProgressHUD dismissWithDelay:1];
                }
            });
            NSLog(@"热门电台获取失败");
        }
    } errorHandler:^(id error) {
        NSLog(@"%@", error);
    }];
}

- (void)sendHotAlbumListRequest {
    [PTWebUtils requestHotAlbumsWithCompletionHandler:^(id object) {
        NSDictionary *dict = object;
        if (dict[MoeCallbackDictAlbumKey]) {
            self.hotAlbumList = dict[MoeCallbackDictAlbumKey];
            dispatch_async(dispatch_get_main_queue(), ^{
                // 传值给HotRadioView，并刷新
                [self.hotAlbumCollectionView reloadData];
                if (self.isRefreshAction == YES) {
                    [SVProgressHUD showSuccessWithStatus:@"热门专辑刷新成功"];
                    [SVProgressHUD dismissWithDelay:0.5];
                }
            });
            NSLog(@"热门专辑获取成功");
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                // 传值给HotAlbumView，并刷新
                [self.hotAlbumCollectionView reloadData];
                if (self.isRefreshAction == YES) {
                    [SVProgressHUD showErrorWithStatus:@"热门专辑刷新失败"];
                    [SVProgressHUD dismissWithDelay:0.5];
                }
            });
            NSLog(@"热门专辑获取失败");
        }
    } errorHandler:^(id error) {
        NSLog(@"%@", error);
    }];
}

- (void)tapMaskView {
    _settingViewIsShowing = NO;
    self.maskView.alpha = 0;
    self.maskView.hidden = YES;
    [UIView animateWithDuration:0.2 animations:^{
        self.settingView.frame = CGRectMake(-_settingViewWidth, _settingViewPointY, _settingViewWidth, _settingViewHeight);
    }];
}

// 退出登录
- (void)oauthLoginOut {
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"退出登录" message:@"退出登录后将无法使用收藏功能，确定退出吗？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionConfirm = [UIAlertAction actionWithTitle:@"确定退出" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults removeObjectForKey:@"oauth_token"];
        [userDefaults removeObjectForKey:@"oauth_token_secret"];
        [userDefaults setBool:NO forKey:@"isLogin"];
        [userDefaults synchronize];
        [self.loginBarButtonItem setTitle:@"登录"];
        app.playerBottomView.favouriteButton.enabled = NO;
        app.playerDetailView.favouriteButton.enabled = NO;
    }];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:actionCancel];
    [alertController addAction:actionConfirm];
    [self presentViewController:alertController animated:YES completion:nil];

}

#pragma mark - interface action

- (IBAction)settingBarButtonItemAction:(UIBarButtonItem *)sender {
    _settingViewIsShowing = !_settingViewIsShowing;
    if (_settingViewIsShowing == YES) {
        self.maskView.hidden = NO;
        [UIView animateWithDuration:0.2 animations:^{
            self.settingView.frame = CGRectMake(0, _settingViewPointY, _settingViewWidth, _settingViewHeight);
        }];
        [UIView animateWithDuration:1 animations:^{
            self.maskView.alpha = 0.8;
        }];
    } else {
        self.maskView.alpha = 0;
        self.maskView.hidden = YES;
        [UIView animateWithDuration:0.2 animations:^{
            self.settingView.frame = CGRectMake(-_settingViewWidth, _settingViewPointY, _settingViewWidth, _settingViewHeight);
        }];
    }
}

// 登录/推出登录按钮
- (IBAction)loginBarButtonItemAction:(UIBarButtonItem *)sender {
    if ([sender.title isEqualToString:@"退出登录"]) {
        [self oauthLoginOut];
    }else{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"登录或注册" message:@"已有账号请选择登录，无账号请选择注册" preferredStyle:UIAlertControllerStyleAlert];
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
}

- (IBAction)userHeadPicTapAction:(UITapGestureRecognizer *)sender {
    // 点击头像，推出个人信息界面
    BOOL isLogin = [[NSUserDefaults standardUserDefaults] boolForKey:@"isLogin"];
    if (isLogin) {
        [self performSegueWithIdentifier:@"UserInfo" sender:nil];
    }else{
        [SVProgressHUD showErrorWithStatus:@"请先登录OAuth授权"];
        [SVProgressHUD dismissWithDelay:2];
    }
}

// 魔力播放按钮
- (IBAction)randomPlayButtonAciton:(UIButton *)sender {
    sender.enabled = NO;
    [PTWebUtils requestRandomPlaylistWithCompletionHandler:^(id object) {
        NSDictionary *dict = object;
        NSArray <MoefmSong *> *playlist = dict[MoeCallbackDictSongKey];
        [[PTPlayerManager sharedPlayerManager] changeToPlayList:playlist andPlayType:MoeRandomPlay andSongIDs:nil];
    } errorHandler:^(id error) {
        NSLog(@"%@", error);
    }];
    sleep(3);
    sender.enabled = YES;
}

// 我的收藏按钮
- (IBAction)favouriteButtonAction:(UIButton *)sender {
    BOOL isLogin = [[NSUserDefaults standardUserDefaults] boolForKey:@"isLogin"];
    if (isLogin) {
        [self performSegueWithIdentifier:@"Favourite" sender:nil];
    }else{
        [SVProgressHUD showErrorWithStatus:@"请先登录OAuth授权"];
        [SVProgressHUD dismissWithDelay:2];
    }
}

// 刷新按钮
- (IBAction)refreshButtonAction:(UIButton *)sender {
    self.isRefreshAction = YES;
    if (sender.tag == WikiTypeRadio) {
        [self sendHotRadioListRequest];
    } else {
        [self sendHotAlbumListRequest];
    }
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
    [SVProgressHUD showWithStatus:@"查询中...请稍后..."];
    _wikiType = collectionView.tag;// 设置wikiType
    
    self.view.userInteractionEnabled = NO;
    MoefmWiki *radioWiki = [[MoefmWiki alloc] init];
    if (collectionView.tag == WikiTypeRadio) {
        radioWiki = self.hotRadioList[indexPath.item];
        [PTWebUtils requestRadioSongCountWithRadioId:radioWiki.wiki_id completionHandler:^(id object) {
            NSMutableDictionary *dict = object;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.view.userInteractionEnabled = YES;
                [SVProgressHUD dismiss];
                NSNumber *countNum = dict[MoeCallbackDictCountKey];
                NSUInteger count = countNum.integerValue;
                if (count != 0) {
                    [dict setObject:radioWiki forKey:@"radioWiki"];
                    [self performSegueWithIdentifier:@"HotRadioOrAlbumDetail" sender:dict];
//                    [dict setObject:@(collectionView.tag) forKey:@"WikiType"];// 将wikiType也放到字典中，传给播放列表界面
                } else {
                    [SVProgressHUD showInfoWithStatus:@"该电台暂无歌曲"];
                    [SVProgressHUD dismissWithDelay:1.5];
                }
                
            });
        } errorHandler:^(id error) {
            NSLog(@"%@", error);
        }];
    } else {
        radioWiki = self.hotAlbumList[indexPath.item];
        [PTWebUtils requestAlbumSongCountWithAlbumID:radioWiki.wiki_id completionHandler:^(id object) {
            NSMutableDictionary *dict = object;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.view.userInteractionEnabled = YES;
                [SVProgressHUD dismiss];
                NSNumber *upload = dict[@"isUpload"];
                BOOL isUpload = upload.integerValue;
                if (isUpload) {
                    [dict setObject:radioWiki forKey:@"radioWiki"];
                    [self performSegueWithIdentifier:@"HotRadioOrAlbumDetail" sender:dict];
                } else {
                    [SVProgressHUD showInfoWithStatus:@"该专辑暂无资源"];
                    [SVProgressHUD dismissWithDelay:1.5];
                }
            });
        } errorHandler:^(id error) {
            NSLog(@"%@", error);
        }];
    }
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
        WikiListViewController *oldHomeVC = [segue destinationViewController];
        UIButton *button = sender;
        oldHomeVC.wikiType = button.tag;
    } else if ([segue.identifier isEqualToString:@"UserInfo"]) {
//        MineViewController *mineVC = [segue destinationViewController];
//        mineVC.userInfo = self.userInfo;
    } else if ([segue.identifier isEqualToString:@"HotRadioOrAlbumDetail"]) {
        WikiPlayListViewController *wikiPlayListVC = [segue destinationViewController];
        wikiPlayListVC.wikiType = _wikiType;
        wikiPlayListVC.relationshipsDict = sender;
    }
}

@end
