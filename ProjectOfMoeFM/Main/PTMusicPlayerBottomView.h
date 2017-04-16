//
//  PTMusicPlayerBottomView.h
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/14.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerData.h"

@protocol PTAVPlayerBottomViewDelegate <NSObject>
@required
- (void)didClickPlayButton;
- (void)didClickNextButton;
- (void)didClickFavouriteButton;
- (void)didClickDislikeButton;

@end

@interface PTMusicPlayerBottomView : UIView

@property (strong, nonatomic) PlayerData *playerData;
@property (strong, nonatomic) id<PTAVPlayerBottomViewDelegate> delegate;

@end
