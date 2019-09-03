//
//  ViewController.m
//  video
//
//  Created by kouqingwei on 2019/8/18.
//  Copyright © 2019 xs. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "PlayerProgressView.h"
#import "Utilities.h"

typedef NS_ENUM(NSInteger, PlayerState) {
    PlayerStateFailed,     // 播放失败
    PlayerStateBuffering,  // 缓冲中
    PlayerStatePlaying,    // 播放中
    PlayerStateStopped,    // 停止播放
    PlayerStatePause,       // 暂停播放
    PlayerStateEnd         // 播放完成
};

@interface ViewController ()<AVAssetResourceLoaderDelegate>

@property(strong,nonatomic)UILabel *currentLabel;

@property(strong,nonatomic)UILabel *totalLabel;

@property(strong,nonatomic)UIImageView *imageView;

@property(strong,nonatomic)UIView *contollView;

@property(strong,nonatomic)PlayerProgressView *progressView;

/*播放器999*/
@property(nonatomic,strong)AVPlayer *player;

/**playerLayer*/
@property (nonatomic,strong)AVPlayerLayer *playerLayer;

/**播放器item*/
@property (nonatomic, strong)AVPlayerItem *playerItem;

/**/
@property (nonatomic, strong)AVPlayerItemVideoOutput *videoOutPut;


@property (nonatomic, assign)NSInteger playState;


@property (nonatomic, strong)id timeObserve;//定时观察者

@end

@implementation ViewController

-(void)last
{
    [self removeObserver];
    if (self.playerLayer) {
        [self.playerLayer removeFromSuperlayer];
    }
    if (self.player) {
        [self.player pause];
    }
    self.playerLayer = nil;
    self.player = nil;
    self.playerItem = nil;
    
    //
    self.playerItem =[AVPlayerItem playerItemWithAsset:[AVURLAsset assetWithURL:[NSURL URLWithString:@"http://wvideo.spriteapp.cn/video/2016/0328/56f8ec01d9bfe_wpd.mp4"]]];
    
    self.player =[AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.videoGravity =  AVLayerVideoGravityResizeAspect;
    [self addObserver];
}

-(void)next
{
    [self removeObserver];
    if (self.playerLayer) {
        [self.playerLayer removeFromSuperlayer];
    }
    if (self.player) {
        [self.player pause];
    }
    self.playerLayer = nil;
    self.player = nil;
    self.playerItem = nil;
    
    //
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ww" ofType:@"mp4"];
    self.playerItem =[AVPlayerItem playerItemWithAsset:[AVAsset assetWithURL:[NSURL fileURLWithPath:path]]];
    
    self.player =[AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.videoGravity =  AVLayerVideoGravityResizeAspect;
    [self addObserver];
}

-(void)createUI
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(60,0,60,20)];
    [btn setTitle:@"忘我" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *lastbtn = [[UIButton alloc] initWithFrame:CGRectMake(0,0,60,20)];
    [lastbtn setTitle:@"蝙蝠侠" forState:UIControlStateNormal];
    [lastbtn addTarget:self action:@selector(last) forControlEvents:UIControlEventTouchUpInside];
    //
    UIView *rightView = [UIView new];
    rightView.frame= CGRectMake(0, 0, btn.frame.size.width*2, btn.frame.size.height);
    [rightView addSubview:btn];
    [rightView addSubview:lastbtn];
    self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc] initWithCustomView:rightView];
}

-(UILabel *)currentLabel{
    
    if (!_currentLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.backgroundColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"00:00";
        label.font = [UIFont systemFontOfSize:10];
        label.frame = CGRectMake(10, self.contollView.frame.origin.y+self.contollView.frame.size.height+12.5, 40, 20);
        _currentLabel = label;
    }
    return _currentLabel;
}

-(UILabel *)totalLabel{
    
    if (!_totalLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.backgroundColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"00:00";
        label.font = [UIFont systemFontOfSize:10];
        label.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 10 - 40, self.contollView.frame.origin.y+self.contollView.frame.size.height+12.5, 40, 20);
        _totalLabel = label;
    }
    return _totalLabel;
}

-(UIView *)contollView{
    
    if (!_contollView) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor cyanColor];
        view.frame = CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 200);
        _contollView = view;
    }
    return _contollView;
}

-(UIImageView *)imageView{
    
    if (!_imageView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.backgroundColor = [UIColor cyanColor];
        imageView.frame = CGRectMake(40, 350, [UIScreen mainScreen].bounds.size.width - 80, 200);
        _imageView = imageView;
    }
    return _imageView;
}

