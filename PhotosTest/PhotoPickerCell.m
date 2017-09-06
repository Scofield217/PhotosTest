//
//  PhotoPickerCell.m
//  PhotosTest
//
//  Created by Scofield on 17/9/5.
//  Copyright © 2017年 谢航. All rights reserved.
//

#import "PhotoPickerCell.h"
#import "MyMacro.h"

@interface PhotoPickerCell ()

@property (strong, nonatomic) UIImageView *PhotoImg;
@property (strong, nonatomic) UIButton *ChooseBT;

@property (strong, nonatomic) UIView *bottom;
@property (strong, nonatomic) UIImageView *VideoImg;
@property (strong, nonatomic) UILabel *VideoDuration;

@end

@implementation PhotoPickerCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _PhotoImg = [[UIImageView alloc] init];
        _PhotoImg.frame = CGRectMake(0,0,frame.size.width,frame.size.height);
        [self addSubview:_PhotoImg];
        
        
        _ChooseBT = [UIButton buttonWithType:UIButtonTypeCustom];
        _ChooseBT.frame = CGRectMake((WIDTH(_PhotoImg) -22*ScreenWidth_scale), 2*ScreenHeight_scale, 20*ScreenWidth_scale,20*ScreenHeight_scale);
        [_ChooseBT addTarget:self action:@selector(TouchButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_ChooseBT];
        
        _bottom = [UIView new];
        _bottom.frame = CGRectMake(0, (HEIGHT(_PhotoImg) - 20*ScreenHeight_scale), WIDTH(_PhotoImg), 20*ScreenHeight_scale);
        _bottom.backgroundColor = XHRGB(250, 250, 250, 0.45);
        _bottom.hidden = YES;
        [self addSubview:_bottom];
        
        _VideoImg = [[UIImageView alloc] init];
        _VideoImg.frame = CGRectMake(0, 0, 20*ScreenHeight_scale, 20*ScreenHeight_scale);
        _VideoImg.image = XHImage(@"video.png");
        [_bottom addSubview:_VideoImg];
        
        _VideoDuration = [UILabel new];
        _VideoDuration.frame = CGRectMake((WIDTH(_PhotoImg) -60*ScreenWidth_scale), Y(_VideoImg), 60*ScreenWidth_scale, HEIGHT(_VideoImg));
        _VideoDuration.font = XHFont(12);
        _VideoDuration.textAlignment = NSTextAlignmentCenter;
        [_bottom addSubview:_VideoDuration];
        
    }
    return self;
}

-(void) TouchButton:(UIButton *)sender
{
    [self selectAnimation:sender];
    self.selectBlock();
}

-(void)setIsSelect:(BOOL)isSelect
{
    if (isSelect == NO) {
        [_ChooseBT setImage:XHImage(@"Choose_nor.png") forState:UIControlStateNormal];
    }else{
        [_ChooseBT setImage:XHImage(@"Choose_sel.png") forState:UIControlStateNormal];
    }
}

-(void)loadPhotoData:(PhotoModel *)photo withTargetSize:(CGSize)target state:(BOOL)isPhotoModel
{
    if (photo.isSelect == NO) {
        [_ChooseBT setImage:XHImage(@"Choose_nor.png") forState:UIControlStateNormal];
    }else{
        [_ChooseBT setImage:XHImage(@"Choose_sel.png") forState:UIControlStateNormal];
    }
    
    __weak typeof (self) weakSelf = self;
    
    if (photo)
    {
        [[PHImageManager defaultManager] requestImageForAsset:photo.asset targetSize:CGSizeMake(200, 200) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage *result, NSDictionary *info){
            
            //修正图片方向
            UIImage *targetImg = [weakSelf fixOrientation:result];
            
            //缩小图片
            targetImg = [weakSelf reSizeImage:targetImg ForSize:target];
            
            weakSelf.PhotoImg.image = targetImg;
            photo.isPhotoModel = YES;
        }];
        
        if (!isPhotoModel) {
            
            _bottom.hidden = NO;
            
            PHImageManager *manager = [PHImageManager defaultManager];
            [manager requestAVAssetForVideo:photo.asset options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info)
             {
                 //CMTime转换
                 NSTimeInterval total = CMTimeGetSeconds(asset.duration);
                 
                 NSString *duration = [weakSelf stringWithTime:total];
                 
                 //回到主线程
                 dispatch_async(dispatch_get_main_queue(), ^{
                     weakSelf.VideoDuration.text = duration;
                     
                     photo.asset_video = asset;
                     photo.isPhotoModel = NO;
                 });
             }];
        }
    }
}

#pragma mark 时间显示转换
- (NSString *)stringWithTime:(NSTimeInterval)time
{
    NSInteger h = time / 3600;
    NSInteger m = time / 60;
    NSInteger s = (NSInteger)time % 60;
    
    NSString *stringtime = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", h, m, s];
    
    return stringtime;
}

#pragma mark 计算图片缩放比例到指定尺寸
- (UIImage*)reSizeImage:(UIImage *)image ForSize:(CGSize)targetSize
{
    
    UIImage *sourceImage = image;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        
        scaledWidth= width * scaleFactor;
        scaledHeight = height * scaleFactor;
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    //    UIGraphicsBeginImageContext(targetSize); // this will crop
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, [UIScreen mainScreen].scale);//缩放不改变分辨率
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width= scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil)
        NSLog(@"could not scale image");
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma mark 修正图片方向
- (UIImage *)fixOrientation:(UIImage *)aImage
{
    
    if (aImage.imageOrientation == UIImageOrientationUp)
        
        return aImage;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
            
        case UIImageOrientationDown:
            
        case UIImageOrientationDownMirrored:
            
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            
            transform = CGAffineTransformRotate(transform, M_PI);
            
            break;
            
        case UIImageOrientationLeft:
            
        case UIImageOrientationLeftMirrored:
            
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            
            transform = CGAffineTransformRotate(transform, M_PI_2);
            
            break;
            
        case UIImageOrientationRight:
            
        case UIImageOrientationRightMirrored:
            
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            
            break;
            
        default:
            
            break;
            
    }
    
    switch (aImage.imageOrientation) {
            
        case UIImageOrientationUpMirrored:
            
        case UIImageOrientationDownMirrored:
            
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            
            transform = CGAffineTransformScale(transform, -1, 1);
            
            break;
          
        case UIImageOrientationLeftMirrored:
            
        case UIImageOrientationRightMirrored:
            
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            
            transform = CGAffineTransformScale(transform, -1, 1);
            
            break;
            
        default:
            
            break;
            
    }
  
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             
                                             CGImageGetColorSpace(aImage.CGImage),
                                             
                                             CGImageGetBitmapInfo(aImage.CGImage));
    
    CGContextConcatCTM(ctx, transform);
    
    switch (aImage.imageOrientation) {
            
        case UIImageOrientationLeft:
            
        case UIImageOrientationLeftMirrored:
            
        case UIImageOrientationRight:
            
        case UIImageOrientationRightMirrored:
            
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            
            break;
           
        default:
            
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            
            break;
            
    }
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    
    CGContextRelease(ctx);
    
    CGImageRelease(cgimg);
    
    return img;
    
}

#pragma mark 选择按钮动画
-(void)selectAnimation:(UIButton *)button
{
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.5;
    
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    animation.values = values;
    [button.layer addAnimation:animation forKey:nil];
}

@end
