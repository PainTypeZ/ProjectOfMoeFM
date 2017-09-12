//
//  MoefmParameters.h
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/9/10.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface MoefmParameters : JSONModel

// @{wiki_type, page, pergage, oauth_consumer_key, oauth_token, oauth_signature_method, oauth_timestamp, oauth_nonce, oauth_version, oauth_signature}
@property (copy, nonatomic) NSString <Optional> *wiki_type;
@property (copy, nonatomic) NSString <Optional> *page;
@property (copy, nonatomic) NSString <Optional> *perpage;
@property (copy, nonatomic) NSString <Optional> *api;
@property (copy, nonatomic) NSString <Optional> *song;
@property (copy, nonatomic) NSString <Optional> *consumer_key;
@property (copy, nonatomic) NSString <Optional> *consumer_secret;
@property (copy, nonatomic) NSString <Optional> *oauth_consumer_key;
@property (copy, nonatomic) NSString <Optional> *oauth_token;
@property (copy, nonatomic) NSString <Optional> *oauth_signature_method;
@property (copy, nonatomic) NSString <Optional> *oauth_timestamp;
@property (copy, nonatomic) NSString <Optional> *oauth_nonce;
@property (copy, nonatomic) NSString <Optional> *oauth_version;
@property (copy, nonatomic) NSString <Optional> *oauth_signature;

@end
