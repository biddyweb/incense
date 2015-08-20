//
//  ViewController.m
//  Incense
//
//  Created by CaiGavin on 8/10/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "CLFMainViewController.h"
#import "CLFCloud.h"
#import "CLFIncenseView.h"
#import "Masonry.h"
#import <AVFoundation/AVFoundation.h>
#import "BMWaveMaker.h"
#import <QuartzCore/QuartzCore.h>
#import "Waver.h"
#import "UIImage+animatedGIF.h"
#import "CLFMathTools.h"

@interface CLFMainViewController () <CLFCloudDelegate, CLFIncenseViewDelegate, UICollisionBehaviorDelegate>

@property (nonatomic, weak)   UIImageView           *incenseShadowView;
@property (nonatomic, weak)   CLFCloud              *cloud;
@property (nonatomic, weak)   UIImageView           *smoke;
@property (nonatomic, weak)   UIImageView           *fire;

@property (nonatomic, strong) AVAudioRecorder       *recorder;
@property (nonatomic, weak)   UIView                *rippleView;
@property (nonatomic, strong) BMWaveMaker           *rippleMaker;

@property (nonatomic, weak)   UIView                *finishedView;
@property (nonatomic, weak)   UIView                *failureView;

@property (nonatomic, strong) UIDynamicAnimator     *animator;
@property (nonatomic, weak)   UIDynamicItemBehavior *itemBehavior;

@property (nonatomic, strong) NSArray               *burntIncenseNumberArray;

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

- (instancetype)init
{
    self = [super init];
    if (self) {
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
    [self makeFire];
    [self makeRipple];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - LightTheIncense

- (void)lightTheIncense {
    NSLog(@"lightTheIncense");
    self.burning = YES;
    self.itemBehavior.resistance = 0;
    [self.animator removeAllBehaviors];
    [self.itemBehavior removeItem:self.fire];
    self.animator = nil;
    self.itemBehavior = nil;
    
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
        self.incenseView.waver.alpha = 1.0f;
    }];

    [UIView animateWithDuration:5.0f animations:^{
        self.fire.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self.fire removeFromSuperview];

    }];
}

- (void)timeFlow {
    NSLog(@"start %@", [NSDate date]);
    __block AVAudioRecorder *weakRecorder = self.recorder;
    
//    [self.incenseView.waver makeWaveLines];
    
    self.incenseView.brightnessCallback = ^(CLFIncenseView *incense) {
        [weakRecorder updateMeters];
        CGFloat normalizedValue = pow (10, [weakRecorder averagePowerForChannel:0] / kFireVoiceFactor);
        incense.brightnessLevel = normalizedValue;
//        incense.waver.level = normalizedValue;
        smokeLocation += 0.32 * sizeRatio;
        self.smoke.frame = CGRectMake(0, smokeLocation, screenWidth, 520);
    };
}

- (void)incenseDidBurnOff {
    NSLog(@"End %@", [NSDate date]);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger burntIncenseNumber = [defaults integerForKey:@"burntIncenseNumber"];
    
    if (burntIncenseNumber) {
        burntIncenseNumber++;
    } else {
        burntIncenseNumber = 1;
    }
    
    [defaults setInteger:burntIncenseNumber forKey:@"burntIncenseNumber"];
    
    self.burntIncenseNumberArray = [CLFMathTools digitInInteger:burntIncenseNumber];
    
    self.burning = NO;
//    [self.rippleMaker stopWave];

    [UIView animateWithDuration:2.0f animations:^{
        self.incenseView.waver.alpha = 0.0f;
        self.incenseView.incenseHeadView.alpha = 0.0f;
//        self.rippleView.alpha = 0.3f;
    } completion:^(BOOL finished) {
        self.finishedView.alpha = 0.0f;
            [UIView animateWithDuration:0.5f animations:^{
                self.finishedView.alpha = 1.0f;
//                self.rippleView.alpha = 0.0f;
            }];
    }];
    
    [self.recorder stop];
    [self.incenseView.waver.displaylink invalidate];
    [self.incenseView.displaylink invalidate];
}

