//
//  MoefmUser.h
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/9/10.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface MoefmUser : JSONModel

@property (copy, nonatomic) NSString *uid;
@property (copy, nonatomic) NSString *user_name;
@property (copy, nonatomic) NSString *user_nickname;
@property (copy, nonatomic) NSString *user_sex;
@property (copy, nonatomic) NSString *user_registered;
@property (copy, nonatomic) NSString *user_lastactivity;
@property (copy, nonatomic) NSString *user_status;
@property (copy, nonatomic) NSString *user_level;
@property (copy, nonatomic) NSString <Optional> *user_icon;
@property (copy, nonatomic) NSString <Optional> *user_desc;
@property (copy, nonatomic) NSString *user_url;
@property (copy, nonatomic) NSString *user_fm_url;
@property (strong, nonatomic) NSDictionary *user_avatar;// user_avatar = @{@"small"*48,@"medium"*204, @"large"*原始大小}
@property (copy, nonatomic) NSString *follower_count;
@property (copy, nonatomic) NSString *following_count;
@property (copy, nonatomic) NSString *group_count;
@property (copy, nonatomic) NSString <Optional> *about;

@end
