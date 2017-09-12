//
//  MoefmInformation.h
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/9/10.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "MoefmParameters.h"

@interface MoefmInformation : JSONModel

@property (strong, nonatomic) MoefmParameters *parameters;// @{wiki_type, page, pergage, oauth_consumer_key, oauth_token, oauth_signature_method, oauth_timestamp, oauth_nonce, oauth_version, oauth_signature}
@property (strong, nonatomic) NSArray <Optional> *msg;// @[]
@property (assign, nonatomic) BOOL has_error;
@property (copy, nonatomic) NSString <Optional>*error;
@property (copy, nonatomic) NSString *request;
@property (copy, nonatomic) NSString <Optional> *page;
@property (copy, nonatomic) NSString <Optional> *perpage;
@property (copy, nonatomic) NSString <Optional> *count;
@property (copy, nonatomic) NSString <Optional> *song_count;
@property (copy, nonatomic) NSString <Optional> *item_count;
@property (copy, nonatomic) NSString <Optional> *is_target;
@property (copy, nonatomic) NSString <Optional> *may_have_next;
@property (copy, nonatomic) NSString <Optional> *next_url;

@end
