//
//  PhotoPicker.m
//  PhotosTest
//
//  Created by Scofield on 17/9/5.
//  Copyright © 2017年 谢航. All rights reserved.
//

#import "PhotoPicker.h"
#import "PhotoPickerCell.h"
#import "PhotoBrower.h"
#import "UIView+CGRect.h"

static NSString *const cellId = @"cellId";

static NSString *const footerId = @"footerId";

#define CellWidth (ScreenWidth-8*1)/4

@interface PhotoPicker ()<UICollectionViewDelegate,UICollectionViewDataSource,PhotoBrowerDelegate>

@property (copy, nonatomic) NSMutableArray *imgViewArr; //原始尺寸

@property (copy, nonatomic) NSMutableArray *imgViewArr_small; //底部滑动小图

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UIView *bottomview;
@property (strong, nonatomic) UIScrollView *scroll;

@property (strong, nonatomic) UILabel *ImgCount; //选择的图片数量
@property (strong, nonatomic) UILabel *selectorLab; //footer

@property (copy, nonatomic) NSMutableArray *VideoArr; //视频

@property (strong, nonatomic) UILongPressGestureRecognizer *longPress;
@end

@implementation PhotoPicker

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = XHColor(whiteColor);
    self.title = @"相册";
    
    _imgViewArr = [NSMutableArray new];
    _imgViewArr_small = [NSMutableArray new];
    _VideoArr = [NSMutableArray new];
    
    [self getSystemPhotos];
}

-(void) getSystemPhotos
{
    // 获取所有资源的集合，并按资源的创建时间排序
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        // 获得相机胶卷的图片
        PHFetchResult<PHAssetCollection *> *collectionResult1 = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        for (PHAssetCollection *collection in collectionResult1) {
            if (![collection.localizedTitle isEqualToString:@"相机胶卷"]) continue;
            [self searchAllImagesInCollection:collection];
            break;
        }
    });
}

- (void)searchAllImagesInCollection:(PHAssetCollection *)collection
{
    // 采取同步获取图片（只获得一次图片）
    PHImageRequestOptions *imageOptions = [[PHImageRequestOptions alloc] init];
    imageOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
    imageOptions.synchronous = YES;
    imageOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    PHVideoRequestOptions *videoOptions = [[PHVideoRequestOptions alloc] init];
    videoOptions.deliveryMode = PHVideoRequestOptionsDeliveryModeFastFormat;
    
    __weak typeof (self) weakSelf = self;
    
    // 遍历这个相册中的所有资源
    PHFetchResult<PHAsset *> *assetResult = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
    
    for (PHAsset *asset in assetResult) {
        
        if (weakSelf.isPhotoModel) {
            // 过滤非图片
            if (asset.mediaType != PHAssetMediaTypeImage) continue;
            
            PhotoModel *photo = [[PhotoModel alloc] init];
            photo.asset = asset;
            [_imgViewArr addObject:photo];
        }
        else
        {
            // 过滤非视频
            if (asset.mediaType != PHAssetMediaTypeVideo) continue;
            
            PhotoModel *photo = [[PhotoModel alloc] init];
            photo.asset = asset;
            [_imgViewArr addObject:photo];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf loadMainView];
    });
    
}

-(void) loadMainView
{
    
    UICollectionViewFlowLayout *collectionFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    collectionFlowLayout.footerReferenceSize =CGSizeMake(ScreenWidth, 30*ScreenHeight_scale);
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,0,WIDTH(self.view),HEIGHT(self.view)-40*ScreenHeight_scale) collectionViewLayout:collectionFlowLayout];
    
    _collectionView.backgroundColor = XHColor(whiteColor);
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [self.view addSubview:_collectionView];
    
    // 注册cell、sectionHeader、sectionFooter
    [_collectionView registerClass:[PhotoPickerCell class] forCellWithReuseIdentifier:cellId];
    
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:footerId];
    
    [self loadBottomView];
    
    //长按手势
    _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    [_collectionView addGestureRecognizer:_longPress];
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    //滚动到底部
    if (_imgViewArr.count != 0) {
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_imgViewArr.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    }
}

