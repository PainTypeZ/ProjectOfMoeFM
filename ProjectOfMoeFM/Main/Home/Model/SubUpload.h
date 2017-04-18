//
//  SubUpload.h
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/18.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol SubUpload;

@interface SubUpload : JSONModel

@property (copy, nonatomic) NSString *up_url;

@end
