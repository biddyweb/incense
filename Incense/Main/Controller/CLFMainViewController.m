//
//  ViewController.m
//  Incense
//
//  Created by CaiGavin on 8/10/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//



#warning - TODO: 音频修改
#warning - TODO: 文案修改
#warning - TODO: appid 修改

#warning - TODO: MusicList 显示方式修改
#warning - TODO: 统一下...用宏

// #warning - DONE: 添加了评分功能?
// #warning - DONE: Intro 页面修改
// #warning - DONE: pageControl 也许需要自定义,以修改小点的图片为句号
// #warning - DONE: 燃烧支数的位置要调整
// #warning - DONE: 不同设备 cloud 的高度
// #warning - DONE: 第一次进入程序 锁屏等会出问题
// #warning - DONE: 进入后台关闭录音/ 似乎录音和本地通知有冲突...后台录音本地通知就没声音?
// #warning - DONE: 在 Intro 页面切到后台会崩溃

#import "CLFMainViewController.h"
#import "CLFCloud.h"
#import "CLFIncenseView.h"
#import "BMWaveMaker.h"
#import "Waver.h"
#import "UIImage+animatedGIF.h"
#import "CLFMathTools.h"
#import "CLFMusicPlayView.h"
#import "CLFEndView.h"

@interface CLFMainViewController () <CLFCloudDelegate, CLFIncenseViewDelegate, CLFEndViewDelegate, UICollisionBehaviorDelegate>

@property (nonatomic, weak)   UIImageView            *incenseShadowView;
@property (nonatomic, weak)   CLFCloud               *cloud;
@property (nonatomic, weak)   UIImageView            *smoke;
@property (nonatomic, weak)   UIImageView            *fire;

@property (nonatomic, weak)   UIView                 *rippleView;
@property (nonatomic, strong) BMWaveMaker            *rippleMaker;

@property (nonatomic, weak)   CLFEndView             *endView;

@property (nonatomic, weak)   CLFMusicPlayView       *musicView;
@property (nonatomic, strong) NSTimer                *musicTimer;

@property (nonatomic, weak)   UITapGestureRecognizer *tap;

@end

CATransform3D CATransform3DMakePerspective(CGPoint center, float disZ) {
    CATransform3D transToCenter = CATransform3DMakeTranslation(-center.x, -center.y, 0);
    CATransform3D transBack = CATransform3DMakeTranslation(center.x, center.y, 0);
    CATransform3D scale = CATransform3DIdentity;
    scale.m34 = -1.0f / disZ;
    return CATransform3DConcat(CATransform3DConcat(transToCenter, scale), transBack);
}

CATransform3D CATransform3DPerspect(CATransform3D t, CGPoint center, float disZ) {
    return CATransform3DConcat(t, CATransform3DMakePerspective(center, disZ));
}


@implementation CLFMainViewController

static CGFloat   screenWidth;
static CGFloat   screenHeight;
static CGFloat   sizeRatio;
static CGFloat   incenseLocation;

static CGFloat   cloudLocation = -380.0f;
static CGFloat   smokeLocation = -520.0f;
static CGFloat   animationTime = 4.0f;

static const CGFloat kWaverVoiceFactor = 10.0f;
static const CGFloat kFireVoiceFactor = 40.0f;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor colorWithRed:231 / 255.0f green:231 / 255.0f blue:231 / 255.0f alpha:1.0f];
        self.burning = NO;
        if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
            [self prefersStatusBarHidden];
            [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    screenWidth = [UIScreen mainScreen].bounds.size.width;
    screenHeight = [UIScreen mainScreen].bounds.size.height;
    sizeRatio = screenHeight / 667.0f;
    incenseLocation = (screenHeight - 200 * sizeRatio) * 0.3;
    
    [self makeIncense];
    [self makeCloud];

    [self makeRipple];
    [self makeMusicView];
    
    self.smoke.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) + 50);
    [self fireAppearInSky];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - LightTheIncense

