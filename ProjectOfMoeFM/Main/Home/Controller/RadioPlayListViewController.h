//
//  RadioPlayListViewController.h
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/13.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RadioWiki.h"
@interface RadioPlayListViewController : UIViewController
@property (strong, nonatomic) RadioWiki *radioWiki;
@property (assign, nonatomic) BOOL isFavourite;

@end