- (void)incenseDidBurnOffForALongTime {
    [self.rippleMaker stopWave];
    self.incenseShadowView.alpha = 0.0f;
    self.incenseView.waver.alpha = 0.0f;
    self.incenseView.incenseHeadView.alpha = 0.0f;
    [self.recorder stop];
//    self.blurView.alpha = 1.0f;
    [self stopFloating];
    [self showFailure];
    [self.incenseView.waver.displaylink invalidate];
    [self.incenseView.displaylink invalidate];

}

- (UIView *)failureView {
    if (!_failureView) {
        //        UIImage *blurImage = [[self takeSnapshotOfView:self.view] applyBlurWithRadius:10 tintColor:[UIColor colorWithWhite:1.0f alpha:0.7f] saturationDeltaFactor:1.0 maskImage:nil];
        //        UIImageView *blurView = [[UIImageView alloc] initWithImage:blurImage];
        NSLog(@"failure");
        UIView *failureView = [[UIView alloc] init];
        failureView.backgroundColor = [UIColor clearColor];
        failureView.frame = self.view.frame;
        
        [self.view addSubview:failureView];
        
        UIButton *failureButton = [[UIButton alloc] init];
        [failureView addSubview:failureButton];
        failureButton.frame = CGRectMake((screenWidth - 22) * 0.5, screenHeight * 0.25 - 44, 22, 44);
        failureButton.contentMode = UIViewContentModeTop;
        failureButton.backgroundColor = [UIColor clearColor];
        [failureButton setImage:[UIImage imageNamed:@"灭"] forState:UIControlStateNormal];
        
        
        UIButton *restartButton = [[UIButton alloc] init];
        [failureView addSubview:restartButton];
        restartButton.frame = CGRectMake((screenWidth - 22) * 0.5, screenHeight * 0.875, 23, 23);
        restartButton.contentMode = UIViewContentModeTop;
        restartButton.backgroundColor = [UIColor clearColor];
        [restartButton addTarget:self action:@selector(oneMoreIncense) forControlEvents:UIControlEventTouchUpInside];
        [restartButton setImage:[UIImage imageNamed:@"否"] forState:UIControlStateNormal];

        
        _failureView = failureView;
    }
    return _failureView;
}


- (void)showFailure {
    self.failureView.alpha = 1.0f;
}

#pragma mark - Incense

- (CLFIncenseView *)incenseView {
    if (!_incenseView) {
        CLFIncenseView *incenseView = [[CLFIncenseView alloc] init];
        incenseView.backgroundColor = [UIColor clearColor];
        incenseView.delegate = self;
        [self.view addSubview:incenseView];
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
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
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
    self.incenseShadowView.layer.position = CGPointMake(screenWidth / 2, screenHeight - incenseLocation + 10);
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
        smoke.frame = CGRectMake(0, cloudLocation, screenWidth, 520);
        [self.view addSubview:smoke];
        _smoke = smoke;
    }
    return _smoke;
}

#pragma mark - Cloud

- (CLFCloud *)cloud {
    if (!_cloud) {
        CLFCloud *cloud = [[CLFCloud alloc] init];
        cloud.delegate = self;
        [self.view addSubview:cloud];
        _cloud = cloud;
    }
    return _cloud;
}

- (void)makeCloud {
    self.cloud.alpha = 1.0f;
    self.cloud.dragEnable = YES;
    self.cloud.frame = CGRectMake(0, cloudLocation, screenWidth, 520); // 也许要换成1042
}

