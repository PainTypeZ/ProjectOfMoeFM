//
//  RadioUser.m
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/25.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import "RadioUser.h"
#import "GTMNSString+HTML.h"

@implementation RadioUser

- (NSString<Optional> *)about {
    return [_about gtm_stringByUnescapingFromHTML];
}

@end
