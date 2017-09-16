//
//  WikiPlayListViewController.h
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/13.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoefmWiki.h"
@interface WikiPlayListViewController : UIViewController
@property (strong, nonatomic) NSDictionary *relationshipsDict;
@property (assign, nonatomic) NSUInteger wikiType;

@end
