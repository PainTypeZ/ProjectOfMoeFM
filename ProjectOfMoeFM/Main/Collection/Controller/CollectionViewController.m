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
#import "UIControl+PTFixMultiClick.h"

@interface CollectionViewController ()<UITableViewDataSource, UITableViewDataSourcePrefetching, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *collectionTableView;
@property (weak, nonatomic) IBOutlet UIButton *randomPlayAllButton;
@property (weak, nonatomic) IBOutlet UIButton *playCurrentListButton;

@property (strong, nonatomic) NSMutableArray <MoefmSong *> *radioPlaylist;// 保存电台播放列表信息
@property (strong, nonatomic) NSArray *songIDs;// 保存songID的数组，用于请求播放列表信息
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
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.0/255 green:161.0/255 blue:209.0/255 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.hidden = NO;
    
    self.randomPlayAllButton.pt_acceptEventInterval = 3;
    self.playCurrentListButton.pt_acceptEventInterval = 3;
    
    self.currentPage = 1;
    self.perpage = 9;
    [self addTableViewRefresh];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    if (self.radioPlaylist.count == 0) {
        [SVProgressHUD showWithStatus:@"加载数据中，请稍后"];
        [PTWebUtils requestFavSongListWithPage:self.currentPage perpage:self.perpage completionHandler:^(id object) {
            NSDictionary *dict = object;
            self.songIDs = dict[MoeCallbackDictSongIDKey];
            NSNumber *count = dict[MoeCallbackDictCountKey];
            self.songCount = count.integerValue;
            [PTWebUtils requestPlaylistWithSongIDs:self.songIDs completionHandler:^(id object) {
                NSDictionary *dict = object;
                self.radioPlaylist = dict[MoeCallbackDictSongKey];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.collectionTableView reloadData];
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

// MJRefresh
- (void)addTableViewRefresh {
        __weak CollectionViewController *weakSelf = self;
    // 下拉刷新
    self.collectionTableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 加载数据
        weakSelf.currentPage = 1;
        // 请求收藏歌曲顺序播放列表信息
        [PTWebUtils requestFavSongListWithPage:weakSelf.currentPage perpage:weakSelf.perpage completionHandler:^(id object) {
            NSDictionary *dict = object;
            weakSelf.songIDs = dict[MoeCallbackDictSongIDKey];
            NSNumber *count = dict[MoeCallbackDictCountKey];
            weakSelf.songCount = count.integerValue;
            [PTWebUtils requestPlaylistWithSongIDs:weakSelf.songIDs completionHandler:^(id object) {
                NSDictionary *dict = object;
                weakSelf.radioPlaylist = dict[MoeCallbackDictSongKey];
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
        [PTWebUtils requestFavSongListWithPage:weakSelf.currentPage perpage:weakSelf.perpage completionHandler:^(id object) {
            NSDictionary *dict = object;
            weakSelf.songIDs = dict[MoeCallbackDictSongIDKey];
            [PTWebUtils requestPlaylistWithSongIDs:weakSelf.songIDs completionHandler:^(id object) {
                NSDictionary *dict = object;
                [weakSelf.radioPlaylist addObjectsFromArray:dict[MoeCallbackDictSongKey]];
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
    if (self.songCount == 0) {
        [SVProgressHUD showInfoWithStatus:@"还没有收藏歌曲"];
        [SVProgressHUD dismissWithDelay:1.5];
        return;
    }
    CollectionSongsCell *cell = (CollectionSongsCell *)sender.superview.superview;
    [[PTPlayerManager sharedPlayerManager] changeToPlayList:@[cell.radioPlaySong] andPlayType:MoeSingleSongPlay andSongIDs:nil];
}
- (IBAction)randomPlayAllAction:(UIButton *)sender {
    if (self.songCount == 0) {
        [SVProgressHUD showInfoWithStatus:@"还没有收藏歌曲"];
        [SVProgressHUD dismissWithDelay:1.5];
        return;
    }
    [PTWebUtils requestFavRandomPlaylistWithCompletionHandler:^(id object) {
        NSDictionary *dict = object;
        NSArray *playlist = dict[MoeCallbackDictSongKey];
        NSMutableArray <MoefmSong *> *array = [NSMutableArray arrayWithArray:playlist];
        [[PTPlayerManager sharedPlayerManager] changeToPlayList:array andPlayType:MoeFavRandomPlay andSongIDs:nil];
    } errorHandler:^(id error) {
        NSLog(@"%@", error);
    }];
}

- (IBAction)playCurrentListAction:(UIButton *)sender {
    if (self.songCount == 0) {
        [SVProgressHUD showInfoWithStatus:@"还没有收藏歌曲"];
        [SVProgressHUD dismissWithDelay:1.5];
        return;
    }
    NSMutableArray *array = [NSMutableArray array];
    for (MoefmSong *song in self.radioPlaylist) {
        [array addObject:song.sub_id];
    }
    [[PTPlayerManager sharedPlayerManager] changeToPlayList:self.radioPlaylist andPlayType:nil andSongIDs:array];
}

- (IBAction)backToHomeAction:(UIBarButtonItem *)sender {
    self.tabBarController.selectedIndex = 0;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;// 以后会变
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.songCount == 0) {
        return 0;
    }
    return self.radioPlaylist.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CollectionSongsCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    MoefmSong *radioPlaySong = self.radioPlaylist[indexPath.row];

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
    label.text = [NSString stringWithFormat:@"我收藏的歌曲 (共%lu首)", self.songCount];
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
