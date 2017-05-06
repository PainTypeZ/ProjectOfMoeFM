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
//#define kHeaderViewHeight 35.0 // 记得与storyboard的collectionheaderView保持一致

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
@property (weak, nonatomic) IBOutlet UISegmentedControl *radiosSegmentedControl;
@property (strong, nonatomic) NSMutableArray *allRadios;// 保存所有电台列表信息
@property (strong, nonatomic) NSMutableArray *hotRadios;// 保存热门电台列表信息
@property (strong, nonatomic) NSMutableDictionary *radiosInformations;// 用于保存电台歌曲总数信息
@property (assign, nonatomic) NSUInteger radioCount;// 电台总数，热门电台不用考虑边界，因为只有五个结果
@property (strong, nonatomic) NSMutableArray *radiosRandomPlayList;

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
    [self checkOAuthStateWhenAlreadyLogin];
    
}

- (void)checkOAuthStateWhenAlreadyLogin {
    BOOL isLogin = [[NSUserDefaults standardUserDefaults] boolForKey:@"isLogin"];
    if (isLogin) {
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
                    [self sendHotRadiosRequest];
//                    [self sendPlayListRequest];// 测试用
                    // 请求电台数据
                    if (self.radiosSegmentedControl.selectedSegmentIndex == 0) {
                        if (self.hotRadios.count == 0) {
                            [self sendHotRadiosRequest];
                        }
                    }else{
                        if (self.allRadios.count == 0) {
                            [self sendAllRadioListRequest];
                        }
                    }
                });
                NSLog(@"OAuthToken已失效");
            }else{
                NSLog(@"%@,%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"oauth_token"], [[NSUserDefaults standardUserDefaults] objectForKey:@"oauth_token_secret"]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    app.playerBottomView.favouriteButton.enabled = YES;
                    // app.playerBottomView.dislikeButton.enabled = YES;// 未实现
                    [self.loginButton setTitle:@"退出登录"];
                    [self sendHotRadiosRequest];
//                    [self sendPlayListRequest];// 测试用
                    // 请求电台数据
                    if (self.radiosSegmentedControl.selectedSegmentIndex == 0) {
                        if (self.hotRadios.count == 0) {
                            [self sendHotRadiosRequest];
                        }
                    }else{
                        if (self.allRadios.count == 0) {
                            [self sendAllRadioListRequest];
                        }
                    }
                });
            }
            [SVProgressHUD dismiss];
        } errorHandler:^(id error) {
            NSLog(@"%@", error);
        }];
    }
}

