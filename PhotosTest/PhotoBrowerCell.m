//
//  PhotoBrowerCell.m
//  PhotosTest
//
//  Created by Scofield on 17/9/5.
//  Copyright © 2017年 谢航. All rights reserved.
//

#import "PhotoBrowerCell.h"
#import "MyMacro.h"

@interface PhotoBrowerCell ()
{
    CGFloat _browser_width;
    CGFloat _browser_height;
}

@property (nonatomic, strong) UIImageView *PhotoImg;
@property (strong, nonatomic) UIImageView *PlayImg;

@end

@implementation PhotoBrowerCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _browser_width = frame.size.width;
        _browser_height = frame.size.height;
        
        _PhotoImg = [[UIImageView alloc]init];
        _PhotoImg.userInteractionEnabled = YES;
        _PhotoImg.contentMode = UIViewContentModeScaleAspectFit;
        
        [self addSubview:_PhotoImg];
        
        _PlayImg = [[UIImageView alloc] init];
        _PlayImg.frame = CGRectMake((WIDTH(_PhotoImg) - 25*ScreenHeight_scale)/2, (HEIGHT(_PhotoImg) - 25*ScreenHeight_scale)/2, 25*ScreenHeight_scale, 25*ScreenHeight_scale);
        _PlayImg.image = XHImage(@"play_white.png");
        _PlayImg.hidden = YES;
        [_PhotoImg addSubview:_PlayImg];
    }
    return self;
}

-(void)loadPHAssetItemForPics:(PHAsset *)assetItem
{
    __weak typeof (self) weakSelf = self;
    PHAsset *phAsset = (PHAsset *)assetItem;
    CGFloat photoWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat aspectRatio = phAsset.pixelWidth / (CGFloat)phAsset.pixelHeight;
    CGFloat multiple = [UIScreen mainScreen].scale;
    CGFloat pixelWidth = photoWidth * multiple;
    CGFloat pixelHeight = pixelWidth / aspectRatio;
    
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    
    [[PHImageManager defaultManager] requestImageForAsset:phAsset targetSize:CGSizeMake(pixelWidth, pixelHeight) contentMode:PHImageContentModeAspectFit options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
        
        if (downloadFinined) {
            
            if (result != nil) {
                [weakSelf changeFrameWithImage:result];
                weakSelf.PhotoImg.image = result;
            }
        }
        
    }];
}

-(void)changeFrameWithImage:(UIImage *)image
{
    CGFloat height = image.size.height / image.size.width * _browser_width;
    _PhotoImg.frame = CGRectMake(0, 0, _browser_width, height);
    _PhotoImg.center = CGPointMake(_browser_width / 2, _browser_height / 2);
}

@end
