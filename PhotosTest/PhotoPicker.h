//
//  PhotoPicker.h
//  PhotosTest
//
//  Created by Scofield on 17/9/5.
//  Copyright © 2017年 谢航. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhotoPickerDelegate <NSObject>

-(void) ReturnPhotoToHome:(NSMutableArray *) Photos;

@end

@interface PhotoPicker : UIViewController

/*
 *    设置Block
 */
typedef void (^PhotoResult)(id responseObject);

/*
 *    设置回调方法
 */
@property (nonatomic, copy) PhotoResult PhotoBlock;

@property (weak, nonatomic) id <PhotoPickerDelegate> PickerDelegate;

@property (assign, nonatomic) BOOL isPhotoModel; //判断是否为相机模式



@end
