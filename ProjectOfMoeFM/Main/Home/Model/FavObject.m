//
//  FavObject.m
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/18.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import "FavObject.h"
#import "GTMNSString+HTML.h"

@implementation FavObject

- (NSString *)sub_title {
    return [_sub_title gtm_stringByUnescapingFromHTML];
}

@end