-(void) loadBottomView
{
    _bottomview = [UIView new];
    _bottomview.frame = CGRectMake(0,HEIGHT(self.view)-40*ScreenHeight_scale, WIDTH(self.view), 40*ScreenHeight_scale);
    _bottomview.backgroundColor = XHRGB(233, 233, 233, 1);
    [self.view addSubview:_bottomview];
    
    UILabel *lab = [UILabel new];
    lab.CustomFrame = CGRectMake(0, 0, 60, 40);
    lab.text = @"预览";
    lab.textAlignment = NSTextAlignmentCenter;
    lab.font = XHFont(14);
    [_bottomview addSubview:lab];
    
    _ImgCount = [UILabel new];
    _ImgCount.CustomFrame = CGRectMake(375-65, 5, 15, 15);
    _ImgCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)[_imgViewArr_small count]];
    _ImgCount.textAlignment = NSTextAlignmentCenter;
    _ImgCount.font = XHFont(10);
    _ImgCount.textColor = XHColor(whiteColor);
    _ImgCount.backgroundColor = XHColor(redColor);
    _ImgCount.layer.masksToBounds = YES;
    _ImgCount.layer.cornerRadius = _ImgCount.bounds.size.height/2;
    [_bottomview addSubview:_ImgCount];
    
    UIButton *bt = [UIButton buttonWithType:UIButtonTypeCustom];
    bt.CustomFrame = CGRectMake(375-60, 0, 60, 40);
    [bt setTitle:@"完成" forState:UIControlStateNormal];
    [bt setTitleColor:XHColor(blueColor) forState:UIControlStateNormal];
    [bt addTarget:self action:@selector(Enter) forControlEvents:UIControlEventTouchUpInside];
    [_bottomview addSubview:bt];
}

-(void) loadScroll
{
    _scroll = [UIScrollView new];
    _scroll.frame = CGRectMake(60*ScreenWidth_scale, 0, WIDTH(self.view) -135*ScreenWidth_scale, HEIGHT(_bottomview));
    _scroll.contentSize = CGSizeMake([_imgViewArr_small count] * 50*ScreenWidth_scale, 0);
    // 开启分页
    _scroll.pagingEnabled = NO;
    // 没有弹簧效果
    _scroll.bounces = YES;
    // 隐藏水平滚动条
    _scroll.showsHorizontalScrollIndicator = NO;
    [_bottomview addSubview:_scroll];
    
    for (int i = 0; i < [_imgViewArr_small count]; i++)
    {
        __weak typeof (self) weakSelf = self;
        PhotoModel *photo = _imgViewArr_small[i];
        
        [[PHImageManager defaultManager] requestImageForAsset:photo.asset targetSize:CGSizeMake(200, 200) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage *result, NSDictionary *info){
            UIImageView *img = [UIImageView new];
            img.CustomFrame = CGRectMake(i*(40+10), 0, 40, 40);
            img.tag = 400 + i;
            
            UIImage *targetImg = [UIView reSizeImage:result ForSize:CGSizeMake(WIDTH(img), HEIGHT(img))];
            img.image = targetImg;
            
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(GoPictureModel:)];
            [img addGestureRecognizer:singleTap];
            img.userInteractionEnabled = YES;
            
            [weakSelf.scroll addSubview:img];
        }];
    }
}

