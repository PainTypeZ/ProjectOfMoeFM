//
//  HomeViewController.m
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/8.
//  Copyright © 2017年 彭平军. All rights reserved.
//



#define kTestRadioID @"11138"
/* collectionViewConstants */
#define kMainScreenWidth [UIScreen mainScreen].bounds.size.width
#define kNumberOfItemsPerRow 3
#define kSectionSpacing 10.0
#define kItemSpacing 15.0
#define kCellViewHeight 30.0 // 记得与storyboard包含3个label的View高度保持一致
#define kHeaderViewHeight 35.0 // 记得与storyboard的collectionheaderView保持一致

#import "HomeViewController.h"
#import "RadioPlayListViewController.h"
#import <SVProgressHUD.h>
#import <MJRefresh.h>

#import "RadioCollectionViewCell.h"
#import "RadioWiki.h"
#import "RadioResponse.h"
#import "RadioRelationships.h"

#import "PTOAuthTool.h"
#import "PTWebUtils.h"

#import "MoefmAPIConst.h"

#import "AppDelegate.h"
#import "PTPlayerManager.h"

@interface HomeViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *radioCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *radioCollectionViewFlowLayout;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *loginButton;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) NSMutableArray *radio_wikis;// 保存电台列表信息
@property (strong, nonatomic) NSMutableDictionary *radio_informations;// 用于保存电台歌曲总数信息
@property (strong, nonatomic) NSMutableArray *radio_randomPlayList;

@property (assign, nonatomic) NSUInteger currentPage;
@property (assign, nonatomic) NSUInteger perpage;
@end

@implementation HomeViewController

static NSString * const reuseIdentifier = @"radioCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:72.0/255 green:170.0/255 blue:245.0/255 alpha:1.0];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [app.window bringSubviewToFront:app.playerBottomView];
    [self initSubObjects];
    [self addCollectionViewRefresh];
    
    // 只有在程序启动时执行一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [SVProgressHUD showWithStatus:@"正在检查OAuth授权状态，请稍后"];
        // 检查OAuth授权是否任然有效
        [PTWebUtils requestUserInfoWithCompletionHandler:^(id object) {
            NSDictionary *userDict = [NSDictionary dictionaryWithDictionary:object];
            
            if ([userDict[@"isOAuth"] isEqualToString:@"NO"]) {
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isLogin"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                dispatch_async(dispatch_get_main_queue(), ^{
                    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    app.playerBottomView.favouriteButton.enabled = NO;
                    [self.loginButton setTitle:@"登录"];
                    [self sendRadioListRequest];
                    [self sendPlayListRequest];// 测试用
                });
                NSLog(@"OAuthToken已失效");
            }else{
                NSLog(@"%@,%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"oauth_token"], [[NSUserDefaults standardUserDefaults] objectForKey:@"oauth_token_secret"]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    app.playerBottomView.favouriteButton.enabled = YES;
                    // app.playerBottomView.dislikeButton.enabled = YES;// 未实现
                    [self.loginButton setTitle:@"退出登录"];
                    [self sendRadioListRequest];
                    [self sendPlayListRequest];// 测试用
                });
            }
            [SVProgressHUD dismiss];
        } errorHandler:^(id error) {
            NSLog(@"%@", error);
        }];
    });

    // 设置背景图的毛玻璃效果
//    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//    UIVisualEffectView *visualEffect = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
//    [visualEffect setFrame:[UIScreen mainScreen].bounds];
//    [self.backgroundImageView addSubview:visualEffect];
  
}

// MJRefresh
- (void)addCollectionViewRefresh {
    __weak HomeViewController *weakSelf = self;
    
    // 下拉刷新
    self.radioCollectionView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 更新数据
        self.currentPage = 1;
        // perpage=0时会发送默认值为20的请求
        [PTWebUtils requestRadioListInfoWithPagea:self.currentPage andPerPage:0 completionHandler:^(id object) {
            self.radio_wikis = object;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.radioCollectionView reloadData];
                // 结束刷新
                [weakSelf.radioCollectionView.mj_header endRefreshing];
            });
        } errorHandler:^(id error) {
            NSLog(@"%@", error);
        }];
    }];
    [self.radioCollectionView.mj_header beginRefreshing];
    
    // 上拉刷新
    self.radioCollectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        self.currentPage++;
        // 增加数据
        [PTWebUtils requestRadioListInfoWithPagea:self.currentPage andPerPage:0 completionHandler:^(id object) {
            [self.radio_wikis addObjectsFromArray:object];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.radioCollectionView reloadData];
                // 结束刷新
                [weakSelf.radioCollectionView.mj_footer endRefreshing];
            });
        } errorHandler:^(id error) {
            NSLog(@"%@", error);
        }];
    }];
    // 默认先隐藏footer
//    self.radioCollectionView.mj_footer.hidden = YES;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self checkOAuthState];
    if (self.radio_wikis.count == 0) {
        [self sendRadioListRequest];
    }
}

- (void)initSubObjects {
    self.currentPage = 1;
    self.perpage = 20;
    self.radio_wikis = [NSMutableArray array];
    self.radio_informations = [NSMutableDictionary dictionary];
    self.radio_randomPlayList = [NSMutableArray array];
}

#pragma mark - UI action and others
// 检查是否登录OAuth
- (void)checkOAuthState {
    BOOL isLogin = [[NSUserDefaults standardUserDefaults] boolForKey:@"isLogin"];
    NSLog(@"loginState:%@", isLogin?@"YES":@"NO");
    if (isLogin) {
        [self.loginButton setTitle:@"退出登录"];
        AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        app.playerBottomView.favouriteButton.enabled = YES;
        // app.playerBottomView.dislikeButton.enabled = YES;// 未实现
    }else{
        AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        app.playerBottomView.favouriteButton.enabled = NO;
        [self.loginButton setTitle:@"登录"];
    }
}