-(PlayerProgressView *)progressView
{
    if (!_progressView) {
        PlayerProgressView *progressV = [[PlayerProgressView alloc] init];
        progressV.backgroundColor = [UIColor yellowColor];
        progressV.frame = CGRectMake(60, self.contollView.frame.origin.y+self.contollView.frame.size.height+20, self.contollView.frame.size.width - 120, 5);
        progressV.cacheProgressTintColor = [UIColor purpleColor];
        progressV.playProgressTintColor = [UIColor redColor];
        progressV.minHitTestSize = CGSizeMake(60, 40);
        progressV.cacheValue = 0.0;
        progressV.playValue = 0.0;
        progressV.sliderBtnMoveEnded = ^(float value){
            
            __weak __typeof(&*self)weakSelf = self;
            
            CGFloat duration = CMTimeGetSeconds([weakSelf.player.currentItem duration]);
            int time = duration * value;
            
            [weakSelf seekToTime:time completionHandler:nil];
        };
        progressV.sliderBtnMoving = ^(float value){
            
            __weak __typeof(&*self)weakSelf = self;
            
            CGFloat duration = CMTimeGetSeconds([weakSelf.player.currentItem duration]);
            int time = duration * value;
            
            NSInteger MM = time/60;
            NSInteger SS = (NSInteger)time%60;
            weakSelf.currentLabel.text = [NSString stringWithFormat:@"%.2ld:%.2ld",MM,SS];
        };
        _progressView = progressV;
    }
    return _progressView;
}

-(void)addObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
    
    [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [_playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    //缓冲区空了，需要等待数据
    [_playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    //缓冲区有足够数据可以播放了
    [_playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    
    
    __weak typeof(self) weakSelf = self;
    
    //添加系统观察者，观察播放进度
    self.timeObserve = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1) queue:nil usingBlock:^(CMTime time){
        
        AVPlayerItem *currentItem = weakSelf.playerItem;
        NSArray *loadedRanges = currentItem.seekableTimeRanges;
        
        if (loadedRanges.count > 0 && currentItem.duration.timescale != 0) {
            
            //
            if (currentItem.duration.timescale <= 0) {
                return;
            }
            CGFloat totalTime = (CGFloat)currentItem.duration.value / currentItem.duration.timescale;
            if (totalTime <= 0) {
                return;
            }
            
            CGFloat value = CMTimeGetSeconds([currentItem currentTime]) / totalTime;

            //更新播放进度，注意滑动不更新
            if (!weakSelf.progressView.sliderIsMoveing) {
                
                weakSelf.progressView.playValue = value;

                NSInteger currentTime = (NSInteger)CMTimeGetSeconds([currentItem currentTime]);
                NSInteger time = (NSInteger)CMTimeGetSeconds(currentItem.duration);
                
                NSInteger MM = currentTime/60;
                NSInteger SS = (NSInteger)currentTime%60;
                weakSelf.currentLabel.text = [NSString stringWithFormat:@"%.2ld:%.2ld",MM,SS];

                NSInteger TMM = time/60;
                NSInteger TSS = (NSInteger)time%60;
                weakSelf.totalLabel.text = [NSString stringWithFormat:@"%.2ld:%.2ld",TMM,TSS];
                
                //
                //[weakSelf getCurrentImage];
            }
        }
    }];
}

#pragma mark---KVO ---
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if (object == _playerItem) {
        
        if ([keyPath isEqualToString:@"status"]) {
            
            if (_playerItem.status == AVPlayerItemStatusReadyToPlay){
                
                self.playState = PlayerStatePlaying;
                
                //
                self.playerLayer.frame = self.contollView.bounds;
                [self.contollView.layer insertSublayer:self.playerLayer atIndex:0];
                //
            }
        }
        if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
            
            // 计算缓冲进度
            NSTimeInterval timeInterval = [self availableDuration];
            CMTime duration = self.playerItem.duration;
            NSTimeInterval totalDuration = CMTimeGetSeconds(duration);//获取视频总长度
            if (isnan(timeInterval)) {
                timeInterval = 0;
            }
            //
            if (!isnan(timeInterval / totalDuration)) {
                self.progressView.cacheValue  =  timeInterval / totalDuration;
            }
            
        }
        if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
            
            // 当缓冲是空的时候
            if (self.playerItem.playbackBufferEmpty) {
                [self bufferingSomeSecond];
            }
            
        }
        if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
            
            //当缓冲好的时候
            self.playState = PlayerStatePlaying;
            [self.player play];
            
        }
    }
}

- (NSTimeInterval)availableDuration {
    
    NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges];
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds        = CMTimeGetSeconds(timeRange.start);
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result     = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