#pragma mark 完成
-(void) Enter
{
    
    __block NSMutableArray<PhotoModel *> *photos = [NSMutableArray array];
    __weak __typeof(self) weakSelf = self;
    for (int i = 0; i < _imgViewArr_small.count; i++) {
        PhotoModel *photo = [_imgViewArr_small objectAtIndex:i];
        
        PHAsset *phAsset = photo.asset;
        
        CGFloat photoWidth = [UIScreen mainScreen].bounds.size.width;
        
        CGFloat screenScale = 2.0;
        if (photoWidth > 700) {
            screenScale = 1.5;
        }
        
        CGFloat aspectRatio = phAsset.pixelWidth / (CGFloat)phAsset.pixelHeight;
        CGFloat pixelWidth = photoWidth * screenScale;
        CGFloat pixelHeight = pixelWidth / aspectRatio;
        CGSize imageSize = CGSizeMake(pixelWidth, pixelHeight);
        
        PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
        option.resizeMode = PHImageRequestOptionsResizeModeFast;
        option.synchronous = YES;
        [[PHImageManager defaultManager] requestImageForAsset:phAsset targetSize:imageSize contentMode:PHImageContentModeAspectFit options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            
            BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
            
            UIImage *image = [UIView fixOrientation:result];
            //设置BOOL判断，确定返回高清照片
            if (downloadFinined) {
                NSURL *imageUrl = (NSURL *)[info objectForKey:@"PHImageFileURLKey"];
                
                if (image){
                    PhotoModel *model = [[PhotoModel alloc]init];
                    model.asset = photo.asset;
                    model.originImage = image;
                    model.imageUrl = imageUrl;
                    model.createDate = photo.asset.creationDate;
                    model.isPhotoModel = weakSelf.isPhotoModel;
                    model.asset_video = photo.asset_video;
                    [photos addObject:model];
                }
                if (photos.count < weakSelf.imgViewArr_small.count){
                    return;
                }
                if (weakSelf.PhotoBlock) {
                    weakSelf.PhotoBlock([NSArray arrayWithArray:photos]);
                }
            }
        }];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 看图模式
-(void) GoPictureModel:(UITapGestureRecognizer *)tap
{
    //图片模式才进入查看大图，视频不进入，这是我们项目的需求，如果各位有需求可以在此加代码
    if (_isPhotoModel)
    {
        __weak __typeof(self) weakSelf = self;
        
        UIImageView *img =(UIImageView *)tap.view;
        
        PhotoBrower *brower = [PhotoBrower new];
        [brower getPhotos:weakSelf.imgViewArr_small andIndex:img.tag - 400];
        
        brower.BrowerDelegate = self;
        brower.PhotoBlock = ^(id responseObject){
            
            NSMutableArray *ReturnImg = (NSMutableArray *)responseObject;
            
            //重新判断选择的图片
            for(int i = 0;i < [ReturnImg count];i++)
            {
                PhotoModel *photo = ReturnImg[i];
                
                if (photo.isSelect) {
                    
                    BOOL isbool = [weakSelf.imgViewArr_small containsObject:photo];
                    
                    if (!isbool) {
                        [weakSelf.imgViewArr_small addObject:photo];
                    }
                }
                else
                {
                    BOOL isbool = [weakSelf.imgViewArr_small containsObject:photo];
                    
                    if (isbool) {
                        [weakSelf.imgViewArr_small removeObject:photo];
                    }
                }
            }
            
            //先移除再加载
            [weakSelf.scroll removeFromSuperview];
            [weakSelf loadScroll];
            
            weakSelf.ImgCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)[weakSelf.imgViewArr_small count]];
            
            //先移除再加载,避免footer重影
            [weakSelf.selectorLab removeFromSuperview];
            [weakSelf.collectionView reloadData];
        };
        
        [self.navigationController pushViewController:brower animated:YES];
    }
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:footerId forIndexPath:indexPath];
    
    _selectorLab = [UILabel new];
    _selectorLab.CustomFrame = CGRectMake((375-200)/2, 0, 200, 30);
    _selectorLab.textColor = XHColor(blackColor);
    _selectorLab.font = XHFont(16);
    _selectorLab.textAlignment = NSTextAlignmentCenter;
    
    if (_isPhotoModel) {
        _selectorLab.text = [NSString stringWithFormat:@"有%lu张图片",(unsigned long)[_imgViewArr count]];
    }
    else
    {
        _selectorLab.text = [NSString stringWithFormat:@"有%lu个视频",(unsigned long)[_imgViewArr count]];
    }
    
    [footerView addSubview:_selectorLab];
    
    return footerView;
}

#pragma mark ---- UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_imgViewArr count];
}

#pragma mark cell内容
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    PhotoPickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[PhotoPickerCell alloc] init];
    }
    
    __unsafe_unretained __typeof(self) weakSelf = self;
    
    cell.selectBlock = ^(){
        
        [weakSelf selectPhotoAtIndex:indexPath.row];
        
    };
    
    [cell loadPhotoData:_imgViewArr[indexPath.row] withTargetSize:CGSizeMake(CellWidth, CellWidth) state:_isPhotoModel];
    
    cell.backgroundColor = [UIColor whiteColor];
    
    return cell;
}

#pragma mark 关键位置，选中的在数组中添加，取消的从数组中减少
- (void)selectPhotoAtIndex:(NSInteger)index
{
    PhotoModel *photo = [_imgViewArr objectAtIndex:index];
    
    if (photo != nil)
    {
        NSInteger count = 0;
        NSString *message = nil;
        
        if (_isPhotoModel)
        {
            count = 9;
            message =@"最多只能选9张图";
        }
        else
        {
            count = 5;
            message =@"最多只能选5个视频";
        }
        
        if (photo.isSelect == NO)
        {
            if ([_imgViewArr_small count] < count)
            {
                photo.isSelect = YES;
                [self changeSelectButtonStateAtIndex:index withPhoto:photo];
                [_imgViewArr_small addObject:photo];
                
                //先移除再加载
                [_scroll removeFromSuperview];
                [self loadScroll];
                
                //动画效果
                [self roundAnimation:_ImgCount];
                _ImgCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)[_imgViewArr_small count]];
            }
            else
            {
                UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
                [alertView addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                }]];
                
                [self presentViewController:alertView animated:true completion:nil];
            }
            
        }else
        {
            
            photo.isSelect = NO;
            [self changeSelectButtonStateAtIndex:index withPhoto:photo];
            [_imgViewArr_small removeObject:photo];
            
            //先移除再加载
            [_scroll removeFromSuperview];
            [self loadScroll];
            
            [self roundAnimation:_ImgCount];
            _ImgCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)[_imgViewArr_small count]];
            
        }
    }
}

