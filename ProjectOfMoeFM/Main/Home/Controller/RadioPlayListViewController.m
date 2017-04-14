//
//  RadioPlayListViewController.m
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/13.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import "RadioPlayListViewController.h"
#import "RadioPlayListCell.h"

#import "RadioPlaySong.h"

#import "PTWebUtils.h"

@interface RadioPlayListViewController ()<UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching>

@property (weak, nonatomic) IBOutlet UITableView *radioPlayListTableView;

@property (strong, nonatomic) NSMutableArray *radio_playlist;// 保存电台播放列表信息


@end

@implementation RadioPlayListViewController

static NSString * const reuseIdentifier = @"radioPlayListCell";

- (NSMutableArray *)radio_playlist {
    if (!_radio_playlist) {
        _radio_playlist = [NSMutableArray array];
    }
    return _radio_playlist;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:72.0/255 green:170.0/255 blue:245.0/255 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    if (self.radioWiki.wiki_id) {
        // 请求播放列表信息
        [PTWebUtils requestRadioPlayListWithRadio_id:self.radioWiki.wiki_id callback:^(id object) {
            self.radio_playlist = object;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.radioPlayListTableView reloadData];
            });
        }];
    }
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
