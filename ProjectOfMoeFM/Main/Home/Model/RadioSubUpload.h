//
//  RadioSubUpload.h
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/13.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface RadioSubUpload : JSONModel

@property (copy, nonatomic) NSString *up_id;
@property (copy, nonatomic) NSString *up_uid;
@property (copy, nonatomic) NSString *up_obj_id;
@property (copy, nonatomic) NSString *up_obj_type;
@property (copy, nonatomic) NSString *up_uri;
@property (copy, nonatomic) NSString *up_type;
@property (copy, nonatomic) NSString *up_md5;
@property (copy, nonatomic) NSString *up_size;
@property (copy, nonatomic) NSString *up_quality;
@property (copy, nonatomic) NSDictionary *up_data; //@{bitrate, length, time, filesize}
@property (copy, nonatomic) NSString *up_date;
@property (copy, nonatomic) NSString *up_url;

@end
