//
//  UIButton+PT_FixMultiClick.m
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/30.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import "UIButton+PT_FixMultiClick.h"
#import <objc/runtime.h>
@implementation UIButton (PT_FixMultiClick)
// 因category不能添加属性，只能通过关联对象的方式。
static const char *UIButton_acceptEventInterval = "UIButton_acceptEventInterval";
static const char *UIButton_acceptEventTime = "UIButton_acceptEventTime";

- (NSTimeInterval)pt_acceptEventInterval {
    return [objc_getAssociatedObject(self, UIButton_acceptEventInterval) doubleValue];
}

- (void)setPt_acceptEventInterval:(NSTimeInterval)pt_acceptEventInterval {
    objc_setAssociatedObject(self, UIButton_acceptEventInterval, @(pt_acceptEventInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)pt_acceptEventTime {
    return [objc_getAssociatedObject(self, UIButton_acceptEventTime) doubleValue];
}

- (void)setPt_acceptEventTime:(NSTimeInterval)pt_acceptEventTime {
    objc_setAssociatedObject(self, UIButton_acceptEventTime, @(pt_acceptEventTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// 在load时执行hook
+ (void)load {
    Method origin   = class_getInstanceMethod(self, @selector(sendAction:to:forEvent:));
    Method changed    = class_getInstanceMethod(self, @selector(pt_sendAction:to:forEvent:));
    method_exchangeImplementations(origin, changed);
}

- (void)pt_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
    if ([NSDate date].timeIntervalSince1970 - self.pt_acceptEventTime < self.pt_acceptEventInterval) {
        return;
    }
    if (self.pt_acceptEventInterval > 0) {
        self.pt_acceptEventTime = [NSDate date].timeIntervalSince1970;
    }
    [self pt_sendAction:action to:target forEvent:event];
}


@end
