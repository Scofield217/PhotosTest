//
//  PhotoBrowerCell.h
//  PhotosTest
//
//  Created by Scofield on 17/9/5.
//  Copyright © 2017年 谢航. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "PhotoModel.h"

@interface PhotoBrowerCell : UICollectionViewCell

-(void)loadPHAssetItemForPics:(PhotoModel *)photo;

@end
