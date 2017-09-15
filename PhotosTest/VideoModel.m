//
//  VideoModel.m
//  PhotosTest
//
//  Created by Scofield on 17/9/5.
//  Copyright © 2017年 谢航. All rights reserved.
//

#import "VideoModel.h"

#import "AVPlayerView.h"
#import "UIView+CGRect.h"
@interface VideoModel ()

@property(nonatomic,strong) PhotoModel *photo;
@property (strong, nonatomic) UIImageView *PlayImg;
@property (strong, nonatomic) AVPlayerView *playerview;
@property (assign, nonatomic) BOOL isPlay;

@end

@implementation VideoModel

-(void) getVideo:(PhotoModel *)photo
{
    _photo = photo;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _isPlay = NO;
    
    //导航栏button
    UIButton * rightbutton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,60,44)];
    [rightbutton setTitle:@"删除" forState:UIControlStateNormal];
    [rightbutton addTarget:self action:@selector(DeleteVideo) forControlEvents:UIControlEventTouchUpInside];
    [rightbutton setTitleColor:XHColor(redColor) forState:UIControlStateNormal];
    UIBarButtonItem *rightitem = [[UIBarButtonItem alloc] initWithCustomView:rightbutton];
    self.navigationItem.rightBarButtonItem = rightitem;
    
    [self loadMainView];
}

-(void) loadMainView
{
    AVPlayerItem *item=[AVPlayerItem playerItemWithAsset:_photo.asset_video];
    
    AVPlayer *player=[[AVPlayer alloc]init];
    
    [player replaceCurrentItemWithPlayerItem:item];
    player.usesExternalPlaybackWhileExternalScreenIsActive=YES;
    
    AVPlayerLayer *playerLayer=[[AVPlayerLayer alloc]init];
    playerLayer.backgroundColor=[UIColor blackColor].CGColor;
    playerLayer.player = player;
    playerLayer.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    [playerLayer displayIfNeeded];
    [self.view.layer insertSublayer:playerLayer atIndex:0];
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:player.currentItem];
    
    //视频
    _playerview = [[AVPlayerView alloc] init];
    
    _playerview.player = playerLayer.player;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(PlayOrPause)];
    [self.view addGestureRecognizer:singleTap];
    self.view.userInteractionEnabled = YES;
    
    [self.view addSubview:_playerview];
    
    _PlayImg = [UIImageView new];
    _PlayImg.frame = CGRectMake((WIDTH(playerLayer) - 30*ScreenWidth_scale)/2, (HEIGHT(playerLayer) - 30*ScreenWidth_scale)/2, 30*ScreenWidth_scale, 30*ScreenWidth_scale);
    _PlayImg.image = XHImage(@"start_white.png");
    [self.view addSubview:_PlayImg];
}

-(void)playbackFinished:(NSNotification *)not
{
    // 播放完成后重复播放
    // 跳到最新的时间点开始播放
    [_playerview.player seekToTime:CMTimeMake(0, 1)];
    _PlayImg.hidden = NO;
    _isPlay = NO;
}

-(void) PlayOrPause
{
    if (_isPlay == NO)
    {
        _isPlay = YES;
        _PlayImg.hidden = YES;
        [_playerview.player play];
        
        
    }
    else
    {
        _isPlay = NO;
        _PlayImg.hidden = NO;
        [_playerview.player pause];
    }
}

-(void) DeleteVideo
{
    self.DeleteBlock(YES);
    [self.navigationController popViewControllerAnimated:YES];
}

@end
