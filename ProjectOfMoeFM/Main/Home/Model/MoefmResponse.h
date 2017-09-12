//
//  MoefmResponse.h
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/9/10.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "MoefmInformation.h"
#import "MoefmRelationships.h"
#import "MoefmUser.h"
#import "MoefmSong.h"
#import "MoefmFavourite.h"

@interface MoefmResponse : JSONModel

@property (strong, nonatomic) MoefmInformation <Optional> *information;
@property (strong, nonatomic) MoefmUser <Optional> *user;
@property (strong, nonatomic) NSArray <Optional, MoefmFavourite> *favs;
@property (strong, nonatomic) NSDictionary <Optional> *fav;
@property (copy, nonatomic) NSString <Optional> *fav_id;
@property (strong, nonatomic) NSArray <Optional, MoefmWiki> *wikis;
@property (strong, nonatomic) NSArray <Optional, MoefmRelationships> *relationships;
@property (strong, nonatomic) NSArray <Optional, MoefmSong> *playlist;
@property (strong, nonatomic) NSArray <Optional, MoefmWiki> *hot_radios;

@end