- (void)lightTheIncense {
    NSLog(@"lightTheIncense");
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMusicView)];
    [self.view addGestureRecognizer:tapRecognizer];
    self.tap = tapRecognizer;
    
    self.burning = YES;
    [self setupRecorder];
    __block AVAudioRecorder *weakRecorder = self.recorder;
    self.incenseView.waver.waverLevelCallback = ^(Waver *waver) {
        [weakRecorder updateMeters];
        CGFloat normalizedValue = pow (10, [weakRecorder averagePowerForChannel:0] / kWaverVoiceFactor);
        waver.level = normalizedValue;
    };
    
    [self timeFlow];
    
    self.fire.alpha = 1.0f;
    self.cloud.cloudImageView.alpha = 1.0f;
    [UIView animateWithDuration:4.0f animations:^{
        self.cloud.cloudImageView.alpha = 0.0f;
        self.incenseView.incenseHeadView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        [self.cloud removeFromSuperview];
    }];

    [UIView animateWithDuration:5.0f animations:^{
        self.fire.alpha = 0.0f;
        self.incenseView.waver.alpha = 1.0f;

    } completion:^(BOOL finished) {
        [self.fire removeFromSuperview];

    }];
}

- (void)timeFlow {
    NSLog(@"start %@", [NSDate date]);
    __block AVAudioRecorder *weakRecorder = self.recorder;
    
    //    [self.incenseView.waver makeWaveLines]; delete
    
    self.incenseView.brightnessCallback = ^(CLFIncenseView *incense) {
        [weakRecorder updateMeters];
        CGFloat normalizedValue = pow (10, [weakRecorder averagePowerForChannel:0] / kFireVoiceFactor);
        incense.brightnessLevel = normalizedValue;
        //        incense.waver.level = normalizedValue;
        smokeLocation += 0.64 * sizeRatio;
        self.smoke.frame = CGRectMake(0, smokeLocation, screenWidth, 520);
    };
}

- (void)incenseDidBurnOff {
    NSLog(@"End %@", [NSDate date]);
    [self.view removeGestureRecognizer:self.tap];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger burntIncenseNumber = [defaults integerForKey:@"burntIncenseNumber"];
    
    if (burntIncenseNumber) {
        burntIncenseNumber++;
    } else {
        burntIncenseNumber = 1;
    }
    
    [defaults setInteger:burntIncenseNumber forKey:@"burntIncenseNumber"];
    
    [self.endView setupWithBurntOffNumber:[CLFMathTools numberToChinese:burntIncenseNumber]];
    
    self.burning = NO;
    [self.rippleMaker stopWave]; // shadow 要隐藏
    
    [self.musicView stopPlayMusic];
    
    if (self.musicView.show) {
        [self showMusicView];
    }

    [UIView animateWithDuration:2.0f animations:^{
        self.incenseView.waver.alpha = 0.0f;
        self.incenseView.incenseHeadView.alpha = 0.0f;
        self.rippleView.alpha = 0.3f;
    } completion:^(BOOL finished) {
        self.endView.alpha = 0.0f;
        [UIView animateWithDuration:0.5f animations:^{
            self.endView.alpha = 1.0f;
            self.rippleView.alpha = 0.0f;
            self.musicView.hidden = YES;
        }];
    }];
    
    [self.recorder stop];
    [self.incenseView.waver.displaylink invalidate];
    [self.incenseView.displaylink invalidate];
}

- (void)incenseDidBurnOffForALongTime {
    [self.view removeGestureRecognizer:self.tap];
    self.burning = NO;
    self.musicView.hidden = YES;
    [self.rippleMaker stopWave];
    [self.musicView stopPlayMusic];
    self.incenseView.waver.alpha = 0.0f;
    self.incenseView.incenseHeadView.alpha = 0.0f;
    [self.recorder stop];
    [self stopFloating];
    [self showFailure];
    [self.incenseView.waver.displaylink invalidate];
    [self.incenseView.displaylink invalidate];
}

#pragma mark - Finished

- (CLFEndView *)endView {
    if (!_endView) {
        CLFEndView *endView = [[CLFEndView alloc] init];
        endView.frame = self.view.frame;
        endView.alpha = 0.0f;
        endView.delegate = self;
        [self.view addSubview:endView];
        _endView = endView;
    }
    return _endView;
}

- (void)showFailure {
    [self.endView setupWithFailure];
    self.endView.alpha = 1.0f;
}

- (void)oneMoreIncense {
    NSLog(@"oneMoreIncense");
    smokeLocation = -520.0f;
    cloudLocation = -380.0f;
    [UIView animateWithDuration:3.0f animations:^{
        self.smoke.frame = self.smoke.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) + 50);
        self.endView.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
        
        [self.endView removeFromSuperview];
        [self.incenseView removeFromSuperview];
        self.incenseView = nil;
        self.incenseShadowView.alpha = 1.0f;
        
        self.musicView.hidden = NO;
        [self makeIncense];
        [self makeCloud];
        [self makeRipple];
        
        [self fireAppearInSky];
    }];
}

