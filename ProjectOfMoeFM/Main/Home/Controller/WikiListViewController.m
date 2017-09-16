//
//  WikiListViewController.m
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

#import "WikiListViewController.h"
#import "WikiPlayListViewController.h"
#import <SVProgressHUD.h>
#import <MJRefresh.h>

#import "WikiCollectionViewCell.h"
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

@interface WikiListViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *radioCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *radioCollectionViewFlowLayout;
@property (strong, nonatomic) NSMutableArray *allRadios;// 保存所有电台列表信息
@property (strong, nonatomic) NSMutableDictionary *radiosInformations;// 用于保存电台歌曲总数信息
@property (assign, nonatomic) NSUInteger radioCount;// wiki总数
//@property (strong, nonatomic) NSMutableArray *radiosRandomPlayList;

@property (assign, nonatomic) NSUInteger currentPage;
@property (assign, nonatomic) NSUInteger perpage;
@end

@implementation WikiListViewController

static NSString * const reuseIdentifier = @"radioCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initSubObjects];
    [self addCollectionViewRefresh];
    
}

// MJRefresh
- (void)addCollectionViewRefresh {
    __weak WikiListViewController *weakSelf = self;
    
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

#pragma mark - UI action and others

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

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.allRadios.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    WikiCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
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
                    [self performSegueWithIdentifier:@"WikiDetail" sender:dict];
//                    [dict setObject:@(self.wikiType) forKey:@"WikiType"];// 将wikiType也放到字典中，传给播放列表界面
                } else {
                    [SVProgressHUD showInfoWithStatus:@"该电台暂无歌曲"];
                    [SVProgressHUD dismissWithDelay:1.5];
                }
                
            });
        } errorHandler:^(id error) {
            NSLog(@"%@", error);
        }];
        
    } else {
        [PTWebUtils requestAlbumSongCountWithAlbumID:radioWiki.wiki_id completionHandler:^(id object) {
            NSMutableDictionary *dict = object;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.view.userInteractionEnabled = YES;
                [SVProgressHUD dismiss];
//                NSNumber *countNum = dict[MoeCallbackDictCountKey];
//                NSUInteger count = countNum.integerValue;
                NSNumber *upload = dict[@"isUpload"];
                BOOL isUpload = upload.integerValue;
                if (isUpload) {
                    [dict setObject:radioWiki forKey:@"radioWiki"];
                    [self performSegueWithIdentifier:@"WikiDetail" sender:dict];
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
    if ([segue.identifier isEqualToString:@"WikiDetail"]) {
        WikiPlayListViewController *wikiPlayListViewContoller = segue.destinationViewController;
        wikiPlayListViewContoller.relationshipsDict = sender;
        wikiPlayListViewContoller.wikiType = self.wikiType;
    }
}

- (void)dealloc {
    NSLog(@"WikiListView(old homeView)被销毁了");
}

@end