- (void)changeSelectButtonStateAtIndex:(NSInteger)index withPhoto:(PhotoModel *)photo
{
    PhotoPickerCell *cell = (PhotoPickerCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    cell.isSelect = photo.isSelect;
}

#pragma mark cell宽高
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return (CGSize){CellWidth,CellWidth};
}

#pragma mark 屏幕间距，上左下右
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(2, 1, 2, 1);
}

#pragma mark 纵向间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 2;
}

#pragma mark 横向间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1;
}

#pragma mark 长按手势事件
- (void)longPressed:(UILongPressGestureRecognizer *)longGesture {
    //判断手势状态
    switch (longGesture.state) {
        case UIGestureRecognizerStateBegan:{
            //判断手势落点位置是否在路径上
            NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:[longGesture locationInView:self.collectionView]];
            if (indexPath == nil) {
                break;
            }
            //在路径上则开始移动该路径上的cell
            [self.collectionView beginInteractiveMovementForItemAtIndexPath:indexPath];
        }
            break;
        case UIGestureRecognizerStateChanged:
            //移动过程当中随时更新cell位置
            [self.collectionView updateInteractiveMovementTargetPosition:[longGesture locationInView:self.collectionView]];
            break;
        case UIGestureRecognizerStateEnded:
            //移动结束后关闭cell移动
            [self.collectionView endInteractiveMovement];
            
            //移动结束重新刷新一下，因为移动以后只是改变了当前cell和新的_imgViewArr，但页面中加载的还是原来的_imgViewArr，在多图选择时会出错
            [self.collectionView reloadData];
            break;
        default:
            [self.collectionView cancelInteractiveMovement];
            break;
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath{
    //返回YES允许其item移动
    return YES;
}

#pragma mark 移动item
- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath {
    //取出源item数据
    id objc = [_imgViewArr objectAtIndex:sourceIndexPath.item];
    //从资源数组中移除该数据
    [_imgViewArr removeObject:objc];
    //将数据插入到资源数组中的目标位置上
    [_imgViewArr insertObject:objc atIndex:destinationIndexPath.item];
}

#pragma mark 选中
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    __weak __typeof(self) weakSelf = self;
    
    if (_isPhotoModel)
    {
        PhotoBrower *brower = [PhotoBrower new];
        [brower getPhotos:_imgViewArr andIndex:indexPath.row];
        brower.BrowerDelegate = self;
        
        brower.PhotoBlock = ^(id responseObject){
            
            NSMutableArray *ReturnImg = (NSMutableArray *)responseObject;
            
            //重新判断选择的图片
            for(int i = 0;i < [ReturnImg count];i++)
            {
                PhotoModel *photo = ReturnImg[i];
                
                if (photo.isSelect) {
                    
                    //去重
                    BOOL isbool = [weakSelf.imgViewArr_small containsObject:photo];
                    
                    if (!isbool) {
                        [weakSelf.imgViewArr_small addObject:photo];
                    }
                }
                else
                {
                    BOOL isbool = [weakSelf.imgViewArr_small containsObject:photo];
                    
                    if (isbool) {
                        [weakSelf.imgViewArr_small removeObject:photo];
                    }
                }
            }
            
            //先移除再加载
            [weakSelf.scroll removeFromSuperview];
            [weakSelf loadScroll];
            
            weakSelf.ImgCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)[weakSelf.imgViewArr_small count]];
            
            //先移除再加载,避免footer重影
            [weakSelf.selectorLab removeFromSuperview];
            [weakSelf.collectionView reloadData];
        };
        
        [self.navigationController pushViewController:brower animated:YES];
    }
    else
    {
        [self selectPhotoAtIndex:indexPath.row];
    }
    
}

#pragma mark delegate回传数组，用于Brower页面回跳Home页面回传值
-(void) ReturnPhotoToPicker:(NSMutableArray *) Photos
{
    [self.PickerDelegate ReturnPhotoToHome:Photos];
}

#pragma mark 小圆点动画
-(void)roundAnimation:(UILabel *)label
{
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.7;
    
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    animation.values = values;
    [label.layer addAnimation:animation forKey:nil];
}

@end