#pragma mark - Incense

- (CLFIncenseView *)incenseView {
    if (!_incenseView) {
        CLFIncenseView *incenseView = [[CLFIncenseView alloc] init];
        incenseView.backgroundColor = [UIColor clearColor];
        incenseView.delegate = self;
        [self.view insertSubview:incenseView belowSubview:self.smoke];
        _incenseView = incenseView;
    }
    return _incenseView;
}

- (UIImageView *)incenseShadowView {
    if (!_incenseShadowView) {
        UIImageView *incenseShadowView = [[UIImageView alloc] init];
        incenseShadowView.image = [UIImage imageNamed:@"影"];
        [self.view addSubview:incenseShadowView];
        _incenseShadowView = incenseShadowView;
    }
    return _incenseShadowView;
}

- (void)makeIncense {
    [self.incenseView initialSetup];

    self.incenseView.frame = CGRectMake(0, screenHeight - incenseLocation - 200, screenWidth, 200 * sizeRatio);
    self.incenseView.waver.alpha = 0.0f;
    self.incenseView.incenseHeadView.alpha = 0.0f;
    
    self.incenseShadowView.frame = CGRectMake((screenWidth - 6) / 2, screenHeight - incenseLocation + 10, 6, 3);
    
    [self floating];
}


#pragma mark - floatingAnimation

- (void)floating {
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animation];
    anim.keyPath = @"position.y";
    anim.repeatCount = 1500;
    anim.values = @[@(screenHeight - incenseLocation + 5), @(screenHeight - incenseLocation), @(screenHeight - incenseLocation + 5)];
    anim.duration = animationTime;
    anim.removedOnCompletion = NO;
    anim.fillMode = kCAFillModeForwards;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    self.incenseView.layer.position = CGPointMake(0, screenHeight - incenseLocation);
    self.incenseView.layer.anchorPoint = CGPointMake(0, 1);
    [self.incenseView.layer addAnimation:anim forKey:nil];
    
    NSValue *bounds1 = [NSValue valueWithCGRect:CGRectMake(0, 0, 6, 3)];
    NSValue *bounds2 = [NSValue valueWithCGRect:CGRectMake(0, 0, 3, 1.5)];
    
    CAKeyframeAnimation *shadowAnim = [CAKeyframeAnimation animation];
    shadowAnim.keyPath = @"bounds";
    shadowAnim.repeatCount = 1500;
    shadowAnim.values = @[bounds1, bounds2, bounds1];
    shadowAnim.duration = animationTime;
    shadowAnim.removedOnCompletion = NO;
    shadowAnim.fillMode = kCAFillModeForwards;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    self.incenseShadowView.layer.position = CGPointMake(screenWidth * 0.5, screenHeight - incenseLocation + 10);
    self.incenseShadowView.layer.anchorPoint = CGPointMake(0.5, 0.5);
    [self.incenseShadowView.layer addAnimation:shadowAnim forKey:nil];
}

- (void)stopFloating {
    [self.incenseView.layer removeAllAnimations];
    [self.incenseShadowView.layer removeAllAnimations];
    
    self.incenseView.layer.position = CGPointMake(0, screenHeight - incenseLocation);
    self.incenseView.layer.anchorPoint = CGPointMake(0, 1);
}

#pragma mark - Smoke

- (UIImageView *)smoke {
    if (!_smoke) {
        UIImageView *smoke = [[UIImageView alloc] init];
        smoke.image = [UIImage imageNamed:@"云雾"];
        smoke.alpha = 1.0f;
        smoke.frame = CGRectMake(0, smokeLocation, screenWidth, 520);
        [self.view addSubview:smoke];
        _smoke = smoke;
    }
    return _smoke;
}

- (void)renewSmokeStatusWithTimeHaveGone:(CGFloat)leaveBackInterval {
    smokeLocation += 0.32 * sizeRatio * leaveBackInterval * 7.5;
}

#pragma mark - Cloud

- (CLFCloud *)cloud {
    if (!_cloud) {
        CLFCloud *cloud = [[CLFCloud alloc] init];
        cloud.userInteractionEnabled = NO;
        cloud.delegate = self;
        [self.view addSubview:cloud];
        _cloud = cloud;
    }
    return _cloud;
}

- (void)makeCloud {
    self.cloud.alpha = 1.0f;
    self.cloud.dragEnable = YES;
    self.cloud.frame = CGRectMake(0, cloudLocation, screenWidth, 380 + 140 * sizeRatio); // 也许要换成1042
}

