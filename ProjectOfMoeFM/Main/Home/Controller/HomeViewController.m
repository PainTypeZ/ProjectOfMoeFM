//
//  HomeViewController.m
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/8.
//  Copyright © 2017年 彭平军. All rights reserved.
//


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
#import "MoefmWiki.h"
#import "MoefmResponse.h"
#import "MoefmRelationships.h"

#import "PTOAuthTool.h"
#import "PTWebUtils.h"

#import "MoefmAPIConst.h"

#import "AppDelegate.h"
#import "PTPlayerManager.h"

typedef enum : NSUInteger {
    WikiTypeRadio,
    WikiTypeAlbum,
    WikiTypeFavourite,
} WikiType;

@interface HomeViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *radioCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *radioCollectionViewFlowLayout;
@property (strong, nonatomic) NSMutableArray *allRadios;// 保存所有电台列表信息
@property (strong, nonatomic) NSMutableDictionary *radiosInformations;// 用于保存电台歌曲总数信息
@property (assign, nonatomic) NSUInteger radioCount;// wiki总数
//@property (strong, nonatomic) NSMutableArray *radiosRandomPlayList;

@property (assign, nonatomic) NSUInteger currentPage;
@property (assign, nonatomic) NSUInteger perpage;
@end

@implementation HomeViewController

static NSString * const reuseIdentifier = @"radioCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.0/255 green:161.0/255 blue:209.0/255 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.hidden = NO;

    [self initSubObjects];
    [self addCollectionViewRefresh];
    
    // 只有在程序启动时执行一次
    //    [self checkOAuthStateWhenAlreadyLogin];
    
}

//- (void)checkOAuthStateWhenAlreadyLogin {
//    BOOL isLogin = [[NSUserDefaults standardUserDefaults] boolForKey:@"isLogin"];
//    if (isLogin) {
//        [SVProgressHUD showWithStatus:@"正在检查OAuth授权状态，请稍后"];
//        // 检查OAuth授权是否任然有效
//        [PTWebUtils requestUserInfoWithCompletionHandler:^(id object) {
//            NSDictionary *userDict = [NSDictionary dictionaryWithDictionary:object];
//
//            if ([userDict[@"isOAuth"] isEqualToString:@"NO"]) {
//                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isLogin"];
//                [[NSUserDefaults standardUserDefaults] synchronize];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
//                    app.playerBottomView.favouriteButton.enabled = NO;
//                    [self.loginButton setTitle:@"登录"];
//                    [self sendHotRadiosRequest];
////                    [self sendPlayListRequest];// 测试用
//                    // 请求电台数据
//                        if (self.allRadios.count == 0) {
//                            [self sendAllRadioListRequest];
//                        }
//                });
//                NSLog(@"OAuthToken已失效");
//            }else{
//                NSLog(@"%@,%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"oauth_token"], [[NSUserDefaults standardUserDefaults] objectForKey:@"oauth_token_secret"]);
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
//                    app.playerBottomView.favouriteButton.enabled = YES;
//                    // app.playerBottomView.dislikeButton.enabled = YES;// 未实现
//                    [self.loginButton setTitle:@"退出登录"];
//                    [self sendHotRadiosRequest];
////                    [self sendPlayListRequest];// 测试用
//                    // 请求电台数据
//
//                        if (self.allRadios.count == 0) {
//                            [self sendAllRadioListRequest];
//                        }
//                });
//            }
//            [SVProgressHUD dismiss];
//        } errorHandler:^(id error) {
//            NSLog(@"%@", error);
//        }];
//    }
//}

