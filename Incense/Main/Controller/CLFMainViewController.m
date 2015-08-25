//
//  ViewController.m
//  Incense
//
//  Created by CaiGavin on 8/10/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//



#warning - TODO: 音频修改

#warning - TODO: 文案修改

#warning - TODO: 菜单？诗词？

#warning - TODO: Appid 修改

#warning - TODO: Music List 鸟字 有一点会露出来 图片要重做

#import "CLFMainViewController.h"
#import "CLFCloud.h"
#import "CLFIncenseView.h"
#import "BMWaveMaker.h"
#import "Waver.h"
#import "UIImage+animatedGIF.h"
#import "CLFMathTools.h"
#import "CLFMusicPlayView.h"
#import "CLFAudioPlayView.h"
#import "CLFEndView.h"
#import "CLFIncenseCommonHeader.h"

@interface CLFMainViewController () <CLFCloudDelegate, CLFIncenseViewDelegate, CLFEndViewDelegate, UICollisionBehaviorDelegate>

@property (nonatomic, weak)   UIImageView            *incenseShadowView;
@property (nonatomic, weak)   CLFCloud               *cloud;
@property (nonatomic, weak)   UIImageView            *smoke;
@property (nonatomic, strong) UIImageView            *fire;

@property (nonatomic, weak)   UIView                 *rippleView;
@property (nonatomic, strong) BMWaveMaker            *rippleMaker;

@property (nonatomic, weak)   CLFEndView             *endView;

@property (nonatomic, weak)   CLFAudioPlayView       *audioView;
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

static CGFloat   cloudLocation = -380.0f;
static CGFloat   smokeLocation = -520.0f;
static CGFloat   animationTime = 4.0f;
static CGFloat   smokeChangeRate = 0.0f;

static const CGFloat kWaverVoiceFactor = 10.0f;
static const CGFloat kFireVoiceFactor = 40.0f;
static const CGFloat kMusicListStyle = 1;

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
    
    smokeChangeRate = (cloudLocation - smokeLocation) / (1.0f * (Incense_Burn_Off_Time * (60 / 20.0f)));
    
    [self makeIncense];
    [self makeCloud];

    [self makeRipple];
    
    if (!kMusicListStyle) {
        [self makeMusicView];
    } else {
        [self makeAudioView];
    }
    
    self.smoke.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) + 50);
    [self fireAppearInSky];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - LightTheIncense

/**
 *  light the incense. 
 *  1. Add a tapGestureRecognizer to allow user to choose white noises.
 *  2. Setup and Recorder so that the light of incense can interactive with users by voice.
 *  3. Cloud and fire would disapear gradually
 *  4. Time goes by
 */
- (void)lightTheIncense {
    NSLog(@"lightTheIncense");
    
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
        [self.cloud removeFromSuperview]; // --> 此处 fire 被释放了
    }];

    [UIView animateWithDuration:5.0f animations:^{
        self.fire.alpha = 0.0f;  // --> 此处创建了 cloud ????
        self.incenseView.waver.alpha = 1.0f;
        self.audioView.alpha = 1.0f;

    } completion:^(BOOL finished) {
        [self.fire removeFromSuperview];
        
        UITapGestureRecognizer *tapRecognizer = kMusicListStyle ? [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showAudioView)] : [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMusicView)];
        [self.view addGestureRecognizer:tapRecognizer];
        self.tap = tapRecognizer;
        
        if (kMusicListStyle) {
            self.audioView.userInteractionEnabled = YES;
        }
    }];
}

/**
 *  Time goes by, incense would be shorter and smoke of incense ('waver' in this program) and smoke in sky would be longer and thicker.
 */

- (void)timeFlow {
    NSLog(@"start %@", [NSDate date]);
    __block AVAudioRecorder *weakRecorder = self.recorder;
    
    self.incenseView.brightnessCallback = ^(CLFIncenseView *incense) {
        [weakRecorder updateMeters];
        CGFloat normalizedValue = pow (10, [weakRecorder averagePowerForChannel:0] / kFireVoiceFactor);
        incense.brightnessLevel = normalizedValue;
        smokeLocation += smokeChangeRate * Size_Ratio_To_iPhone6;
        self.smoke.frame = CGRectMake(0, smokeLocation, Incense_Screen_Width, 520);
    };
}

/**
 *  incense burnt off in normal way. Increase the burnt off number, stop the audio player/recorder and show a normal endView.
 */

- (void)calculateBurntIncenseNumber {
    
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
//    [self.rippleMaker stopWave];
    
    if (!kMusicListStyle) {
        [self.musicView stopPlayMusic];
        if (self.musicView.show) {
            [self showMusicView];
        }
    } else {
        [self.audioView stopPlayAudio];
        self.audioView.userInteractionEnabled = NO;
        if (self.audioView.show) {
            [self showAudioView];
        }
    }

    [UIView animateWithDuration:2.0f animations:^{
        self.incenseView.waver.alpha = 0.0f;
        self.incenseView.incenseHeadView.alpha = 0.0f;
//        self.rippleView.alpha = 0.3f;
        self.audioView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        self.endView.alpha = 0.0f;
        [UIView animateWithDuration:0.5f animations:^{
            self.endView.alpha = 1.0f;
//            self.rippleView.alpha = 0.0f;
            
            if (!kMusicListStyle) {
                self.musicView.hidden = YES;
            } else {
//                self.audioView.hidden = YES;
            }

        }];
    }];
    
    [self.recorder stop];
    [self.incenseView.waver.displaylink invalidate];
    [self.incenseView.displaylink invalidate];
}


