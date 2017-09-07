//
//  PhotoBrower.m
//  PhotosTest
//
//  Created by Scofield on 17/9/5.
//  Copyright © 2017年 谢航. All rights reserved.
//

#import "PhotoBrower.h"
#import "UIView+CGRect.h"
#import "PhotoBrowerCell.h"
#import "PhotoModel.h"

@interface PhotoBrower ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *picBrowse;
@property (nonatomic, assign) NSInteger        numberOfItems;

@property (nonatomic,   copy) NSArray *photoData;

@property (nonatomic, assign) NSInteger scrollIndex;

@property (strong, nonatomic) UIView *nav;
@property (strong, nonatomic) UILabel *CountPhoto;

@property (strong, nonatomic) UIView *BottomView;
@property (strong, nonatomic) UILabel *HighQuality;//是否原图
@property (strong, nonatomic) UILabel *ImgCount; //选择的图片数lab

@property (strong, nonatomic) UIButton *choose_btn;
@property (copy, nonatomic) NSMutableArray *selectorPic; //选择图片array

@property (strong, nonatomic) UIButton *isHighQuality;//是否原图按钮
@property (copy, nonatomic) NSString *PhotoSize; //图片大小

@end

@implementation PhotoBrower

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.hidden = YES;
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    self.navigationController.navigationBar.hidden = NO;
}

-(void) getPhotos:(NSArray *)photos andIndex:(NSInteger)index
{
    _photoData = [NSArray new];
    _photoData = photos;
    _scrollIndex = index;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _selectorPic = [NSMutableArray new];
    
    //初始化选择按钮状态
    for (int i = 0; i < [_photoData count]; i++) {
        PhotoModel *photo = _photoData[i];
        
        if (photo.isSelect) {
            [_selectorPic addObject:photo];
        }
    }
    
    [self loadMainView];
    [self loadNav];
    [self loadBottom];
}

-(void) loadNav
{
    _nav = [UIView new];
    _nav.frame = CGRectMake(0, 0, ScreenWidth, 64);
    _nav.backgroundColor = XHColor(redColor);
    [self.view addSubview:_nav];
    
    UIButton *back_btn = [[UIButton alloc]initWithFrame:CGRectMake(15, 20 + (44-25)/2, 25, 25)];
    [back_btn setImage:[UIImage imageNamed:@"nav_back.png"] forState:UIControlStateNormal];
    [back_btn addTarget:self action:@selector(backItemMethod) forControlEvents:UIControlEventTouchUpInside];
    [_nav addSubview:back_btn];
    
    _choose_btn = [[UIButton alloc]initWithFrame:CGRectMake(WIDTH(_nav) - 40, Y(back_btn), WIDTH(back_btn), HEIGHT(back_btn))];
    [_choose_btn setImage:[UIImage imageNamed:@"Choose_nor.png"] forState:UIControlStateNormal];
    [_choose_btn setImage:[UIImage imageNamed:@"Choose_sel.png"] forState:UIControlStateSelected];
    [_choose_btn addTarget:self action:@selector(ChooseMethod:) forControlEvents:UIControlEventTouchUpInside];
    [_nav addSubview:_choose_btn];
    
    _CountPhoto = [UILabel new];
    _CountPhoto.frame = CGRectMake((WIDTH(_nav) -200)/2, Y(back_btn), 200, 25);
    _CountPhoto.textColor = XHColor(whiteColor);
    _CountPhoto.textAlignment = NSTextAlignmentCenter;
    _CountPhoto.text = [NSString stringWithFormat:@"%ld/%lu",(long)_scrollIndex+1,(unsigned long)[_photoData count]];
    [_nav addSubview:_CountPhoto];
    
    PhotoModel *photo = _photoData[_scrollIndex];
    if (photo.isSelect) {
        _choose_btn.selected = YES;
    }
}

#pragma mark 选择图片
-(void) ChooseMethod:(UIButton *)bt
{
    PhotoModel *photo = _photoData[_scrollIndex];
    
    if (bt.selected) {
        bt.selected = NO;
        photo.isSelect = NO;
        
        [_selectorPic removeObject:photo];
    }
    else
    {
        bt.selected = YES;
        photo.isSelect = YES;
        
        [_selectorPic addObject:photo];
    }
    
    _ImgCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)[_selectorPic count]];
}

