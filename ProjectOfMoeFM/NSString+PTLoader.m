//
//  NSString+PTLoader.m
//  OAuthTest
//
//  Created by 彭平军 on 2017/5/4.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import "NSString+PTLoader.h"

@implementation NSString (PTLoader)

+ (NSString *)tempFilePath {
    return [[NSHomeDirectory() stringByAppendingPathComponent:@"tmp"] stringByAppendingPathComponent:@"MusicTemp.mp3"];
}


+ (NSString *)cacheFolderPath {
    return [[NSHomeDirectory() stringByAppendingPathComponent:@"Library"] stringByAppendingPathComponent:@"MusicCaches"];
}

+ (NSString *)fileNameWithURL:(NSURL *)url {
    return [[url.path componentsSeparatedByString:@"/"] lastObject];
}

@end