/**
 *  If the user ignored the alert, show a incompletely burnt incense.
 */


- (void)incenseDidBurnOffFromBackgroundWithResult:(NSString *)resultString {
    [self.view removeGestureRecognizer:self.tap];
    self.burning = NO;
    
    if (!kMusicListStyle) {
        self.musicView.hidden = YES;
        [self.musicView stopPlayMusic];
    } else {
//        self.audioView.hidden = YES;
        self.audioView.userInteractionEnabled = NO;
        [self.audioView stopPlayAudio];
    }
    
//    [self.rippleMaker stopWave];
    self.audioView.alpha = 0.0f;
    self.incenseView.waver.alpha = 0.0f;
    self.incenseView.incenseHeadView.alpha = 0.0f;
    self.incenseView.lightView.alpha = 0.0f;
    [self.recorder stop];
    [self stopFloating];
    
    if ([resultString isEqualToString:@"failure"]) {
       [self showFailure];
    } else {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSInteger burntIncenseNumber = [defaults integerForKey:@"burntIncenseNumber"];
        
        if (burntIncenseNumber) {
            burntIncenseNumber++;
        } else {
            burntIncenseNumber = 1;
        }
        
        [defaults setInteger:burntIncenseNumber forKey:@"burntIncenseNumber"];
        
        [self.endView setupWithBurntOffNumber:[CLFMathTools numberToChinese:burntIncenseNumber]];
        self.endView.alpha = 1.0f;
    }
    
    [self.incenseView.waver.displaylink invalidate];
    [self.incenseView.displaylink invalidate];
}

#pragma mark - Finished

- (CLFEndView *)endView {
    if (!_endView) {
        CLFEndView *endView = [[CLFEndView alloc] init];
        endView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
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


/**
 *  Make a new incense for users.
 */
- (void)oneMoreIncense {
    NSLog(@"oneMoreIncense");

    NSLog(@"self.view.subviews %@", self.view.subviews);
    
    [self.view bringSubviewToFront:self.smoke];
    self.smoke.layer.zPosition = 101;

    
    smokeLocation = -520.0f;
    cloudLocation = -380.0f;
    [UIView animateWithDuration:3.0f animations:^{
        self.smoke.frame = self.smoke.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) + 50);
        self.endView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        
        [self.endView removeFromSuperview];
        self.endView = nil;
        [self.incenseView removeFromSuperview];
        self.incenseView = nil;
        self.incenseShadowView.alpha = 1.0f;
        
        if (!kMusicListStyle) {
            self.musicView.hidden = NO;
        } else {
            self.audioView.hidden = NO;
        }
        
        [self makeIncense];
        [self makeCloud];
        [self makeRipple];
        
        [self fireAppearInSky];
    }];
}

#pragma mark - Incense

/**
 *  Make incense and the shadow above ripple.
 *
 */

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

    self.incenseView.frame = CGRectMake(0, Incense_Screen_Height - Incense_Location - 200, Incense_Screen_Width, 200 * Size_Ratio_To_iPhone6);
    self.incenseView.waver.alpha = 0.0f;
    self.incenseView.incenseHeadView.alpha = 0.0f;
    
    self.incenseShadowView.frame = CGRectMake((Incense_Screen_Width - 6) / 2, Incense_Screen_Height - Incense_Location + 10, 6, 3);
    
    [self floating];
}


#pragma mark - floatingAnimation

/**
 *  Make incense floating above the ripple, and the shadow should react to the floating.
 */

- (void)floating {
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animation];
    anim.keyPath = @"position.y";
    anim.repeatCount = 1500;
    anim.values = @[@(Incense_Screen_Height - Incense_Location + 5), @(Incense_Screen_Height - Incense_Location), @(Incense_Screen_Height - Incense_Location + 5)];
    anim.duration = animationTime;
    anim.removedOnCompletion = NO;
    anim.fillMode = kCAFillModeForwards;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    self.incenseView.layer.position = CGPointMake(0, Incense_Screen_Height - Incense_Location);
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
    
    self.incenseShadowView.layer.position = CGPointMake(Incense_Screen_Width * 0.5, Incense_Screen_Height - Incense_Location + 10);
    self.incenseShadowView.layer.anchorPoint = CGPointMake(0.5, 0.5);
    [self.incenseShadowView.layer addAnimation:shadowAnim forKey:nil];
}