- (void)cloudRebound {
//    [UIView animateWithDuration:1.0f
//                          delay:0.0f
//         usingSpringWithDamping:1.0f
//          initialSpringVelocity:10.0f
//                        options:UIViewAnimationOptionCurveEaseInOut
//                     animations:^{
//                         self.cloud.frame = CGRectMake(0, cloudLocation, screenWidth, 520);
//                     }
//                     completion:^(BOOL finished) {
//                         
//                     }];
    
    [UIView animateKeyframesWithDuration:1.0f delay:0.0f options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        self.cloud.frame = CGRectMake(0, cloudLocation, screenWidth, 520);
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
    self.fire.alpha = 1.0f;
    self.fire.frame = CGRectMake((screenWidth - fireW) / 2, (CGRectGetHeight(self.cloud.frame) - 80), fireW, fireH);
    
//    [self.fire mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(self.cloud).offset(-50);
//        make.centerX.equalTo(self.cloud);
//        make.height.equalTo(@24);
//        make.width.equalTo(@18);
//    }];
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

#pragma mark - Restart

- (UIImage *)takeSnapshotOfView:(UIView *)view
{
    CGFloat reductionFactor = 1;
    UIGraphicsBeginImageContext(CGSizeMake(view.frame.size.width/reductionFactor, view.frame.size.height/reductionFactor));
    [view drawViewHierarchyInRect:CGRectMake(0, 0, view.frame.size.width/reductionFactor, view.frame.size.height/reductionFactor) afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

//- (UIImageView *)blurView {
//    if (!_blurView) {
////        UIImage *blurImage = [[self takeSnapshotOfView:self.view] applyBlurWithRadius:10 tintColor:[UIColor colorWithWhite:1.0f alpha:0.7f] saturationDeltaFactor:1.0 maskImage:nil];
////        UIImageView *blurView = [[UIImageView alloc] initWithImage:blurImage];
//        UIImageView *blurView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"境"]];
//        
//        blurView.userInteractionEnabled = YES;
//        blurView.frame = self.view.frame;
//        
//        [self.view addSubview:blurView];
//        
//        UIButton *restartButton = [[UIButton alloc] init];
//        [blurView addSubview:restartButton];
//        restartButton.frame = self.view.frame;
//        restartButton.imageView.bounds = CGRectMake(0, 0, 22, 110);
//        restartButton.contentMode = UIViewContentModeTop;
//        [restartButton setContentHorizontalAlignment: UIControlContentHorizontalAlignmentCenter];
//        [restartButton setContentVerticalAlignment: UIControlContentVerticalAlignmentTop];
//        [restartButton setImageEdgeInsets:UIEdgeInsetsMake(CGRectGetHeight(restartButton.frame) * 1.0 / 3, 0, 0, 0)];
//        
//        restartButton.backgroundColor = [UIColor clearColor];
//        [restartButton addTarget:self action:@selector(oneMoreIncense) forControlEvents:UIControlEventTouchUpInside];
//        [restartButton setImage:[UIImage imageNamed:@"時"] forState:UIControlStateNormal];
//        
//        _blurView = blurView;
//    }
//    return _blurView;
//}

- (UIView *)finishedView {  // 可以和 failureView 合并
    if (!_finishedView) {
        //        UIImage *blurImage = [[self takeSnapshotOfView:self.view] applyBlurWithRadius:10 tintColor:[UIColor colorWithWhite:1.0f alpha:0.7f] saturationDeltaFactor:1.0 maskImage:nil];
        //        UIImageView *blurView = [[UIImageView alloc] initWithImage:blurImage];
        NSLog(@"failure");
        UIView *finishedView = [[UIView alloc] init];
        finishedView.backgroundColor = [UIColor clearColor];
        finishedView.frame = self.view.frame;
        
        [self.view addSubview:finishedView];
        
        UIButton *finishedButton = [[UIButton alloc] init];
        [finishedView addSubview:finishedButton];
        finishedButton.frame = CGRectMake((screenWidth - 22) * 0.5, screenHeight * 0.25 - 44, 22, 120);
        finishedButton.contentMode = UIViewContentModeTop;
        finishedButton.backgroundColor = [UIColor clearColor];
        [finishedButton setImage:[UIImage imageNamed:@"時"] forState:UIControlStateNormal];
        
        
        UIButton *restartButton = [[UIButton alloc] init];
        [finishedView addSubview:restartButton];
        restartButton.frame = CGRectMake((screenWidth - 22) * 0.5, screenHeight * 0.875, 23, 23);
        restartButton.contentMode = UIViewContentModeTop;
        restartButton.backgroundColor = [UIColor clearColor];
        [restartButton addTarget:self action:@selector(oneMoreIncense) forControlEvents:UIControlEventTouchUpInside];
        [restartButton setImage:[UIImage imageNamed:@"否"] forState:UIControlStateNormal];
        
        
        _finishedView = finishedView;
    }
    return _finishedView;
}


- (void)oneMoreIncense {
    smokeLocation = -520.0f;
    [self.failureView removeFromSuperview];
    [self.finishedView removeFromSuperview];
    [self.incenseView removeFromSuperview];
    [self.smoke removeFromSuperview];
    self.incenseView = nil;
    self.incenseShadowView.alpha = 1.0f;
    
    [self makeIncense];
    [self makeCloud];
    [self makeFire];
    [self makeRipple];
}

#pragma mark - Recorder

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
