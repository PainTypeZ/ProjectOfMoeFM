//
//  MoefmUser.m
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/9/10.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import "MoefmUser.h"
#import "GTMNSString+HTML.h"

@implementation MoefmUser

- (NSString<Optional> *)about {
    return [_about gtm_stringByUnescapingFromHTML];
}

@end
