//
//  RadioPlayListViewController.m
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/13.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#define kFavouriteKey @"fav"

#import "RadioPlayListViewController.h"
#import "RadioPlayListCell.h"
#import <MJRefresh.h>
#import <SVProgressHUD.h>

#import "RadioPlaySong.h"

#import "PTWebUtils.h"

#import "PTPlayerManager.h"

@interface RadioPlayListViewController ()<UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching>

@property (weak, nonatomic) IBOutlet UITableView *radioPlayListTableView;

@property (strong, nonatomic) NSMutableArray *radio_playlist;// 保存电台播放列表信息
@property (weak, nonatomic) IBOutlet UILabel *titeLabel;

@property (assign, nonatomic) NSUInteger currentPage;
@property (assign, nonatomic) NSUInteger perpage;
@end

@implementation RadioPlayListViewController

static NSString * const reuseIdentifier = @"radioPlayListCell";

- (NSMutableArray *)radio_playlist {
    if (!_radio_playlist) {
        _radio_playlist = [NSMutableArray array];
    }
    return _radio_playlist;
}

- (NSUInteger)currentPage {
    if (!_currentPage) {
        _currentPage = 1;
    }
    return _currentPage;
}

- (NSUInteger)perpage {
    if (!_perpage) {
        _perpage = 9;
    }
    return _perpage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:72.0/255 green:170.0/255 blue:245.0/255 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    [self addTableViewRefresh];
}

- (void)addTableViewRefresh {
//    __weak RadioPlayListViewController *weakSelf = self;
    // 下拉刷新
    self.radioPlayListTableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 加载数据
        self.currentPage = 1;
        if (self.isFavourite) {
            // 请求收藏列表信息
            [PTWebUtils requestRadioPlayListWithRadio_id:kFavouriteKey andPage:self.currentPage andPerpage:0 completionHandler:^(id object) {
                self.radio_playlist = object;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.radioPlayListTableView reloadData];
                    [self.radioPlayListTableView.mj_header endRefreshing];
                });
                
            } errorHandler:^(id error) {
                NSLog(@"%@", error);
            }];
        }else{
            // 请求电台播放列表信息
            [PTWebUtils requestRadioPlayListWithRadio_id:self.radioWiki.wiki_id andPage:self.currentPage andPerpage:0 completionHandler:^(id object) {
                self.radio_playlist = object;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.radioPlayListTableView reloadData];
                    [self.radioPlayListTableView.mj_header endRefreshing];
                });
                
            } errorHandler:^(id error) {
                NSLog(@"%@", error);
            }];
        }
    }];
    
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    self.radioPlayListTableView.mj_header.automaticallyChangeAlpha = YES;
    
    // 上拉刷新
    self.radioPlayListTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        // 加载数据
        self.currentPage++;
        
        if (self.isFavourite) {
            // 请求收藏列表信息
            
            [PTWebUtils requestRadioPlayListWithRadio_id:kFavouriteKey andPage:self.currentPage andPerpage:0 completionHandler:^(id object) {
                [self.radio_playlist addObjectsFromArray:object];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.radioPlayListTableView reloadData];
                    [self.radioPlayListTableView.mj_footer endRefreshing];
                });
                
            } errorHandler:^(id error) {
                NSLog(@"%@", error);
            }];
        }else{
            // 请求电台播放列表信息
            self.currentPage++;
            [PTWebUtils requestRadioPlayListWithRadio_id:self.radioWiki.wiki_id andPage:self.currentPage andPerpage:0 completionHandler:^(id object) {
                [self.radio_playlist addObjectsFromArray:object];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.radioPlayListTableView reloadData];
                    [self.radioPlayListTableView.mj_footer endRefreshing];
                });
                
            } errorHandler:^(id error) {
                NSLog(@"%@", error);
            }];
        }

    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    if (self.isFavourite) {
        self.titeLabel.text = @"我收藏的曲目";
        // 请求收藏曲目列表
        [PTWebUtils requestRadioPlayListWithRadio_id:kFavouriteKey andPage:self.currentPage andPerpage:0 completionHandler:^(id object) {
            self.radio_playlist = object;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.radioPlayListTableView reloadData];
            });
        } errorHandler:^(id error) {
            NSLog(@"%@", error);
        }];
    }else{
        self.titeLabel.text = self.radioWiki.wiki_title;
        // 请求电台播放列表信息
        [PTWebUtils requestRadioPlayListWithRadio_id:self.radioWiki.wiki_id andPage:self.currentPage andPerpage:0 completionHandler:^(id object) {
            self.radio_playlist = object;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.radioPlayListTableView reloadData];
            });
        } errorHandler:^(id error) {
            NSLog(@"%@", error);
        }];

    }
}
- (IBAction)playSingleSongAction:(UIButton *)sender {
    RadioPlayListCell *cell = (RadioPlayListCell *)sender.superview.superview;
    [[PTPlayerManager sharedAVPlayerManager] playSingleSong:cell.radioPlaySong];
}
- (IBAction)playAllSongsAction:(UIBarButtonItem *)sender {
    [[PTPlayerManager sharedAVPlayerManager] changeToPlayList:self.radio_playlist andRadioWikiID:self.radioWiki.wiki_id];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.radio_playlist.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RadioPlayListCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    RadioPlaySong *radioPlaySong = self.radio_playlist[indexPath.row];
    cell.radioPlaySong = radioPlaySong;
    
    return cell;
}
#pragma mark - UITableViewDataSourcePrefetching
- (void)tableView:(UITableView *)tableView prefetchRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    
}
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ([UIScreen mainScreen].bounds.size.height - 64 - 44) / 6;
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
