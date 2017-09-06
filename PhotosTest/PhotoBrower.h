//
//  PhotoBrower.h
//  PhotosTest
//
//  Created by Scofield on 17/9/5.
//  Copyright © 2017年 谢航. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhotoBrowerDelegate <NSObject>

-(void) ReturnPhotoToPicker:(NSMutableArray *) Photos;

@end

@interface PhotoBrower : UIViewController

/*
 *    设置Block
 */
typedef void (^PhotoResult)(id responseObject);

/*
 *    设置回调方法
 */
@property (nonatomic, copy) PhotoResult PhotoBlock;

@property (weak, nonatomic) id <PhotoBrowerDelegate> BrowerDelegate;

-(void) getPhotos:(NSArray *)photos andIndex:(NSInteger) index;

@end
