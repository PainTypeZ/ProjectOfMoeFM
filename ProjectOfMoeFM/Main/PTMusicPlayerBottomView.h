//
//  PTMusicPlayerBottomView.h
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/14.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PTAVPlayerBottomViewDelegate <NSObject>
@required
- (void)didClickPlayButtonAndSendState:(BOOL)isSelected;
- (void)didClickNextButton;
- (void)didClickFavouriteButtonAndSendState:(BOOL)isSelected;
- (void)didClickDislikeButtonAndSendState:(BOOL)isSelected;

@end

@interface PTMusicPlayerBottomView : UIView
// 检查登录状态需要访问这两个按钮的可选状态，所以公开属性
@property (weak, nonatomic) IBOutlet UIButton *favouriteButton;
@property (weak, nonatomic) IBOutlet UIButton *dislikeButton;
@property (strong, nonatomic) id<PTAVPlayerBottomViewDelegate> delegate;

@end
