//
//  RadioResponse.h
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/12.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "RadioInformation.h"
#import "RadioWiki.h"
#import "RadioRelationships.h"
#import "RadioPlaySong.h"
#import "Favourite.h"
#import "RadioUser.h"

@interface RadioResponse : JSONModel

@property (strong, nonatomic) RadioInformation <Optional> *information;
@property (strong, nonatomic) RadioUser <Optional> *user;
@property (strong, nonatomic) NSArray <Optional, Favourite> *favs;
@property (strong, nonatomic) NSDictionary <Optional> *fav;
@property (copy, nonatomic) NSString <Optional> *fav_id;
@property (strong, nonatomic) NSArray <Optional, RadioWiki> *wikis;
@property (strong, nonatomic) NSArray <Optional, RadioRelationships> *relationships;
@property (strong, nonatomic) NSArray <Optional, RadioPlaySong> *playlist;
@property (strong, nonatomic) NSArray <Optional, RadioWiki> *hot_radios;
@end
