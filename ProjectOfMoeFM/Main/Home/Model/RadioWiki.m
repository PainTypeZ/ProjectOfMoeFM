//
//  RadioWiki.m
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/12.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import "RadioWiki.h"
#import "GTMNSString+HTML.h"

@implementation RadioWiki

- (NSString *)wiki_title {
    return [_wiki_title gtm_stringByUnescapingFromHTML];
}

@end
