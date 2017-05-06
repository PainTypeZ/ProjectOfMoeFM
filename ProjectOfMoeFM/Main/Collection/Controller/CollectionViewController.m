//
//  CollectionViewController.m
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/8.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import "CollectionViewController.h"
#import "PTWebUtils.h"
#import "MoefmAPIConst.h"
#import <MJRefresh.h>
#import "CollectionSongsCell.h"
#import <SVProgressHUD.h>
#import "PTPlayerManager.h"

@interface CollectionViewController ()<UITableViewDataSource, UITableViewDataSourcePrefetching, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *collectionTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *playAllSongsItem;

@property (strong, nonatomic) NSMutableArray <RadioPlaySong *> *radioPlaylist;// 保存电台播放列表信息
@property (copy, nonatomic) NSString *songID;// 保存songID拼接的字符串，用于请求播放列表信息
@property (assign, nonatomic) NSUInteger songCount;// 目前只有请求favsongid的接口有返回歌曲总数这个功能
@property (assign, nonatomic) NSUInteger currentPage;
@property (assign, nonatomic) NSUInteger perpage;

@end

@implementation CollectionViewController

static NSString * const reuseIdentifier = @"collectionSongsCell";

- (NSMutableArray *)radioPlaylist {
    if (!_radioPlaylist) {
        _radioPlaylist = [NSMutableArray array];
    }
    return _radioPlaylist;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:72.0/255 green:170.0/255 blue:245.0/255 alpha:1.0];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    self.currentPage = 1;
    self.perpage = 9;
    [self addTableViewRefresh];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    if (self.playAllSongsItem.enabled == NO) {
        if (self.radioPlaylist.count == 0) {
            [SVProgressHUD showWithStatus:@"加载数据中，请稍后"];
            [PTWebUtils requestFavSongListWithPage:self.currentPage andPerPage:self.perpage completionHandler:^(id object) {
                NSDictionary *dict = object;
                self.songID = dict[@"songID"];
                NSNumber *count = dict[@"count"];
                self.songCount = count.integerValue;
                [PTWebUtils requestRadioPlayListWithRadio_id:self.songID andPage:self.currentPage andPerpage:self.perpage completionHandler:^(id object) {
                    NSDictionary *dict = object;
                    self.radioPlaylist = dict[@"songs"];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.collectionTableView reloadData];
                        self.playAllSongsItem.enabled = YES;
                        [SVProgressHUD dismiss];
                    });
                } errorHandler:^(id error) {
                    NSLog(@"%@", error);
                }];
                
            } errorHandler:^(id error) {
                NSLog(@"%@", error);
            }];            
        }
    }
}

// MJRefresh
- (void)addTableViewRefresh {
        __weak CollectionViewController *weakSelf = self;
    // 下拉刷新
    self.collectionTableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 加载数据
        weakSelf.currentPage = 1;
        // 请求收藏歌曲顺序播放列表信息
        [PTWebUtils requestFavSongListWithPage:weakSelf.currentPage andPerPage:weakSelf.perpage completionHandler:^(id object) {
            NSDictionary *dict = object;
            weakSelf.songID = dict[@"songID"];
            [PTWebUtils requestRadioPlayListWithRadio_id:weakSelf.songID andPage:0 andPerpage:0 completionHandler:^(id object) {
                NSDictionary *dict = object;
                weakSelf.radioPlaylist = dict[@"songs"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.collectionTableView reloadData];
                    [weakSelf.collectionTableView.mj_header endRefreshing];
                });
            } errorHandler:^(id error) {
                [weakSelf.collectionTableView.mj_header endRefreshing];
                NSLog(@"%@", error);
            }];
            
        } errorHandler:^(id error) {
            [weakSelf.collectionTableView.mj_header endRefreshing];
            NSLog(@"%@", error);
        }];
    }];
    
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    self.collectionTableView.mj_header.automaticallyChangeAlpha = YES;
    
    // 上拉刷新
    self.collectionTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        if (weakSelf.radioPlaylist.count >= weakSelf.songCount) {
            [SVProgressHUD showInfoWithStatus:@"已经是最后一页了"];
            [SVProgressHUD dismissWithDelay:1.5];
            // 结束刷新
            [weakSelf.collectionTableView.mj_footer endRefreshing];
            return;
        }
        // 加载数据
        weakSelf.currentPage++;
        // 请求电台播放列表信息
        [PTWebUtils requestFavSongListWithPage:weakSelf.currentPage andPerPage:weakSelf.perpage completionHandler:^(id object) {
            NSDictionary *dict = object;
            weakSelf.songID = dict[@"songID"];
            [PTWebUtils requestRadioPlayListWithRadio_id:weakSelf.songID andPage:weakSelf.currentPage andPerpage:weakSelf.perpage completionHandler:^(id object) {
                NSDictionary *dict = object;
                [weakSelf.radioPlaylist addObjectsFromArray:dict[@"songs"]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.collectionTableView reloadData];
                    // 结束刷新
                    [weakSelf.collectionTableView.mj_footer endRefreshing];
                });
            } errorHandler:^(id error) {
                // 结束刷新
                [weakSelf.collectionTableView.mj_footer endRefreshing];
                NSLog(@"%@", error);
            }];
            
        } errorHandler:^(id error) {
            // 结束刷新
            [weakSelf.collectionTableView.mj_footer endRefreshing];
            NSLog(@"%@", error);
        }];
    }];
}


#pragma mark - actions
- (IBAction)playSingleFavouriteSongAction:(UIButton *)sender {
    CollectionSongsCell *cell = (CollectionSongsCell *)sender.superview.superview;
    [[PTPlayerManager sharedPlayerManager] playSingleSong:cell.radioPlaySong andRadioID:@"ordered_fav"];
}

- (IBAction)playAllSongsAction:(UIBarButtonItem *)sender {
    [[PTPlayerManager sharedPlayerManager] changeToPlayList:self.radioPlaylist andRadioWikiID:@"ordered_fav"];// 需要在manager添加处理顺序播放的逻辑
    sender.enabled = NO;
    sleep(3);
    sender.enabled = YES;
}

- (IBAction)backToHomeAction:(UIBarButtonItem *)sender {
    self.tabBarController.selectedIndex = 0;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;// 以后会变
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.radioPlaylist.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CollectionSongsCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    RadioPlaySong *radioPlaySong = self.radioPlaylist[indexPath.row];

    cell.radioPlaySong = radioPlaySong;
    
    return cell;
}

#pragma mark - UITableViewDataSourcePrefetching
- (void)tableView:(UITableView *)tableView prefetchRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 暂时未实现歌曲详情
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ([UIScreen mainScreen].bounds.size.height - 64 - 44) / 6;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    view.backgroundColor = [UIColor colorWithRed:72.0/255 green:170.0/255 blue:245.0/255 alpha:1.0];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, view.bounds.size.width, view.bounds.size.height)];
    label.text = @"我收藏的歌曲";
    label.textColor = [UIColor whiteColor];
    [view addSubview:label];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section  {
    return 30;
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
