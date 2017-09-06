//
//  AVPlayerView.h
//  PhotosTest
//
//  Created by Scofield on 17/9/5.
//  Copyright © 2017年 谢航. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AVPlayer;

@interface AVPlayerView : UIView

@property (nonatomic, strong) AVPlayer* player;

- (void)setPlayer:(AVPlayer*)player;

@end
