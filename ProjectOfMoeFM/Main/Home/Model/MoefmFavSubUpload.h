//
//  MoefmFavSubUpload.h
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/9/10.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol MoefmFavSubUpload;

@interface MoefmFavSubUpload : JSONModel

@property (copy, nonatomic) NSString *up_url;
@property (strong, nonatomic) NSDictionary *up_data;

@end
