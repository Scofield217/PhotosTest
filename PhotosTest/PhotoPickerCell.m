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
        
        _PhotoImg = [[UIImageView alloc] initWithFrame:self.bounds];
        _PhotoImg.layer.masksToBounds = YES;
        _PhotoImg.contentMode = UIViewContentModeScaleAspectFill;
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
            
            weakSelf.PhotoImg.image = result;
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
