//
//  MoefmSong.m
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/9/10.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import "MoefmSong.h"
#import "GTMNSString+HTML.h"

@implementation MoefmSong

- (NSString<Optional> *)sub_title {
    return [_sub_title gtm_stringByUnescapingFromHTML];
}

- (NSString *)wiki_title {
    return [_wiki_title gtm_stringByUnescapingFromHTML];
}

@end
