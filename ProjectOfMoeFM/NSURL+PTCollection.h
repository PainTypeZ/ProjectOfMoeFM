//
//  NSURL+PTCollection.h
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/9/5.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (PTCollection)

// 转换为自定义Scheme
- (NSURL *)customSchemeURL;

// 还原Scheme
- (NSURL *)originalSchemeURL;

@end