- (void)bufferingSomeSecond
{
    self.playState = PlayerStateBuffering;
    //playbackBufferEmpty会反复进入，因此在bufferingOneSecond延时播放执行完之前再调用bufferingSomeSecond都忽略
    __block BOOL isBuffering = NO;
    if (isBuffering) return;
    isBuffering = YES;
    
    //需要先暂停一小会之后再播放，否则网络状况不好的时候时间在走，声音播放不出来
    [self.player pause];
    
    __weak __typeof(&*self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        weakSelf.playState  = PlayerStatePlaying;
        //如果执行了play还是没有播放则说明还没有缓存好，则再次缓存一段时间
        isBuffering = NO;
        if (!weakSelf.playerItem.isPlaybackLikelyToKeepUp) {
            [weakSelf bufferingSomeSecond];
        }
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
    [self.view addSubview:self.contollView];
    [self.view addSubview:self.progressView];
    [self.view addSubview:self.currentLabel];
    [self.view addSubview:self.totalLabel];
    [self.view addSubview:self.imageView];
    
    //
    [self removeObserver];
    if (self.playerLayer) {
        [self.playerLayer removeFromSuperlayer];
    }
    if (self.player) {
        [self.player pause];
    }
    self.playerLayer = nil;
    self.player = nil;
    self.playerItem = nil;
    
    //NSString *path = [[NSBundle mainBundle] pathForResource:@"ww" ofType:@"mp4"];
    //self.playerItem =[AVPlayerItem playerItemWithAsset:[AVAsset assetWithURL:[NSURL fileURLWithPath:path]]];
    //self.videoOutPut = [[AVPlayerItemVideoOutput alloc] init];
    //[self.playerItem addOutput:_videoOutPut];
    
    AVURLAsset *set = [AVURLAsset assetWithURL:[NSURL URLWithString:@"ggggggg:http://wvideo.spriteapp.cn/video/2016/0328/56f8ec01d9bfe_wpd.mp4"]];
    [set.resourceLoader setDelegate:self queue:dispatch_get_main_queue()];
    
    
    self.playerItem =[AVPlayerItem playerItemWithAsset:set];
    self.player =[AVPlayer playerWithPlayerItem:_playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.videoGravity =  AVLayerVideoGravityResizeAspect;
    [self addObserver];
}

-(void)removeObserver{
    
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    if (self.timeObserve) {
        self.timeObserve = nil;
    }
}


- (void)seekToTime:(NSInteger)dragedSeconds completionHandler:(void (^)(BOOL finished))completionHandler
{
    __weak __typeof(&*self)weakSelf = self;
    
    if (weakSelf.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        // seekTime:completionHandler:不能精确定位
        // 如果需要精确定位，可以使用seekToTime:toleranceBefore:toleranceAfter:completionHandler:
        // 转换成CMTime才能给player来控制播放进度
        
        [weakSelf.player pause];
        weakSelf.playState = PlayerStateBuffering;
        CMTime dragedCMTime = CMTimeMake(dragedSeconds, 1); //kCMTimeZero
        
        [weakSelf.player seekToTime:dragedCMTime toleranceBefore:CMTimeMake(1,1) toleranceAfter:CMTimeMake(1,1) completionHandler:^(BOOL finished) {
            
            // 视频跳转回调
            if (completionHandler) {
                completionHandler(finished);
            }
            
            [weakSelf.player play];
            weakSelf.progressView.sliderIsMoveing = NO;
            
            
            if (!weakSelf.playerItem.isPlaybackLikelyToKeepUp ){
                weakSelf.playState = PlayerStateBuffering;
            }else{
                weakSelf.playState = PlayerStatePlaying;
            }
        }];
    }
}


-(void)moviePlayDidEnd:(NSNotification *)noti{
    
}

#pragma mark-
-(void)getCurrentImage {
    
    //CMTime itemTime = _player.currentItem.currentTime;
    
    CVPixelBufferRef pixelBuffer = [_videoOutPut copyPixelBufferForItemTime:kCMTimeZero itemTimeForDisplay:nil];
    
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    
    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    
    CGImageRef videoImage = [temporaryContext
                             
                             createCGImage:ciImage
                             
                             fromRect:CGRectMake(0, 0,
                                                 
                                                 CVPixelBufferGetWidth(pixelBuffer),
                                                 
                                                 CVPixelBufferGetHeight(pixelBuffer))];
    
    
    //当前帧的画面
    UIImage *currentImage = [UIImage imageWithCGImage:videoImage];
    if (!currentImage) {
        return;
    }
    
    CGImageRelease(videoImage);
    
    self.imageView.frame = CGRectMake(self.imageView.frame.origin.x, self.imageView.frame.origin.y, self.imageView.frame.size.width, self.imageView.frame.size.width*(currentImage.size.height/currentImage.size.width));
    self.imageView.image = currentImage;
}

#pragma mark- AVAssetResourceLoaderDelegate
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest
{
    return YES;
}

@end
