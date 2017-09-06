//
//  PhotoModel.h
//  PhotosTest
//
//  Created by Scofield on 17/9/5.
//  Copyright © 2017年 谢航. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface PhotoModel : NSObject

/**
 图片资源
 */
@property (nonatomic, strong) PHAsset *asset;
/**
 视频资源
 */
@property (nonatomic, strong) AVAsset *asset_video;
/**
 原尺寸图片
 */
@property (nonatomic, strong) UIImage *originImage;
/**
 照片在手机中的路径
 */
@property (nonatomic, strong) NSURL *imageUrl;
/**
 照片保存到相册中的时间
 */
@property (nonatomic, copy)   NSDate *createDate;
/**
 判断该图片是否选中
 */
@property (nonatomic, assign) BOOL isSelect;
/**
 判断该资源是图片还是视频
 */
@property (nonatomic, assign) BOOL isPhotoModel;

@end