// MJRefresh
- (void)addCollectionViewRefresh {
    __weak HomeViewController *weakSelf = self;
    
    // 下拉刷新
    self.radioCollectionView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 更新数据

        if (weakSelf.radiosSegmentedControl.selectedSegmentIndex == 0) {
            [PTWebUtils requestHotRadiosWithCompletionHandler:^(id object) {
                weakSelf.hotRadios = object;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.radioCollectionView reloadData];
                    [weakSelf.radioCollectionView.mj_header endRefreshing];
                });
            } errorHandler:^(id error) {
                [weakSelf.radioCollectionView.mj_header endRefreshing];
                NSLog(@"%@", error);
            }];
        }else{
            weakSelf.currentPage = 1;
            // perpage=0时会发送默认值为20的请求
            [PTWebUtils requestRadioListInfoWithPage:self.currentPage andPerPage:0 completionHandler:^(id object) {
                NSDictionary *dict = object;
                NSNumber *count = dict[@"count"];
                weakSelf.allRadios = dict[@"radios"];
                weakSelf.radioCount = count.integerValue;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.radioCollectionView reloadData];
                    // 结束刷新
                    [weakSelf.radioCollectionView.mj_header endRefreshing];
                });
            } errorHandler:^(id error) {
                // 结束刷新
                [weakSelf.radioCollectionView.mj_header endRefreshing];
                NSLog(@"%@", error);
                
            }];

        }
    }];
    [self.radioCollectionView.mj_header beginRefreshing];
    
    // 上拉刷新
    self.radioCollectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        if (weakSelf.radiosSegmentedControl.selectedSegmentIndex == 0) {
            [SVProgressHUD showInfoWithStatus:@"没有更多的结果了"];
            [SVProgressHUD dismissWithDelay:1.5];
            // 结束刷新
            [weakSelf.radioCollectionView.mj_footer endRefreshing];
        }else{
            if (weakSelf.allRadios.count >= weakSelf.radioCount) {
                [SVProgressHUD showWithStatus:@"已经是最后一页了"];
                [SVProgressHUD dismissWithDelay:1.5];
                // 结束刷新
                [weakSelf.radioCollectionView.mj_footer endRefreshing];
                return;
            }
            weakSelf.currentPage++;
            // 增加数据
            [PTWebUtils requestRadioListInfoWithPage:weakSelf.currentPage andPerPage:0 completionHandler:^(id object) {
                NSDictionary *dict = object;
                NSNumber *count = dict[@"count"];
                NSArray *moreRadiosArray = dict[@"radios"];
                weakSelf.radioCount = count.integerValue;
                [weakSelf.allRadios addObjectsFromArray:moreRadiosArray];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.radioCollectionView reloadData];
                    // 结束刷新
                    [weakSelf.radioCollectionView.mj_footer endRefreshing];
                });
            } errorHandler:^(id error) {
                NSLog(@"%@", error);
                // 结束刷新
                [weakSelf.radioCollectionView.mj_footer endRefreshing];
            }];
        }
    }];
    // 默认先隐藏footer
//    self.radioCollectionView.mj_footer.hidden = YES;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self checkOAuthState];
}

- (void)initSubObjects {
    self.currentPage = 1;
    self.perpage = 20;
    self.hotRadios = [NSMutableArray array];
    self.allRadios = [NSMutableArray array];
    self.radiosInformations = [NSMutableDictionary dictionary];
    self.radiosRandomPlayList = [NSMutableArray array];
}

- (void)sendAllRadioListRequest {
    if (self.allRadios.count == 0) {
        // 请求电台列表信息
        [SVProgressHUD showWithStatus:@"加载数据中，请稍后"];
        [PTWebUtils requestRadioListInfoWithPage:self.currentPage andPerPage:self.perpage completionHandler:^(id object) {
            NSDictionary *dict = object;
            NSNumber *count = dict[@"count"];
            self.allRadios = dict[@"radios"];
            self.radioCount = count.integerValue;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.radioCollectionView reloadData];
                [SVProgressHUD dismiss];
            });
            
        } errorHandler:^(id error) {
            NSLog(@"%@", error);
        }];
    }
}

- (void)sendHotRadiosRequest {
    if (self.hotRadios.count == 0) {
        [PTWebUtils requestHotRadiosWithCompletionHandler:^(id object) {
            self.hotRadios = object;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.radioCollectionView reloadData];
            });
        } errorHandler:^(id error) {
            NSLog(@"%@", error);
        }];
    }
}

// 测试用
- (void)sendPlayListRequest {
    // 用单例构造方法初始化playerManager实例
    PTPlayerManager *playerManager = [PTPlayerManager sharedPlayerManager];
    // 启动时默认开始播放，测试用
    [PTWebUtils requestRadioPlayListWithRadio_id:kTestRadioID andPage:1 andPerpage:9 completionHandler:^(id object) {
        [playerManager changeToPlayList:object andRadioWikiID:kTestRadioID];
    } errorHandler:^(id error) {
        NSLog(@"%@", error);
    }];
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

    }else{
        AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        app.playerBottomView.favouriteButton.enabled = NO;
        [self.loginButton setTitle:@"登录"];
    }
}

