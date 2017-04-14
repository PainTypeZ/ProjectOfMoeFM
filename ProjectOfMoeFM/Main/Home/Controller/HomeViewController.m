//
//  HomeViewController.m
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/8.
//  Copyright © 2017年 彭平军. All rights reserved.
//


/* collectionViewConstants */
#define kMainScreenWidth [UIScreen mainScreen].bounds.size.width
#define kNumberOfItemsPerRow 2
#define kSectionSpacing 15.0
#define kItemSpacing 15.0
#define kCellViewHeight 30.0 // 记得与storyboard包含3个label的View高度保持一致

#import "HomeViewController.h"
#import "RadioPlayListViewController.h"
#import "PTMusicPlayerView.h"

#import "RadioCollectionViewCell.h"
#import "RadioWiki.h"
#import "RadioResponse.h"
#import "RadioRelationships.h"

#import "PTOAuthTool.h"
#import "PTWebUtils.h"

#import "MoefmAPIConst.h"

@interface HomeViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *radioCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *radioCollectionViewFlowLayout;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *loginButton;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) NSMutableArray *radio_wikis;// 保存电台列表信息
@property (strong, nonatomic) NSMutableDictionary *radio_informations;// 用于保存电台歌曲总数信息
@property (strong, nonatomic) NSMutableArray *radio_randomPlayList;

@end

@implementation HomeViewController

static NSString * const reuseIdentifier = @"radioCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:72.0/255 green:170.0/255 blue:245.0/255 alpha:1.0];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    // 设置背景图的毛玻璃效果
//    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//    UIVisualEffectView *visualEffect = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
//    [visualEffect setFrame:[UIScreen mainScreen].bounds];
//    [self.backgroundImageView addSubview:visualEffect];
  
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self checkOAuthState];
    if (self.radio_wikis.count == 0) {
        // 请求电台列表信息
        [PTWebUtils requestRadioListInfoWithCallback:^(id object) {
            self.radio_wikis = object;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.radioCollectionView reloadData];
            });
        }];
    }
}

- (NSMutableArray *)radio_wikis {
    if (!_radio_wikis) {
        _radio_wikis = [NSMutableArray array];
    }
    return _radio_wikis;
}

- (NSMutableDictionary *)radio_informations {
    if (!_radio_informations) {
        _radio_informations = [NSMutableDictionary dictionary];
    }
    return _radio_informations;
}

- (NSMutableArray *)radio_randomPlayList {
    if (!_radio_randomPlayList) {
        _radio_randomPlayList = [NSMutableArray array];
    }
    return _radio_randomPlayList;
}

#pragma mark - UI action and others
// 检查是否登录OAuth
- (void)checkOAuthState {
    BOOL isLogin = [[NSUserDefaults standardUserDefaults] boolForKey:@"isLogin"];
    if (isLogin) {
        NSLog(@"loginState:%d", isLogin);
        [self.loginButton setTitle:@"退出登录"];
    }
}

// 退出登录
- (void)oauthLoginOut {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"oauth_token"];
    [userDefaults removeObjectForKey:@"oauth_token_secret"];
    [userDefaults setBool:NO forKey:@"isLogin"];
    [userDefaults synchronize];
    [self.loginButton setTitle:@"登录"];
}

// 点击OAuth登录按钮事件
- (IBAction)oauthLogin:(UIBarButtonItem *)sender {
    BOOL isLogin = [[NSUserDefaults standardUserDefaults] boolForKey:@"isLogin"];
    if (isLogin) {
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

#pragma mark - UICollectionViewDataSourcePrefetching
- (void)collectionView:(UICollectionView *)collectionView prefetchItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    RadioWiki *radioWiki = self.radio_wikis[indexPath.item];
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

@end
