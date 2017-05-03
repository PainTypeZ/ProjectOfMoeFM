//
//  MineViewController.m
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/25.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import "MineViewController.h"
#import "PTWebUtils.h"
#import "MoefmAPIConst.h"
#import "RadioUser.h"
#import <SDWebImage/UIImageView+WebCache.h>
@interface MineViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *userAvatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userAboutLabel;
@property (weak, nonatomic) IBOutlet UILabel *userFollowingLabel;
@property (weak, nonatomic) IBOutlet UILabel *userFollowerLabel;
@property (weak, nonatomic) IBOutlet UILabel *userGroupLabel;
@property (weak, nonatomic) IBOutlet UILabel *userRegisterLabel;
@property (weak, nonatomic) IBOutlet UILabel *userUIDLabel;

@property (strong, nonatomic) RadioUser *userInfo;

@end

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:72.0/255 green:170.0/255 blue:245.0/255 alpha:1.0];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    if (!self.userInfo) {
        [self loadUserInfo];
    }
}

- (void)loadUserInfo {
    [PTWebUtils requestUserInfoWithCompletionHandler:^(id object) {
        NSDictionary *dict = object;
        self.userInfo = dict[@"user"];
        if (self.userInfo) {
            
            [self.userAvatarImageView sd_setImageWithURL:self.userInfo.user_avatar[MoePictureSizeLargeKey]];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.userNickNameLabel.text = self.userInfo.user_nickname;
                
                self.userNameLabel.text = self.userInfo.user_name;
                
                self.userAboutLabel.text = self.userInfo.about;
                
                self.userFollowingLabel.text = self.userInfo.following_count;
                
                self.userFollowerLabel.text = self.userInfo.follower_count;
                
                self.userGroupLabel.text = self.userInfo.group_count;
                
                NSString *timestamp = self.userInfo.user_registered;
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateStyle:NSDateFormatterMediumStyle];
                [formatter setTimeStyle:NSDateFormatterShortStyle];
                [formatter setDateFormat:@"yyyy-MM-dd"]; // （@"yyyy-MM-dd hh:mm:ss"）----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
                NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
                [formatter setTimeZone:timeZone];
                NSDate *resultDate = [NSDate dateWithTimeIntervalSince1970:timestamp.integerValue];
                NSString *resultDateString = [formatter stringFromDate:resultDate];
                
                self.userRegisterLabel.text = resultDateString;
                
                self.userUIDLabel.text = self.userInfo.uid;
            });
        }
    } errorHandler:^(id error) {
        NSLog(@"%@", error);
    }];
}

- (IBAction)backToHomeAction:(UIBarButtonItem *)sender {
    self.tabBarController.selectedIndex = 0;
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
