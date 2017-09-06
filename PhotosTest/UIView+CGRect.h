//
//  UIView+CGRect.h
//  PhotosTest
//
//  Created by Scofield on 17/9/5.
//  Copyright © 2017年 谢航. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyMacro.h"

@interface UIView (CGRect)

@property(nonatomic) CGRect CustomFrame;

-(void) setCustomFrame:(CGRect) rect;

+ (UIImage*)reSizeImage:(UIImage *)image ForSize:(CGSize)targetSize;

+ (UIImage *)fixOrientation:(UIImage *)aImage;

@end