- (void)stopFloating {
    [self.incenseView.layer removeAllAnimations];
    [self.incenseShadowView.layer removeAllAnimations];
    
    self.incenseView.layer.position = CGPointMake(0, Incense_Screen_Height - Incense_Location);
    self.incenseView.layer.anchorPoint = CGPointMake(0, 1);
}

#pragma mark - Smoke

/**
 *  Smoke here means the smoke in the sky. It's also used for transition.
 */

- (UIImageView *)smoke {
    if (!_smoke) {
        UIImageView *smoke = [[UIImageView alloc] init];
        smoke.image = [UIImage imageNamed:@"云雾"];
        smoke.alpha = 1.0f;
        smoke.frame = CGRectMake(0, smokeLocation, Incense_Screen_Width, 520);
        [self.view addSubview:smoke];
        _smoke = smoke;
    }
    return _smoke;
}

- (void)renewSmokeStatusWithTimeHaveGone:(CGFloat)leaveBackInterval {
    
    smokeLocation += smokeChangeRate * Size_Ratio_To_iPhone6 * leaveBackInterval * 3;
}

#pragma mark - Cloud

/**
 *  Cloud exists before the incense is burnt. After the incense being lighted, cloud would disappear with fire.
 */

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
    self.cloud.frame = CGRectMake(0, cloudLocation, Incense_Screen_Width, 380 + 140 * Size_Ratio_To_iPhone6); // 也许要换成1042
}

- (void)cloudRebound {
    [UIView animateKeyframesWithDuration:1.0f delay:0.0f options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        self.cloud.frame = CGRectMake(0, cloudLocation, Incense_Screen_Width, 380 + 140 * Size_Ratio_To_iPhone6);
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - Fire

/**
 *  Locating on cloud, which used to light the incense (but in this program, whether the incense lighted is determined by the position of cloud).
 */

- (UIImageView *)fire {
    if (!_fire) {
        UIImageView *fire = [[UIImageView alloc] init];
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"Fire" withExtension:@"gif"];
        fire.image = [UIImage animatedImageWithAnimatedGIFURL:url];
        _fire = fire;
    }
    return _fire;
}

- (void)makeFire {
    self.cloud.cloudImageView.alpha = 1.0f;
    [self.cloud addSubview:self.fire];
    CGFloat fireW = 18;
    CGFloat fireH = 24;
    self.fire.alpha = 0.0f;
    self.fire.frame = CGRectMake((Incense_Screen_Width - fireW) / 2, (CGRectGetHeight(self.cloud.frame) - 80), fireW, fireH);
    [UIView animateWithDuration:0.5f animations:^{
        self.fire.alpha = 1.0f;
    } completion:^(BOOL finished) {
        self.cloud.userInteractionEnabled = YES;
    }];
}

- (void)fireAppearInSky {
    [UIView animateWithDuration:1.0f animations:^{
        self.smoke.frame = CGRectMake(0, -440 , Incense_Screen_Width, 520); // 用 -440 是为了让火焰的出现更自然
    } completion:^(BOOL finished) {
        [self makeFire];
        self.smoke.frame = CGRectMake(0, smokeLocation , Incense_Screen_Width, 520);
        self.smoke.layer.zPosition = 0;
    }];
}

#pragma mark - Ripple

/**
 *  eeeeeeee..........Ripple.
 */

- (UIView *)rippleView {
    if (!_rippleView) {
        UIView *rippleView = [[UIView alloc] init];
        rippleView.frame = CGRectMake(0, Incense_Screen_Height - Incense_Location - 80, Incense_Screen_Width, 180);
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
        _rippleMaker.spanScale = 100.0f;
        _rippleMaker.originRadius = 0.9f;
        _rippleMaker.waveColor = [UIColor whiteColor];
        _rippleMaker.animationDuration = 30.0f;
        _rippleMaker.wavePathWidth = 1.5f;
    }
    return _rippleMaker;
}

#pragma mark - About Audio

/**
 *  audioView and musicView have the same function but different styles. we can switch between audioView and musicView by setting kMusicListStyle.
 *
 */

- (CLFAudioPlayView *)audioView {
    if (!_audioView) {
        CLFAudioPlayView *audioView = [[CLFAudioPlayView alloc] init];
        audioView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:audioView];
        _audioView = audioView;
    }
    return _audioView;
}

- (void)makeAudioView {
    self.audioView.userInteractionEnabled = NO;
    self.audioView.frame = CGRectMake(0, Incense_Screen_Height - 60, Incense_Screen_Width, 40);
    self.audioView.show = NO;
    self.audioView.alpha = 0.0f;
}

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
    self.musicView.frame = CGRectMake(0, Incense_Screen_Height - 60, Incense_Screen_Width, 120);
    self.musicView.show = NO;
    self.musicView.hidden = NO;
}

- (void)showMusicView {
    [self.musicView showMusicButtons];
}

- (void)showAudioView {
        NSLog(@"kkkkkkkkkk");
    [self.audioView showAudioButtons];
}

- (void)setupRecorder {
    NSLog(@"setupRecorder");
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
        
    [self.recorder prepareToRecord];
    [self.recorder setMeteringEnabled:YES];
    [self.recorder record];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
