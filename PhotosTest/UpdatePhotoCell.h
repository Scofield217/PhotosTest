//
//  UpdatePhotoCell.h
//  PhotosTest
//
//  Created by Scofield on 17/9/5.
//  Copyright © 2017年 谢航. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoModel.h"

@interface UpdatePhotoCell : UICollectionViewCell

@property (strong, nonatomic) UIImageView *PhotoImg;
@property (strong, nonatomic) UIButton *DeleteImg;

@property (strong, nonatomic) UIImageView *VideoImg;
@property (strong, nonatomic) UILabel *VideoDuration;
@property (strong, nonatomic) UIView *bottom;

-(void)loadPhotoData:(PhotoModel *)photo withTargetSize:(CGSize)target;

@end