- (void)sendRadioListRequest {
    if (self.radio_wikis.count == 0) {
        // 请求电台列表信息
        [PTWebUtils requestRadioListInfoWithPagea:self.currentPage andPerPage:self.perpage completionHandler:^(id object) {
            self.radio_wikis = object;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.radioCollectionView reloadData];
            });
            
        } errorHandler:^(id error) {
            NSLog(@"%@", error);
        }];
    }
}

- (void)sendPlayListRequest {
    // 用单例构造方法初始化playerManager实例
    PTPlayerManager *playerManager = [PTPlayerManager sharedAVPlayerManager];
    // 启动时默认开始播放，测试用
    [PTWebUtils requestRadioPlayListWithRadio_id:kTestRadioID andPage:1 andPerpage:9 completionHandler:^(id object) {
        [playerManager changeToPlayList:object andRadioWikiID:kTestRadioID];
    } errorHandler:^(id error) {
        NSLog(@"%@", error);
    }];
}

// 退出登录
- (void)oauthLoginOut {
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    app.playerBottomView.userInteractionEnabled = NO;// 先关闭播放器底部视图的用户交互
    
    UIAlertController *alretController = [UIAlertController alertControllerWithTitle:@"退出登录" message:@"退出登录后将无法使用收藏功能，确定退出吗？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionConfirm = [UIAlertAction actionWithTitle:@"确定退出" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alretController dismissViewControllerAnimated:YES completion:nil];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults removeObjectForKey:@"oauth_token"];
        [userDefaults removeObjectForKey:@"oauth_token_secret"];
        [userDefaults setBool:NO forKey:@"isLogin"];
        [userDefaults synchronize];
        [self.loginButton setTitle:@"登录"];
        [[PTPlayerManager sharedAVPlayerManager] updateFavInfo];
        app.playerBottomView.favouriteButton.enabled = NO;
        //    app.playerBottomView.dislikeButton.enabled = NO;// 未实现
        app.playerBottomView.userInteractionEnabled = YES;// 重新开启用户交互
        
    }];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alretController dismissViewControllerAnimated:YES completion:nil];
        app.playerBottomView.userInteractionEnabled = YES;// 重新开启用户交互
    }];
    [alretController addAction:actionCancel];
    [alretController addAction:actionConfirm];
    [self presentViewController:alretController animated:YES completion:nil];
    
}
- (IBAction)playFavouriteAction:(UIButton *)sender {
    BOOL isLogin = [[NSUserDefaults standardUserDefaults] boolForKey:@"isLogin"];
    if (isLogin) {
        [PTWebUtils requestRadioPlayListWithRadio_id:@"fav" andPage:1 andPerpage:0 completionHandler:^(id object) {
            [[PTPlayerManager sharedAVPlayerManager] changeToPlayList:object andRadioWikiID:@"fav"];            
        } errorHandler:^(id error) {
            NSLog(@"%@", error);
        }];
        
    }else{
        [SVProgressHUD showErrorWithStatus:@"请先登录OAuth授权"];
    }

}
- (IBAction)browseFavouriteAction:(UIButton *)sender {
    BOOL isLogin = [[NSUserDefaults standardUserDefaults] boolForKey:@"isLogin"];
    if (isLogin) {
        [self performSegueWithIdentifier:@"pushRadioPlayListViewController" sender:@"favourite"];        
    }else{
        [SVProgressHUD showErrorWithStatus:@"请先登录OAuth授权"];
        
    }
}

// 点击OAuth登录按钮事件
- (IBAction)oauthLogin:(UIBarButtonItem *)sender {
//    BOOL isLogin = [[NSUserDefaults standardUserDefaults] boolForKey:@"isLogin"];
    if ([sender.title isEqualToString:@"退出登录"]) {
        [self oauthLoginOut];
    }else {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"OAuth" bundle:[NSBundle mainBundle]];
        UIApplication *app = [UIApplication sharedApplication];
        app.keyWindow.rootViewController = storyBoard.instantiateInitialViewController;
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.radio_wikis.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    RadioCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    RadioWiki *radioWiki = self.radio_wikis[indexPath.item];
    cell.radioWiki = radioWiki;
//    NSLog(@"%@", radioWiki.wiki_id);
   
    return cell;
};

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"RadioListHeaderView" forIndexPath:indexPath];
    return view;
}

#pragma mark - UICollectionViewDataSourcePrefetching
- (void)collectionView:(UICollectionView *)collectionView prefetchItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    RadioWiki *radioWiki = self.radio_wikis[indexPath.item];
    [self performSegueWithIdentifier:@"pushRadioPlayListViewController" sender:radioWiki];

}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(kMainScreenWidth, kHeaderViewHeight);
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat itemWidth = (kMainScreenWidth - kItemSpacing * (kNumberOfItemsPerRow + 1)) / kNumberOfItemsPerRow;
    CGFloat itemHeight = itemWidth + kCellViewHeight;
//    CGFloat itemHeight = itemWidth;
    return CGSizeMake(itemWidth, itemHeight);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return kSectionSpacing;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return kItemSpacing;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(kSectionSpacing, kItemSpacing, kSectionSpacing, kItemSpacing);
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"pushRadioPlayListViewController"]) {
        RadioPlayListViewController *radioPlayListViewContoller = segue.destinationViewController;
        // 注意不能用字符串判断，因为sender可能类型不是NSString
        if ([sender isEqual:@"favourite"]) {
            radioPlayListViewContoller.isFavourite = YES;
        }else{
            radioPlayListViewContoller.radioWiki = sender;
        }
    }
}

@end