// 退出登录
- (void)oauthLoginOut {
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    UIAlertController *alretController = [UIAlertController alertControllerWithTitle:@"退出登录" message:@"退出登录后将无法使用收藏功能，确定退出吗？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionConfirm = [UIAlertAction actionWithTitle:@"确定退出" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alretController dismissViewControllerAnimated:YES completion:nil];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults removeObjectForKey:@"oauth_token"];
        [userDefaults removeObjectForKey:@"oauth_token_secret"];
        [userDefaults setBool:NO forKey:@"isLogin"];
        [userDefaults synchronize];
        [self.loginButton setTitle:@"登录"];
//        [[PTPlayerManager sharedPlayerManager] updateFavInfo];
        app.playerBottomView.favouriteButton.enabled = NO;
    }];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alretController dismissViewControllerAnimated:YES completion:nil];
    }];
    [alretController addAction:actionCancel];
    [alretController addAction:actionConfirm];
    [self presentViewController:alretController animated:YES completion:nil];
    
}

- (IBAction)radiosSegmentedAction:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        if (self.hotRadios.count == 0) {
            [self sendHotRadiosRequest];
        }else{
            [self.radioCollectionView reloadData];
        }
    }else{
        if (self.allRadios.count == 0) {
            [self sendAllRadioListRequest];
        }else{
            [self.radioCollectionView reloadData];
        }
        
    }
}

- (IBAction)randomPlayAction:(UIButton *)sender {
    [PTWebUtils requestRadioPlayListWithRadio_id:@"random" andPage:0 andPerpage:0 completionHandler:^(id object) {
        NSDictionary *dict = object;
        [[PTPlayerManager sharedPlayerManager] changeToPlayList:dict[@"songs"] andRadioWikiID:@"random"];
    } errorHandler:^(id error) {
        NSLog(@"%@", error);
    }];
}

- (IBAction)myFavouriteAction:(UIButton *)sender {
    BOOL isLogin = [[NSUserDefaults standardUserDefaults] boolForKey:@"isLogin"];
    if (isLogin) {
        self.tabBarController.selectedIndex = 1;// 要改成枚举
    }else{
        [SVProgressHUD showErrorWithStatus:@"请先登录OAuth授权"];
        [SVProgressHUD dismissWithDelay:2];
    }
}

- (IBAction)myInformationAction:(UIButton *)sender {
    BOOL isLogin = [[NSUserDefaults standardUserDefaults] boolForKey:@"isLogin"];
    if (isLogin) {
        self.tabBarController.selectedIndex = 2;// 要改成枚举
    }else{
        [SVProgressHUD showErrorWithStatus:@"请先登录OAuth授权"];
        [SVProgressHUD dismissWithDelay:2];
    }
}

// 点击OAuth登录按钮事件
- (IBAction)oauthLogin:(UIBarButtonItem *)sender {

    if ([sender.title isEqualToString:@"退出登录"]) {
        [self oauthLoginOut];
    }else {
        [self.tabBarController performSegueWithIdentifier:@"OAuth" sender:nil];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.radiosSegmentedControl.selectedSegmentIndex == 0) {
        return self.hotRadios.count;
    }else{
        return self.allRadios.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    RadioCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    RadioWiki *radioWiki = [[RadioWiki alloc] init];
    if (self.radiosSegmentedControl.selectedSegmentIndex == 0) {
        radioWiki = self.hotRadios[indexPath.item];
    }else{
        radioWiki = self.allRadios[indexPath.item];
    }
    cell.radioWiki = radioWiki;
   
    return cell;
};


#pragma mark - UICollectionViewDataSourcePrefetching
- (void)collectionView:(UICollectionView *)collectionView prefetchItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    RadioWiki *radioWiki = [[RadioWiki alloc] init];
    if (self.radiosSegmentedControl.selectedSegmentIndex == 0) {
        radioWiki = self.hotRadios[indexPath.item];
    }else{
        radioWiki = self.allRadios[indexPath.item];
    }
    [self performSegueWithIdentifier:@"pushRadioPlayListViewController" sender:radioWiki];

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
        radioPlayListViewContoller.radioWiki = sender;
    }
}

- (void)dealloc {
    NSLog(@"home被销毁了");
}

@end
