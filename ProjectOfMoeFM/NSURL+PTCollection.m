//
//  NSURL+PTCollection.m
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/9/5.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import "NSURL+PTCollection.h"

@implementation NSURL (PTCollection)

- (NSURL *)customSchemeURL {
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:self resolvingAgainstBaseURL:NO];
    components.scheme = @"streaming";
    return [components URL];
}

- (NSURL *)originalSchemeURL {
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:self resolvingAgainstBaseURL:NO];
    components.scheme = @"http";
    return [components URL];
}

@end
