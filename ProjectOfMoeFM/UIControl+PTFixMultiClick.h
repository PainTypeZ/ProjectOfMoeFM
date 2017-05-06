//
//  UIControl+PTFixMultiClick.h
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/5/3.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIControl (PTFixMultiClick)
// Category不能给类添加属性, 所以以xia的pt_acceptEventInterval和pt_acceptEventTime只会有对应的getter和setter方法, 不会添加真正的成员变量，如果不在实现文件中添加其getter和setter方法, 则采用 btn.pt_acceptEventInterval = 1; 这种方法尝试访问该属性会出错.
@property (nonatomic, assign) NSTimeInterval pt_acceptEventInterval; // 重复点击的间隔
@property (nonatomic, assign) NSTimeInterval pt_acceptEventTime;

@end
