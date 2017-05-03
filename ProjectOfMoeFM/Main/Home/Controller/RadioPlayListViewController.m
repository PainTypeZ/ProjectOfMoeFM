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
@property (weak, nonatomic) IBOutlet UIBarButtonItem *playAllSongsItem;

@property (strong, nonatomic) NSMutableArray *radioPlaylist;// 保存电台播放列表信息
@property (assign, nonatomic) NSUInteger songCount;// 现在的api没有这个功能，只有favSongID有
@property (assign, nonatomic) BOOL isLast;// 标记是否最后一页
@property (weak, nonatomic) IBOutlet UILabel *titeLabel;

@property (assign, nonatomic) NSUInteger currentPage;
@property (assign, nonatomic) NSUInteger perpage;
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

- (BOOL)isLast {
    if (!_isLast) {
        _isLast = NO;
    }
    return _isLast;
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
        self.isLast = NO;// 重置最后一页标记;
        weakSelf.currentPage = 1;
        // 请求电台播放列表信息
        [PTWebUtils requestRadioPlayListWithRadio_id:weakSelf.radioWiki.wiki_id andPage:weakSelf.currentPage andPerpage:0 completionHandler:^(id object) {
            NSDictionary *dict = object;
            NSNumber *count = dict[@"count"];
            weakSelf.songCount = count.integerValue;
            weakSelf.radioPlaylist = dict[@"songs"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.radioPlayListTableView reloadData];
                [weakSelf.radioPlayListTableView.mj_header endRefreshing];
            });
            
        } errorHandler:^(id error) {
            NSLog(@"%@", error);
        }];
    }];
    
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    self.radioPlayListTableView.mj_header.automaticallyChangeAlpha = YES;
    
    // 上拉刷新
    self.radioPlayListTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
//        if (weakSelf.radioPlaylist.count >= weakSelf.songCount)// 现在的api没有歌曲总数
        if (weakSelf.isLast == YES) {
            [SVProgressHUD showInfoWithStatus:@"已经是最后一页了"];
            [SVProgressHUD dismissWithDelay:1.5];
            // 结束刷新
            [weakSelf.radioPlayListTableView.mj_footer endRefreshing];
            return;
        }
        // 加载数据
        weakSelf.currentPage++;
        // 请求电台播放列表信息
        weakSelf.currentPage++;
        [PTWebUtils requestRadioPlayListWithRadio_id:weakSelf.radioWiki.wiki_id andPage:weakSelf.currentPage andPerpage:0 completionHandler:^(id object) {
            NSDictionary *dict = object;
            NSNumber *count = dict[@"count"];
            weakSelf.songCount = count.integerValue;
            NSArray *moreSongsArray = dict[@"songs"];
            if (moreSongsArray.count < 9) {
                weakSelf.isLast = YES;
            }
            [weakSelf.radioPlaylist addObjectsFromArray:moreSongsArray];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.radioPlayListTableView reloadData];
                // 结束刷新
                [weakSelf.radioPlayListTableView.mj_footer endRefreshing];
            });
            
        } errorHandler:^(id error) {
            NSLog(@"%@", error);
        }];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.playAllSongsItem.enabled = NO;
    self.titeLabel.text = self.radioWiki.wiki_title;
    // 请求电台播放列表信息
    [SVProgressHUD showWithStatus:@"加载数据中，请稍后"];
    [PTWebUtils requestRadioPlayListWithRadio_id:self.radioWiki.wiki_id andPage:self.currentPage andPerpage:0 completionHandler:^(id object) {
        NSDictionary *dict = object;
        NSNumber *count = dict[@"count"];
        self.songCount = count.integerValue;
        self.radioPlaylist = dict[@"songs"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.radioPlayListTableView reloadData];
            [SVProgressHUD dismiss];
            self.playAllSongsItem.enabled = YES;
        });
    } errorHandler:^(id error) {
        NSLog(@"%@", error);
    }];
}
- (IBAction)playSingleSongAction:(UIButton *)sender {
    RadioPlayListCell *cell = (RadioPlayListCell *)sender.superview.superview;
    [[PTPlayerManager sharedPlayerManager] playSingleSong:cell.radioPlaySong andRadioID:@"random"];
}
- (IBAction)playAllSongsAction:(UIBarButtonItem *)sender {
    [[PTPlayerManager sharedPlayerManager] changeToPlayList:self.radioPlaylist andRadioWikiID:self.radioWiki.wiki_id];
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
    return self.radioPlaylist.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RadioPlayListCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
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
