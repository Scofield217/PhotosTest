//
//  VideoModel.h
//  PhotosTest
//
//  Created by Scofield on 17/9/5.
//  Copyright © 2017年 谢航. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoModel.h"

@interface VideoModel : UIViewController

/*
 设置block
 **/
typedef void (^DeleteVideoBlock)(BOOL isDelete);

/*
 设置回调方法
 **/
@property (copy, nonatomic) DeleteVideoBlock DeleteBlock;

-(void) getVideo:(PhotoModel *)photo;

@end
