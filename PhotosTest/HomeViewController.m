//
//  HomeViewController.m
//  PhotosTest
//
//  Created by Scofield on 17/9/5.
//  Copyright © 2017年 谢航. All rights reserved.
//

#import "HomeViewController.h"
#import "PhotoPicker.h"
#import "UpdatePhotoCell.h"
#import "UIView+CGRect.h"

#import "VideoModel.h" //播放视频模式

#import "UpdataReusableHead.h"

static NSString *const cellId = @"cellId";

static NSString *const headId = @"headId";

@interface HomeViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,PhotoPickerDelegate>

@property (strong, nonatomic) UICollectionView *collectionView;
@property (copy, nonatomic) NSMutableArray *ImageArr; //图片
@property (copy, nonatomic) NSMutableArray *VideoArr; //视频

@property (assign, nonatomic) BOOL isPhotoModel; //判断是否为相机模式

@property (strong, nonatomic) UIView  *TopView;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"自定义相册";
    
    _ImageArr = [NSMutableArray new];
    _VideoArr = [NSMutableArray new];
    
    _TopView = [UIView new];
    _TopView.CustomFrame = CGRectMake(0, 0, 375, 40);
    _TopView.backgroundColor = XHColor(orangeColor);
    [self.view addSubview:_TopView];
    
    NSArray *name = @[@"Photo",@"Video"];
    
    for (int i = 0; i < 2; i++) {
        UIButton *bt = [UIButton buttonWithType:UIButtonTypeCustom];
        bt.frame = CGRectMake(i*WIDTH(_TopView)/2 , 0, WIDTH(_TopView)/2, HEIGHT(_TopView));
        bt.tag = 300 + i;
        [bt setTitle:name[i] forState:UIControlStateNormal];
        [bt addTarget:self action:@selector(TouchBT:) forControlEvents:UIControlEventTouchUpInside];
        [_TopView addSubview:bt];
    }
    
    [self loadUpdatePhotos];
}

#pragma mark 添加图片、视频
-(void) TouchBT:(UIButton *)bt
{
    switch (bt.tag) {
        case 300:
            _isPhotoModel = YES;
            [self setAlertCameraTitle:@"拍照" PhotoTitle:@"相册" alertTitle:@"选择相册"];
            break;
        case 301:
            _isPhotoModel = NO;
            [self setAlertCameraTitle:@"录像" PhotoTitle:@"本地视频" alertTitle:@"选择视频"];
            break;
        default:
            break;
    }
    
}

-(void) setAlertCameraTitle:(NSString *)CT PhotoTitle:(NSString *)PT alertTitle:(NSString *)AT
{
    __weak __typeof(self) weakSelf = self;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:AT message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
    
    // 判断是否支持相机
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertAction *cameraAc = [UIAlertAction actionWithTitle:CT style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertController addAction:cameraAc];
    }
    
    // 图集
    UIAlertAction *photoAc = [UIAlertAction actionWithTitle:PT style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
        //相册权限判断
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusDenied)
        {
            //相册权限未开启
            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
            // app名称
            NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
            
            [weakSelf SetAlertWithTitle:@"提醒" andMessage:[NSString stringWithFormat:@"请在iPhone的“设置->隐私->照片”开启%@访问你的手机相册",app_Name]];
            
        }
        else if(status == PHAuthorizationStatusNotDetermined)
        {
            //相册进行授权
            /* * * 第一次安装应用时直接进行这个判断进行授权 * * */
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status)
            {
                //授权后直接打开照片库
                if (status == PHAuthorizationStatusAuthorized)
                {
                    dispatch_async(dispatch_get_main_queue(), ^
                    {
                        [weakSelf pushViewController];
                    });
                    
                }
            }];
        }
        else if (status == PHAuthorizationStatusAuthorized)
        {
            [weakSelf pushViewController];
        }
        
    }];
    [alertController addAction:photoAc];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertController addAction:cancel];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark 跳转
-(void) pushViewController
{
    NSString *message = nil;
    NSInteger count = 0;
    PhotoPicker *vc = [PhotoPicker new];
    
    if (_isPhotoModel)
    {
        vc.isPhotoModel = YES;
        message = @"最多只能传9张图片";
        count = 9;
    }
    else
    {
        vc.isPhotoModel = NO;
        message = @"最多只能传5个视频";
        count = 5;
    }
    
    vc.PickerDelegate = self;
    
    vc.PhotoBlock = ^(id responseObject){
        
        if (_isPhotoModel)
        {
            if ([_ImageArr count] < count)
            {
                [_ImageArr addObjectsFromArray:(NSArray *)responseObject];
                
                if ([_ImageArr count] > count)
                {
                    [_ImageArr removeObjectsInArray:(NSArray *)responseObject];
                    [self SetAlertWithTitle:nil andMessage:message];
                }
                else
                {
                    [_collectionView reloadData];
                }
            }
            else
            {
                [self SetAlertWithTitle:nil andMessage:message];
            }
        }
        else
        {
            if ([_VideoArr count] < count) {
                [_VideoArr addObjectsFromArray:(NSArray *)responseObject];
                
                if ([_VideoArr count] > count) {
                    [_VideoArr removeObjectsInArray:(NSArray *)responseObject];
                    [self SetAlertWithTitle:nil andMessage:message];
                }
                else
                {
                    [_collectionView reloadData];
                }
            }
            else
            {
                [self SetAlertWithTitle:nil andMessage:message];
            }
        }
        
    };
    
    [self.navigationController pushViewController:vc animated:NO];
}
#pragma mark Brower页面回调数组
-(void) ReturnPhotoToHome:(NSMutableArray *) Photos
{
    if ([_ImageArr count] < 9) {
        [_ImageArr addObjectsFromArray:(NSArray *)Photos];
        
        if ([_ImageArr count] > 9) {
            [_ImageArr removeObjectsInArray:(NSArray *)Photos];
            [self SetAlertWithTitle:nil andMessage:@"最多只能传9张图片"];
        }
        else
        {
            [_collectionView reloadData];
        }
        
    }
    else
    {
        [self SetAlertWithTitle:nil andMessage:@"最多只能传9张图片"];
    }
}

