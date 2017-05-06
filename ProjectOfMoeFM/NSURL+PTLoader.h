//
//  NSURL+PTLoader.h
//  OAuthTest
//
//  Created by 彭平军 on 2017/5/4.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (PTLoader)

- (NSURL *)customSchemeURL; // 自定义scheme的URL

- (NSURL *)originalSchemeURL; // 原始scheme的URL
@end
