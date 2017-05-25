//
//  RadioPlaySong.m
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/13.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import "RadioPlaySong.h"
#import "GTMNSString+HTML.h"

@implementation RadioPlaySong

- (NSString<Optional> *)sub_title {
    return [_sub_title gtm_stringByUnescapingFromHTML];
}

- (NSString *)wiki_title {
    return [_wiki_title gtm_stringByUnescapingFromHTML];
}
@end
