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

@property (weak, nonatomic) IBOutlet UIButton *favouriteButton;
@property (weak, nonatomic) IBOutlet UIButton *dislikeButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (strong, nonatomic) id<PTAVPlayerBottomViewDelegate> delegate;

@end
