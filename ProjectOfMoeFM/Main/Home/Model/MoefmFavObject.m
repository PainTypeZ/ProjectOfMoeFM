//
//  MoefmFavObject.m
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/9/10.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import "MoefmFavObject.h"
#import "GTMNSString+HTML.h"

@implementation MoefmFavObject

- (NSString *)sub_title {
    return [_sub_title gtm_stringByUnescapingFromHTML];
}

@end
