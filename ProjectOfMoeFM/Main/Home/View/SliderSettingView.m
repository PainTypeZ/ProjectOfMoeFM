//
//  SliderSettingView.m
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/9/11.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import "SliderSettingView.h"
#import "PTPlayerManager.h"
#import <SVProgressHUD.h>
#import "AppDelegate.h"
#import "SliderSettingHeaderView.h"
@interface SliderSettingView()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *settingTableView;

@end
@implementation SliderSettingView

static NSString *cellIdentifier = @"settingTableView";

- (void)awakeFromNib {
    [super awakeFromNib];
    self.settingTableView.dataSource = self;
    self.settingTableView.delegate = self;
    
//    self.settingTableView.separatorStyle = UITableViewCellSelectionStyleGray;
    
    // 注册cell
    [self.settingTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;// 设置cell被选中时的效果
    
    if (indexPath.row == 4) {
        cell.textLabel.text = @"清理缓存";
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 4) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"清理缓存" message:@"确定要清理吗？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            BOOL isClean = [[PTPlayerManager sharedPlayerManager] cleanCaches];
            if (isClean == YES) {
                [SVProgressHUD showSuccessWithStatus:@"清理缓存成功！"];
                [SVProgressHUD dismissWithDelay:1];
            }
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:confirmAction];
        [alertController addAction:cancelAction];
        AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [app.window.rootViewController presentViewController:alertController animated:YES completion:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.frame.size.height * 0.75 / 8;// 0.75是因为headerview占了1/4的高度
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return self.frame.size.height * 0.25;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    SliderSettingHeaderView *headerView = [[NSBundle mainBundle] loadNibNamed:@"SliderSettingHeaderView" owner:nil options:nil].firstObject;
    headerView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height/4);
    return headerView;
}

@end