- (void)cloudRebound {
    [UIView animateKeyframesWithDuration:1.0f delay:0.0f options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        self.cloud.frame = CGRectMake(0, cloudLocation, screenWidth, 380 + 140 * sizeRatio);
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - Fire

- (UIImageView *)fire {
    if (!_fire) {
        UIImageView *fire = [[UIImageView alloc] init];
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"Fire" withExtension:@"gif"];
        fire.image = [UIImage animatedImageWithAnimatedGIFURL:url];
        self.cloud.cloudImageView.alpha = 1.0f;
        [self.cloud addSubview:fire];
        _fire = fire;
    }
    return _fire;
}

- (void)makeFire {
    CGFloat fireW = 18;
    CGFloat fireH = 24;
    self.fire.alpha = 0.0f;
    self.fire.frame = CGRectMake((screenWidth - fireW) / 2, (CGRectGetHeight(self.cloud.frame) - 80), fireW, fireH);
    [UIView animateWithDuration:0.5f animations:^{
        self.fire.alpha = 1.0f;
    } completion:^(BOOL finished) {
        self.cloud.userInteractionEnabled = YES;
    }];
}

- (void)fireAppearInSky {
    [UIView animateWithDuration:2.0f animations:^{
        self.smoke.frame = CGRectMake(0, -440 , screenWidth, 520); // 用 -440 是为了让火焰的出现更自然
    } completion:^(BOOL finished) {
        [self makeFire];
        self.smoke.frame = CGRectMake(0, smokeLocation , screenWidth, 520);
    }];
}

#pragma mark - Ripple

- (UIView *)rippleView {
    if (!_rippleView) {
        UIView *rippleView = [[UIView alloc] init];
        rippleView.frame = CGRectMake(0, screenHeight - incenseLocation - 80, screenWidth, 180);
        rippleView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:rippleView];
        _rippleView = rippleView;
    }
    return _rippleView;
}

- (void)makeRipple {
    self.rippleView.alpha = 1.0f;

    self.rippleMaker.animationView = self.rippleView;
    [self.rippleMaker spanWaveContinuallyWithTimeInterval:animationTime];
    CATransform3D rotate = CATransform3DMakeRotation(M_PI / 3, 1, 0, 0);
    self.rippleView.layer.transform = CATransform3DPerspect(rotate, CGPointMake(0, 0), 200);
}

- (BMWaveMaker *)rippleMaker {
    if (!_rippleMaker) {
        _rippleMaker = [[BMWaveMaker alloc] init];
        _rippleMaker.spanScale = 80.0f;
        _rippleMaker.originRadius = 0.9f;
        _rippleMaker.waveColor = [UIColor whiteColor];
        _rippleMaker.animationDuration = 20.0f;
        _rippleMaker.wavePathWidth = 1.5f;
    }
    return _rippleMaker;
}

#pragma mark - About Audio

- (CLFMusicPlayView *)musicView {
    if (!_musicView) {
        CLFMusicPlayView *musicView = [[CLFMusicPlayView alloc] init];
        musicView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:musicView];
        _musicView = musicView;
    }
    return _musicView;
}

- (void)makeMusicView {
    self.musicView.frame = CGRectMake(0, screenHeight - 60, screenWidth, 120);
    self.musicView.show = NO;
    self.musicView.hidden = NO;
}

- (void)showMusicView {
    [self.musicView showMusicButtons];
    if (self.musicView.show) {
        self.musicTimer = [NSTimer scheduledTimerWithTimeInterval:6.0f target:self selector:@selector(showMusicView) userInfo:nil repeats:NO];
    } else {
        [self.musicTimer invalidate];
    }
}

- (void)setupRecorder {
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    
    NSDictionary *settings = @{AVSampleRateKey:          [NSNumber numberWithFloat: 44100.0],
                               AVFormatIDKey:            [NSNumber numberWithInt: kAudioFormatAppleLossless],
                               AVNumberOfChannelsKey:    [NSNumber numberWithInt: 2],
                               AVEncoderAudioQualityKey: [NSNumber numberWithInt: AVAudioQualityMin]};
    
    NSError *error;
    self.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    
    if (error) {
        NSLog(@"Ups, could not create recorder %@", error);
        return;
    }
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    
    if (error) {
        NSLog(@"Error setting category: %@", [error description]);
    }
    
    [self.recorder prepareToRecord];
    [self.recorder setMeteringEnabled:YES];
    [self.recorder record];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