// MJRefresh
- (void)addCollectionViewRefresh {
    __weak HomeViewController *weakSelf = self;
    
    // 下拉刷新
    self.radioCollectionView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weakSelf.currentPage = 1;
        // perpage=0时会发送默认值为20的请求
        
        if (self.wikiType == WikiTypeRadio) {
            [PTWebUtils requestRadioListInfoWithPage:self.currentPage perpage:0 completionHandler:^(id object) {
                NSDictionary *dict = object;
                NSNumber *count = dict[MoeCallbackDictCountKey];
                weakSelf.allRadios = dict[MoeCallbackDictRadioKey];
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
        } else {
            [PTWebUtils requestAlbumListInfoWithPage:self.currentPage perpage:0 completionHandler:^(id object) {
                NSDictionary *dict = object;
                NSNumber *count = dict[MoeCallbackDictCountKey];
                weakSelf.allRadios = dict[MoeCallbackDictAlbumKey];
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
        if (weakSelf.allRadios.count >= weakSelf.radioCount) {
            [SVProgressHUD showWithStatus:@"已经是最后一页了"];
            [SVProgressHUD dismissWithDelay:1.5];
            // 结束刷新
            [weakSelf.radioCollectionView.mj_footer endRefreshing];
            return;
        }
        weakSelf.currentPage++;
        // 增加数据
        if (self.wikiType == WikiTypeRadio) {
            [PTWebUtils requestRadioListInfoWithPage:weakSelf.currentPage perpage:0 completionHandler:^(id object) {
                NSDictionary *dict = object;
                NSNumber *count = dict[MoeCallbackDictCountKey];
                NSArray *moreRadiosArray = dict[MoeCallbackDictRadioKey];
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
            
        } else {
            [PTWebUtils requestAlbumListInfoWithPage:weakSelf.currentPage perpage:0 completionHandler:^(id object) {
                NSDictionary *dict = object;
                NSNumber *count = dict[MoeCallbackDictCountKey];
                NSArray *moreRadiosArray = dict[MoeCallbackDictAlbumKey];
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
    //    [self checkOAuthState];
    if (self.wikiType == WikiTypeRadio) {
        self.title = @"电台列表";
    } else {
        self.title = @"专辑列表";
    }
}

- (void)initSubObjects {
    self.currentPage = 1;
    self.perpage = 20;
    self.allRadios = [NSMutableArray array];
    self.radiosInformations = [NSMutableDictionary dictionary];
    //    self.radiosRandomPlayList = [NSMutableArray array];
}

//- (void)sendAllRadioListRequest {
//    if (self.allRadios.count == 0) {
//        // 请求电台列表信息
//        [SVProgressHUD showWithStatus:@"加载数据中，请稍后"];
//        [PTWebUtils requestRadioListInfoWithPage:self.currentPage perpage:self.perpage completionHandler:^(id object) {
//            NSDictionary *dict = object;
//            NSNumber *count = dict[MoeCallbackDictCountKey];
//            self.allRadios = dict[MoeCallbackDictRadioKey];
//            self.radioCount = count.integerValue;
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.radioCollectionView reloadData];
//                [SVProgressHUD dismiss];
//            });
//
//        } errorHandler:^(id error) {
//            NSLog(@"%@", error);
//        }];
//    }
//}

//- (void)sendHotRadiosRequest {
//    if (self.hotRadios.count == 0) {
//        [SVProgressHUD showWithStatus:@"加载数据中，请稍后"];
//        [PTWebUtils requestHotRadiosWithCompletionHandler:^(id object) {
//            NSDictionary *dict = object;
//            if (dict[MoeCallbackDictRadioKey]) {
//                self.hotRadios = dict[MoeCallbackDictRadioKey];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.radioCollectionView reloadData];
//                    [SVProgressHUD dismiss];
//                });
//            } else {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [SVProgressHUD showInfoWithStatus:@"暂无热门电台信息"];
//                    [SVProgressHUD dismissWithDelay:1.5];
//                    [self.radioCollectionView reloadData];
//                });
//                NSLog(@"热门电台获取失败");
//            }
//        } errorHandler:^(id error) {
//            NSLog(@"%@", error);
//        }];
//    }
//}

#pragma mark - UI action and others
// 检查是否登录OAuth
//- (void)checkOAuthState {
//    BOOL isLogin = [[NSUserDefaults standardUserDefaults] boolForKey:@"isLogin"];
//    NSLog(@"loginState:%@", isLogin?@"YES":@"NO");
//    if (isLogin) {
//        [self.loginButton setTitle:@"退出登录"];
//        AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
//        app.playerBottomView.favouriteButton.enabled = YES;
//
//    }else{
//        AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
//        app.playerBottomView.favouriteButton.enabled = NO;
//        [self.loginButton setTitle:@"登录"];
//    }
//}

// 退出登录
//- (void)oauthLoginOut {
//    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
//
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"退出登录" message:@"退出登录后将无法使用收藏功能，确定退出吗？" preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *actionConfirm = [UIAlertAction actionWithTitle:@"确定退出" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//        [alertController dismissViewControllerAnimated:YES completion:nil];
//        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//        [userDefaults removeObjectForKey:@"oauth_token"];
//        [userDefaults removeObjectForKey:@"oauth_token_secret"];
//        [userDefaults setBool:NO forKey:@"isLogin"];
//        [userDefaults synchronize];
//        [self.loginButton setTitle:@"登录"];
////        [[PTPlayerManager sharedPlayerManager] updateFavInfo];
//        app.playerBottomView.favouriteButton.enabled = NO;
//    }];
//    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
//    [alertController addAction:actionCancel];
//    [alertController addAction:actionConfirm];
//    [self presentViewController:alertController animated:YES completion:nil];
//
//}

//- (IBAction)radiosSegmentedAction:(UISegmentedControl *)sender {
//    if (sender.selectedSegmentIndex == 0) {
//        if (!self.hotRadios || self.hotRadios.count == 0) {
//            [self sendHotRadiosRequest];
//        }else{
//            [self.radioCollectionView reloadData];
//        }
//    }else{
//        if (self.allRadios.count == 0) {
//            [self sendAllRadioListRequest];
//        }else{
//            [self.radioCollectionView reloadData];
//        }
//
//    }
//}

- (IBAction)randomPlayAction:(UIButton *)sender {
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
//- (IBAction)oauthLogin:(UIBarButtonItem *)sender {
//
//    if ([sender.title isEqualToString:@"退出登录"]) {
//        [self oauthLoginOut];
//    }else{
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"登录或注册" message:@"已有账号请选择登录，无账号请选择注册,取消则返回主页" preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *actionLogin = [UIAlertAction actionWithTitle:@"登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
////            [alertController dismissViewControllerAnimated:YES completion:nil];
//            [self.tabBarController performSegueWithIdentifier:@"OAuth" sender:nil];
//        }];
//        UIAlertAction *actionRegister = [UIAlertAction actionWithTitle:@"注册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
////            [alertController dismissViewControllerAnimated:YES completion:nil];
//            [self.tabBarController performSegueWithIdentifier:@"Register" sender:nil];
//        }];
//        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
//        [alertController addAction:actionLogin];
//        [alertController addAction:actionRegister];
//        [alertController addAction:actionCancel];
//        [self presentViewController:alertController animated:YES completion:nil];
//    }
//}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.allRadios.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    RadioCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    MoefmWiki *radioWiki = [[MoefmWiki alloc] init];
    radioWiki = self.allRadios[indexPath.item];
    
    cell.radioWiki = radioWiki;
    
    return cell;
};


#pragma mark - UICollectionViewDataSourcePrefetching
- (void)collectionView:(UICollectionView *)collectionView prefetchItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.view.userInteractionEnabled = NO;
    MoefmWiki *radioWiki = [[MoefmWiki alloc] init];
    radioWiki = self.allRadios[indexPath.item];
    
    [SVProgressHUD showWithStatus:@"查询中...请稍后..."];
    if (self.wikiType == WikiTypeRadio) {
        [PTWebUtils requestRadioSongCountWithRadioId:radioWiki.wiki_id completionHandler:^(id object) {
            NSMutableDictionary *dict = object;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.view.userInteractionEnabled = YES;
                [SVProgressHUD dismiss];
                NSNumber *countNum = dict[MoeCallbackDictCountKey];
                NSUInteger count = countNum.integerValue;
                if (count != 0) {
                    [dict setObject:radioWiki forKey:@"radioWiki"];
                    [self performSegueWithIdentifier:@"RadioDetail" sender:dict];
                    [dict setObject:@(self.wikiType) forKey:@"WikiType"];// 将wikiType也放到字典中，传给播放列表界面
                } else {
                    [SVProgressHUD showInfoWithStatus:@"该电台暂无歌曲"];
                    [SVProgressHUD dismissWithDelay:1.5];
                }
                
            });
        } errorHandler:^(id error) {
            NSLog(@"%@", error);
        }];
        
    } else {
//        [PTWebUtils requestAlbumSongCountWithAlbumID:radioWiki.wiki_id completionHandler:^(id object) {
//            NSMutableDictionary *dict = object;
//            dispatch_async(dispatch_get_main_queue(), ^{
//                self.view.userInteractionEnabled = YES;
//                [SVProgressHUD dismiss];
////                NSNumber *countNum = dict[MoeCallbackDictCountKey];
////                NSUInteger count = countNum.integerValue;
//                NSNumber *upload = dict[@"isUpload"];
//                BOOL isUpload = upload.integerValue;
//                if (isUpload) {
//                    [dict setObject:radioWiki forKey:@"radioWiki"];
//                    [self performSegueWithIdentifier:@"RadioDetail" sender:dict];
//                } else {
//                    [SVProgressHUD showInfoWithStatus:@"该专辑暂无资源"];
//                    [SVProgressHUD dismissWithDelay:1.5];
//                }
//            });
//        } errorHandler:^(id error) {
//            NSLog(@"%@", error);
//        }];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat itemWidth = (kMainScreenWidth - kItemSpacing * (kNumberOfItemsPerRow + 1) - 16) / kNumberOfItemsPerRow;
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
    if ([segue.identifier isEqualToString:@"RadioDetail"]) {
        RadioPlayListViewController *radioPlayListViewContoller = segue.destinationViewController;
        radioPlayListViewContoller.relationshipsDict = sender;
        radioPlayListViewContoller.wikiType = self.wikiType;
    }
}

- (void)dealloc {
    NSLog(@"WikiListView(old homeView)被销毁了");
}

@end
