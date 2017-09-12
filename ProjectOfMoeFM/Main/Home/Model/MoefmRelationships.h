//
//  MoefmRelationships.h
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/9/10.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "MoefmObject.h"

@protocol MoefmRelationships;

@interface MoefmRelationships : JSONModel

@property (copy, nonatomic) NSString *wr_id;
@property (copy, nonatomic) NSString *wr_obj1;
@property (copy, nonatomic) NSString *wr_obj1_type;
@property (copy, nonatomic) NSString *wr_obj2;
@property (copy, nonatomic) NSString *wr_obj2_type;
@property (copy, nonatomic) NSString *wr_order;
@property (copy, nonatomic) NSString <Optional> *wr_about;
@property (copy, nonatomic) MoefmObject *obj;

@end