#pragma mark 返回
-(void)backItemMethod
{
    if (self.PhotoBlock) {
        self.PhotoBlock([NSArray arrayWithArray:_photoData]);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) loadBottom
{
    _BottomView = [UIView new];
    _BottomView.frame = CGRectMake(0, ScreenHeight - 40*ScreenHeight_scale, ScreenWidth, 40*ScreenHeight_scale);
    _BottomView.backgroundColor = XHColor(blackColor);
    _BottomView.userInteractionEnabled = YES;
    [self.view addSubview:_BottomView];
    
    _isHighQuality = [UIButton buttonWithType:UIButtonTypeCustom];
    _isHighQuality.CustomFrame = CGRectMake(10, (40-20)/2, 20, 20);
    _isHighQuality.layer.masksToBounds = YES;
    _isHighQuality.layer.cornerRadius = _isHighQuality.bounds.size.height/2;
    _isHighQuality.layer.borderColor = XHColor(lightGrayColor).CGColor;
    _isHighQuality.layer.borderWidth = 2;
    [_isHighQuality setImage:XHImage(@"point_black.png") forState:UIControlStateNormal];
    [_isHighQuality setImage:XHImage(@"point_green.png") forState:UIControlStateSelected];
    [_isHighQuality addTarget:self action:@selector(isHighQuality:) forControlEvents:UIControlEventTouchUpInside];
    [_BottomView addSubview:_isHighQuality];
    
    _HighQuality = [UILabel new];
    _HighQuality.CustomFrame = CGRectMake(25+15, (40-20)/2, 120, 20);
    _HighQuality.text = @"原图";
    _HighQuality.textColor = XHColor(whiteColor);
    _HighQuality.font = XHFont(14);
    [_BottomView addSubview:_HighQuality];
    
    UIButton *done = [UIButton buttonWithType:UIButtonTypeCustom];
    done.CustomFrame = CGRectMake(375 - 60, 0, 60, 40);
    [done setTitle:@"完成" forState:UIControlStateNormal];
    done.titleLabel.font = XHFont(14);
    [done setTitleColor:XHRGB(1, 200, 75, 1) forState:UIControlStateNormal];
    [done addTarget:self action:@selector(Done) forControlEvents:UIControlEventTouchUpInside];
    [_BottomView addSubview:done];
    
    _ImgCount = [UILabel new];
    _ImgCount.CustomFrame = CGRectMake(375-70, 5, 20, 20);
    _ImgCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)[_selectorPic count]];
    _ImgCount.textAlignment = NSTextAlignmentCenter;
    _ImgCount.font = XHFont(8);
    _ImgCount.textColor = XHColor(whiteColor);
    _ImgCount.backgroundColor = XHRGB(1, 200, 75, 1);
    _ImgCount.layer.masksToBounds = YES;
    _ImgCount.layer.cornerRadius = _ImgCount.bounds.size.height/2;
    [_BottomView addSubview:_ImgCount];
}

-(void) isHighQuality:(UIButton *)bt
{
    if (bt.selected) {
        bt.selected = NO;
        _HighQuality.text = @"原图";
    }
    else
    {
        bt.selected = YES;
        _HighQuality.text = [NSString stringWithFormat:@"原图(%@)",_PhotoSize];
    }
}

#pragma mark 完成按钮
-(void) Done
{
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    NSMutableArray *ReturnPic = [NSMutableArray new];
    
    //pop回主页时取消掉图片的选择状态，因为主页要用到这个状态来判定是否删除图片
    for (PhotoModel *model in _selectorPic) {
        model.isSelect = NO;
        [ReturnPic addObject:model];
    }
    
    [self.BrowerDelegate ReturnPhotoToPicker:ReturnPic];
}

-(void) loadMainView
{
    self.edgesForExtendedLayout = UIRectEdgeNone;
    /*
     *   创建核心内容 UICollectionView
     */
    self.view.backgroundColor = [UIColor blackColor];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = (CGSize){ScreenWidth,ScreenHeight};
    flowLayout.minimumLineSpacing = 0.0f;
    
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    _picBrowse = [[UICollectionView alloc] initWithFrame:CGRectMake(0,0, ScreenWidth, ScreenHeight) collectionViewLayout:flowLayout];
    _picBrowse.backgroundColor = [UIColor clearColor];
    _picBrowse.pagingEnabled = YES;
    
    _picBrowse.bounces = NO;
    _picBrowse.showsHorizontalScrollIndicator = NO;
    _picBrowse.showsVerticalScrollIndicator = NO;
    [_picBrowse registerClass:[PhotoBrowerCell class] forCellWithReuseIdentifier:NSStringFromClass([PhotoBrowerCell class])];
    _picBrowse.dataSource = self;
    _picBrowse.delegate = self;
    _picBrowse.translatesAutoresizingMaskIntoConstraints = NO;
    _picBrowse.userInteractionEnabled = YES;
    [self.view addSubview:_picBrowse];
    
    UITapGestureRecognizer *singleFingerOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleFingerEvent)];
    
    [_picBrowse addGestureRecognizer:singleFingerOne];
    
    //滚动到指定位置
    [_picBrowse scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_scrollIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:NO];
}

-(void) handleSingleFingerEvent
{
    _nav.hidden = !_nav.hidden;
    _BottomView.hidden = !_BottomView.hidden;
}

#pragma mark --- UICollectionviewDelegate or dataSource
-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _photoData.count;
}

-(UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoBrowerCell *browerCell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([PhotoBrowerCell class]) forIndexPath:indexPath];
    
    if ([[_photoData objectAtIndex:indexPath.row] isKindOfClass:[PhotoModel class]]) {
        //加载相册中的数据时实用
        PhotoModel *photo = [_photoData objectAtIndex:indexPath.row];
        [browerCell loadPHAssetItemForPics:photo];
        
        _ImgCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)[_selectorPic count]];
        _PhotoSize = photo.asset_Size;
        
    }
    
    return browerCell;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    NSInteger num = targetContentOffset->x / _picBrowse.frame.size.width;
    
    _scrollIndex = num;
    
    _CountPhoto.text = [NSString stringWithFormat:@"%ld/%lu",_scrollIndex+1,(unsigned long)[_photoData count]];
    
    PhotoModel *photo = [_photoData objectAtIndex:_scrollIndex];
    
    _PhotoSize = photo.asset_Size;
    
    if (_isHighQuality.selected) {
        _HighQuality.text = [NSString stringWithFormat:@"原图(%@)",_PhotoSize];
    }
    else
    {
        _HighQuality.text = @"原图";
    }
    
    if (photo.isSelect) {
        _choose_btn.selected = YES;
    }
    else
    {
        _choose_btn.selected = NO;
    }
}

@end
