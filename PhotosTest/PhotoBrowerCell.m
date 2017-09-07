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

-(void)loadPHAssetItemForPics:(PhotoModel *)photo
{
    __weak typeof (self) weakSelf = self;
    PHAsset *phAsset = photo.asset;
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
    
    PHAssetResource *resource = [[PHAssetResource assetResourcesForAsset:phAsset] firstObject];
    NSInteger size = [[resource valueForKey:@"fileSize"] longLongValue];
    
    photo.asset_Size = [self fileSizeWithInterge:size];
}

-(void)changeFrameWithImage:(UIImage *)image
{
    CGFloat height = image.size.height / image.size.width * _browser_width;
    _PhotoImg.frame = CGRectMake(0, 0, _browser_width, height);
    _PhotoImg.center = CGPointMake(_browser_width / 2, _browser_height / 2);
}

#pragma mark 计算图片大小
- (NSString *)fileSizeWithInterge:(NSInteger)size{
    // 1k = 1024, 1m = 1024k
    if (size < 1024) {// 小于1k
        return [NSString stringWithFormat:@"%ldB",(long)size];
    }else if (size < 1024 * 1024){// 小于1m
        CGFloat aFloat = (float)size/1024;
        return [NSString stringWithFormat:@"%.0fKB",aFloat];
    }else if (size < 1024 * 1024 * 1024){// 小于1G
        CGFloat aFloat = (float)size/(1024 * 1024);
        return [NSString stringWithFormat:@"%.1fMB",aFloat];
    }else{
        CGFloat aFloat = (float)size/(1024*1024*1024);
        return [NSString stringWithFormat:@"%.1fG",aFloat];
    }
}

@end