#pragma mark 回调展示页面
-(void) loadUpdatePhotos
{
    UICollectionViewFlowLayout *collectionFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,BOTTOM(_TopView),WIDTH(self.view),HeightFromBottom(self.view, _TopView) -64) collectionViewLayout:collectionFlowLayout];
    
    _collectionView.backgroundColor = self.view.backgroundColor;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [self.view addSubview:_collectionView];
    
    // 注册cell、sectionHeader、sectionFooter
    [_collectionView registerClass:[UpdatePhotoCell class] forCellWithReuseIdentifier:cellId];
    
    [_collectionView registerClass:[UpdataReusableHead class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headId];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGSize SectionSize = CGSizeMake(0, 0.1);
    
    switch (section) {
        case 0:
            if ([_ImageArr count] != 0) {
                SectionSize = CGSizeMake(0, 20);
            }
            break;
        case 1:
            if ([_VideoArr count] != 0) {
                SectionSize = CGSizeMake(0, 20);
            }
            break;
        default:
            break;
    }
    
    return SectionSize;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    NSArray *name = @[@"图片",@"视频"];
    
    UpdataReusableHead *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headId forIndexPath:indexPath];
    headerView.backgroundColor = self.view.backgroundColor;
    
    headerView.SectionLab.text = name[indexPath.section];
    
    switch (indexPath.section) {
        case 0:
            if ([_ImageArr count] == 0) {
                headerView.SectionLab.hidden = YES;
            }
            else
            {
                headerView.SectionLab.hidden = NO;
            }
            break;
        case 1:
            if ([_VideoArr count] == 0) {
                headerView.SectionLab.hidden = YES;
            }
            else
            {
                headerView.SectionLab.hidden = NO;
            }
            break;
        default:
            break;
    }
    
    return headerView;
}

#pragma mark section数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return (CGSize){(WIDTH(self.view) - 8*10)/4,(WIDTH(self.view) - 8*10)/4};
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

#pragma mark ---- UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = 0;
    
    switch (section) {
        case 0:
            count = [_ImageArr count];
            break;
        case 1:
            count = [_VideoArr count];
            break;
        default:
            break;
    }
    
    return count;
}

#pragma mark cell内容
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    UpdatePhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    
    switch (indexPath.section) {
        case 0:
            [cell loadPhotoData:_ImageArr[indexPath.row] withTargetSize:CGSizeMake(120,150)];
            break;
        case 1:
            [cell loadPhotoData:_VideoArr[indexPath.row] withTargetSize:CGSizeMake(120,150)];
            break;
        default:
            break;
    }
    
    
    
    [cell.DeleteImg addTarget:self action:@selector(DeleteImg:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.backgroundColor = [UIColor whiteColor];
    
    return cell;
}

#pragma mark
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoModel *photo = [PhotoModel new];
    
    switch (indexPath.section) {
        case 0:
            photo = _ImageArr[indexPath.row];
            break;
        case 1:
            photo = _VideoArr[indexPath.row];
            break;
            
        default:
            break;
    }
    
    if (photo.isPhotoModel) {
        
        UpdatePhotoCell *cell = (UpdatePhotoCell *)[collectionView cellForItemAtIndexPath:indexPath];
        cell.DeleteImg.hidden = !cell.DeleteImg.hidden;
    }
    else
    {
        //视频
        VideoModel *video = [VideoModel new];
        [video getVideo:photo];
        video.hidesBottomBarWhenPushed = YES;
        video.DeleteBlock = ^(BOOL isDelete){
            if (isDelete) {
                [_VideoArr removeObject:photo];
                
                [_collectionView reloadData];
            }
        };
        [self.navigationController pushViewController:video animated:YES];
        
    }
}

#pragma mark 删除图片
-(void) DeleteImg:(UIButton *)bt
{
    UpdatePhotoCell *cell = (UpdatePhotoCell *)[bt superview];
    
    NSIndexPath *IndexPath = [_collectionView indexPathForCell:cell];
    
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"" message:@"要删除该图片吗？" preferredStyle:UIAlertControllerStyleAlert];
    [alertView addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        cell.DeleteImg.hidden = YES;
        [_ImageArr removeObject:_ImageArr[IndexPath.row]];
        
        [_collectionView reloadData];
    }]];
    [alertView addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [self presentViewController:alertView animated:true completion:nil];
}

#pragma mark 提交
-(void) GoPublic
{
    
}

#pragma mark 弹出提示框
-(void) SetAlertWithTitle:(NSString *)title andMessage:(NSString *)message
{
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertView addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [self presentViewController:alertView animated:true completion:nil];
}

@end
