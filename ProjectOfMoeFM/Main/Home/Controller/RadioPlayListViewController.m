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
#import "RadioRelationships.h"
#import "RadioSubUpload.h"

#import "PTWebUtils.h"

#import "PTPlayerManager.h"

#import "MoefmAPIConst.h"

@interface RadioPlayListViewController ()<UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching>

@property (weak, nonatomic) IBOutlet UITableView *radioPlayListTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *playAllSongsItem;

@property (strong, nonatomic) NSMutableArray *radioPlaylist;// 保存电台播放列表信息
@property (weak, nonatomic) IBOutlet UILabel *titeLabel;

@property (assign, nonatomic) NSUInteger currentPage;
@property (assign, nonatomic) NSUInteger perpage;
@property (assign, nonatomic) NSUInteger songCount;
@property (strong, nonatomic) NSMutableArray *songIDs;
@property (strong, nonatomic) RadioWiki *radioWiki;

//@property (strong, nonatomic) NSDictionary *requestedList; //用来标记是否需要重新请求列表信息, 暂时不做缓存

@end

@implementation RadioPlayListViewController

static NSString * const reuseIdentifier = @"radioPlayListCell";

- (NSMutableArray *)radioPlaylist {
    if (!_radioPlaylist) {
        _radioPlaylist = [NSMutableArray array];
    }
    return _radioPlaylist;
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
    __weak RadioPlayListViewController *weakSelf = self;
    // 下拉刷新
    self.radioPlayListTableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 加载数据
        weakSelf.currentPage = 1;
        // 请求电台播放列表信息
        [PTWebUtils requestPlaylistWithRadioId:weakSelf.radioWiki.wiki_id andPage:weakSelf.currentPage andPerpage:0 completionHandler:^(id object) {
            NSDictionary *dict = object;
            weakSelf.radioPlaylist = dict[MoeCallbackDictSongKey];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.radioPlayListTableView reloadData];
                [weakSelf.radioPlayListTableView.mj_header endRefreshing];
            });
        } errorHandler:^(id error) {
            [weakSelf.radioPlayListTableView.mj_header endRefreshing];
            NSLog(@"%@", error);
        }];
    }];
    
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    self.radioPlayListTableView.mj_header.automaticallyChangeAlpha = YES;
    
    // 上拉刷新
    self.radioPlayListTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
       if (weakSelf.radioPlaylist.count >= weakSelf.songCount) {
            [SVProgressHUD showInfoWithStatus:@"已经是最后一页了"];
            [SVProgressHUD dismissWithDelay:1.5];
            // 结束刷新
            [weakSelf.radioPlayListTableView.mj_footer endRefreshing];
            return;
        }
        // 加载数据
        weakSelf.currentPage++;
        // 请求电台播放列表信息
        [PTWebUtils requestPlaylistWithRadioId:weakSelf.radioWiki.wiki_id andPage:weakSelf.currentPage andPerpage:0 completionHandler:^(id object) {
            NSDictionary *dict = object;
            NSArray *moreSongsArray = dict[MoeCallbackDictSongKey];
            [weakSelf.radioPlaylist addObjectsFromArray:moreSongsArray];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.radioPlayListTableView reloadData];
                // 结束刷新
                [weakSelf.radioPlayListTableView.mj_footer endRefreshing];
            });
        } errorHandler:^(id error) {
            // 结束刷新
            [weakSelf.radioPlayListTableView.mj_footer endRefreshing];
            NSLog(@"%@", error);
        }];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.radioWiki = self.relationshipsDict[@"radioWiki"];
    NSNumber *count = self.relationshipsDict[MoeCallbackDictCountKey];
    self.songCount = count.integerValue;
    NSArray *relationships = self.relationshipsDict[MoeCallbackDictRelationshipsKey];
    self.songIDs = [NSMutableArray array];
    for (RadioRelationships *relationship in relationships) {
        [self.songIDs addObject:relationship.obj.sub_id];
    }
    
    if (self.playAllSongsItem.enabled == NO) {
        self.titeLabel.text = [NSString stringWithFormat:@"%@\n(共%lu首)", self.radioWiki.wiki_title, self.songCount];
        // 请求电台播放列表信息
        [SVProgressHUD showWithStatus:@"加载数据中，请稍后"];
        [PTWebUtils requestPlaylistWithRadioId:self.radioWiki.wiki_id andPage:self.currentPage andPerpage:0 completionHandler:^(id object) {
            NSDictionary *dict = object;
            self.radioPlaylist = dict[MoeCallbackDictSongKey];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.radioPlayListTableView reloadData];
                [SVProgressHUD dismiss];
                self.playAllSongsItem.enabled = YES;
            });
        } errorHandler:^(id error) {
            NSLog(@"%@", error);
        }];
    }
}
- (IBAction)playSingleSongAction:(UIButton *)sender {
    RadioPlayListCell *cell = (RadioPlayListCell *)sender.superview.superview;
    [[PTPlayerManager sharedPlayerManager] changeToPlayList:@[cell.radioPlaySong] andPlayType:MoeSingleSongPlay andSongIDs:@[]];
}
- (IBAction)playAllSongsAction:(UIBarButtonItem *)sender {
    [[PTPlayerManager sharedPlayerManager] changeToPlayList:self.radioPlaylist andPlayType:@"" andSongIDs:self.songIDs];
    sender.enabled = NO;
    sleep(3);
    sender.enabled = YES;
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.radioPlaylist.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RadioPlayListCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    RadioPlaySong *radioPlaySong = self.radioPlaylist[indexPath.row];
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

- (void)dealloc {
    NSLog(@"电台播放列表界面被销毁了");
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
