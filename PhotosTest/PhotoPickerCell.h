//
//  PhotoPickerCell.h
//  PhotosTest
//
//  Created by Scofield on 17/9/5.
//  Copyright © 2017年 谢航. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoModel.h"

@interface PhotoPickerCell : UICollectionViewCell

@property(copy  ,nonatomic) void(^selectBlock)();

@property(assign,nonatomic) BOOL isSelect;

-(void)loadPhotoData:(PhotoModel *)photo withTargetSize:(CGSize)target state:(BOOL)isPhotoModel;

@end
