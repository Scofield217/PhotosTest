//
//  UpdatePhotoCell.m
//  PhotosTest
//
//  Created by Scofield on 17/9/5.
//  Copyright © 2017年 谢航. All rights reserved.
//

#import "UpdatePhotoCell.h"
#import "MyMacro.h"

@implementation UpdatePhotoCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _PhotoImg = [[UIImageView alloc] init];
        _PhotoImg.frame = CGRectMake(0,0,frame.size.width,frame.size.height);
        [self addSubview:_PhotoImg];
        
        _DeleteImg = [UIButton buttonWithType:UIButtonTypeCustom];
        _DeleteImg.frame = CGRectMake(frame.size.width - 22*ScreenWidth_scale, 2*ScreenHeight_scale, 20*ScreenWidth_scale, 20*ScreenWidth_scale);
        [_DeleteImg setImage:XHImage(@"delete_red.png") forState:UIControlStateNormal];
        _DeleteImg.hidden = YES;
        [self addSubview:_DeleteImg];
        
        
    }
    return self;
}

-(void)loadPhotoData:(PhotoModel *)photo withTargetSize:(CGSize)target
{
    __weak typeof (self) weakSelf = self;
    
    if ([photo isKindOfClass:[PhotoModel class]]) {
        
        if (photo.asset != nil) {
            PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
            option.resizeMode = PHImageRequestOptionsResizeModeFast;
            option.synchronous = YES;
            
            [[PHImageManager defaultManager] requestImageForAsset:photo.asset targetSize:CGSizeMake(200, 200) contentMode:PHImageContentModeAspectFit options:option resultHandler:^(UIImage *result, NSDictionary *info){
                
                //修正图片方向
                UIImage *targetImg = [weakSelf fixOrientation:result];
                
                //缩小图片
                targetImg = [weakSelf reSizeImage:targetImg ForSize:target];
                
                weakSelf.PhotoImg.image = targetImg;
                
            }];
        }
        else
        {
            _PhotoImg.image = photo.originImage;
        }
    }
    
    if (photo.isSelect)
    {
        _DeleteImg.hidden = NO;
    }
    else{
        _DeleteImg.hidden = YES;
    }
}

-(void)setIsSelect:(BOOL)isSelect
{
    if (isSelect == NO) {
        _DeleteImg.hidden = NO;
    }else{
        _DeleteImg.hidden = YES;
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

#pragma mark 图片自己计算缩放比例到指定尺寸
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

// 修正图片方向

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
@end
