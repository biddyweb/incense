//
//  ViewController.m
//  Incense
//
//  Created by CaiGavin on 8/10/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "CLFMainViewController.h"
#import "CLFFire.h"
#import "CLFIncenseView.h"
#import "CLFSmokeView.h"
#import "Masonry.h"
#import <AVFoundation/AVFoundation.h>
#import "BMWaveMaker.h"
#import <QuartzCore/QuartzCore.h>
#import "Waver.h"
#import "UIImage+ImageEffects.h"
#import "UIERealTimeBlurView.h"

@interface CLFMainViewController () <CLFFireDelegate, CLFIncenseViewDelegate>
@property (nonatomic, weak)   CLFSmokeView    *smokeView;
@property (nonatomic, weak)   CLFIncenseView  *incenseView;
@property (nonatomic, weak)   UIImageView     *incenseShadowView;
@property (nonatomic, weak)   CLFFire         *fire;

@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, weak)   UIView          *rippleView;
@property (nonatomic, strong) BMWaveMaker     *rippleMaker;

@property (nonatomic, weak) UIERealTimeBlurView *blurView;

@end

@implementation CLFMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self makeIncense];
    [self makeFire];
    [self makeSmoke];
    [self makeRipple];
}

- (void)lightTheIncense {
    [self setupRecorder];
    __block AVAudioRecorder *weakRecorder = self.recorder;
    self.incenseView.waver.waverLevelCallback = ^(Waver *waver) {
        [weakRecorder updateMeters];
        CGFloat normalizedValue = pow (10, [weakRecorder averagePowerForChannel:0] / 5);
        waver.level = normalizedValue;
    };

    self.fire.dragEnable = NO;
    [UIView animateWithDuration:3.0 animations:^{
        self.fire.alpha = 0.0f;
        self.incenseView.incenseHeadView.alpha = 1.0f;
        self.incenseView.waver.alpha = 1.0f;
    } completion:^(BOOL finished) {
        if (finished) {
            [self.fire removeFromSuperview];
            [self timeFlow];
        }
    }];
}

#pragma mark - IncenseLighted

- (void)timeFlow {
    __block AVAudioRecorder *weakRecorder = self.recorder;
    
    self.incenseView.brightnessCallback = ^(CLFIncenseView *incense) {
        [weakRecorder updateMeters];
        CGFloat normalizedValue = pow (10, [weakRecorder averagePowerForChannel:0] / 5);
        incense.brightnessLevel = normalizedValue;
    };
}

- (void)incenseDidBurnOff {
    [self.rippleMaker stopWave];
    self.blurView.alpha = 0.0f;
    [UIView animateWithDuration:2.0f animations:^{
        self.incenseView.waver.alpha = 0.0f;
        self.incenseView.incenseHeadView.alpha = 0.0f;
        self.blurView.alpha = 0.9f;
        self.rippleView.alpha = 0.3f;
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:1.0f animations:^{
                self.blurView.alpha = 1.0f;
                self.rippleView.alpha = 0.0f;
            } completion:^(BOOL finished) {

            }];
        }
    }];
    [self.incenseView.waver.displaylink invalidate];
    [self.incenseView.displaylink invalidate];
}

#pragma mark - Incense

- (CLFIncenseView *)incenseView {
    if (!_incenseView) {
        CLFIncenseView *incenseView = [[CLFIncenseView alloc] init];
        incenseView.backgroundColor = [UIColor greenColor];
        incenseView.delegate = self;
        [self.view addSubview:incenseView];
        _incenseView = incenseView;
    }
    return _incenseView;
}

- (UIImageView *)incenseShadowView {
    if (!_incenseShadowView) {
        UIImageView *incenseShadowView = [[UIImageView alloc] init];
        incenseShadowView.image = [UIImage imageNamed:@"StickShadow"];
        [self.view addSubview:incenseShadowView];
        _incenseShadowView = incenseShadowView;
    }
    return _incenseShadowView;
}

- (void)makeIncense {
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    
    [self.incenseView initialSetup];

    self.incenseView.frame = CGRectMake(0, screenH - 300, screenW, 200);
    self.incenseView.waver.alpha = 0.0f;
    self.incenseView.incenseHeadView.alpha = 0.0f;
    
    self.incenseShadowView.frame = CGRectMake((screenW - 6) / 2, screenH - 90, 6, 3);
    
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animation];
    anim.keyPath = @"position.y";
    anim.repeatCount = 1500;
    anim.values = @[@(screenH - 95), @(screenH - 100), @(screenH - 95)];
    anim.duration = 4.0f;
    anim.removedOnCompletion = NO;
    anim.fillMode = kCAFillModeForwards;
    self.incenseView.layer.position = CGPointMake(0, screenH - 100);
    self.incenseView.layer.anchorPoint = CGPointMake(0, 1);
    [self.incenseView.layer addAnimation:anim forKey:nil];
    
    NSValue *bounds1 = [NSValue valueWithCGRect:CGRectMake(0, 0, 6, 3)];
    NSValue *bounds2 = [NSValue valueWithCGRect:CGRectMake(0, 0, 3, 1.5)];
    
    CAKeyframeAnimation *shadowAnim = [CAKeyframeAnimation animation];
    shadowAnim.keyPath = @"bounds";
    shadowAnim.repeatCount = 1500;
    shadowAnim.values = @[bounds1, bounds2, bounds1];
    shadowAnim.duration = 4.0f;
    shadowAnim.removedOnCompletion = NO;
    shadowAnim.fillMode = kCAFillModeForwards;
    self.incenseShadowView.layer.position = CGPointMake(screenW / 2, screenH - 90);
    self.incenseShadowView.layer.anchorPoint = CGPointMake(0.5, 0.5);
    [self.incenseShadowView.layer addAnimation:shadowAnim forKey:nil];
}

#pragma mark - Fire

- (CLFFire *)fire {
    if (!_fire) {
        CLFFire *fire = [[CLFFire alloc] init];
        fire.backgroundColor = [UIColor clearColor];
        fire.delegate = self;
        fire.dragEnable = YES;
        [self.view addSubview:fire];
        _fire = fire;
    }
    return _fire;
}

- (void)makeFire {
    self.fire.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 20, 80, 40, 40);
}

#pragma mark - Smoke

- (UIView *)smokeView {
    if (!_smokeView) {
        CLFSmokeView *smokeView = [[CLFSmokeView alloc] init];
        smokeView.backgroundColor = [UIColor clearColor];
        smokeView.alpha = 0.0f;
        [self.view addSubview:smokeView];
        _smokeView = smokeView;
    }
    return _smokeView;
}

- (void)makeSmoke {
    [self.smokeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.view);
        make.height.equalTo(@180);
    }];
}

#pragma mark - Ripple

- (UIView *)rippleView {
    if (!_rippleView) {
        CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
        CGFloat screenH = [UIScreen mainScreen].bounds.size.height;

        UIView *rippleView = [[UIView alloc] init];
        rippleView.frame = CGRectMake(0, screenH - 180, screenW, 180);
        rippleView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:rippleView];
        _rippleView = rippleView;
    }
    return _rippleView;
}

- (void)makeRipple {
    self.rippleView.alpha = 1.0f;

    self.rippleMaker.animationView = self.rippleView;
    [self.rippleMaker spanWaveContinuallyWithTimeInterval:2.0f];
        CATransform3D rotate = CATransform3DMakeRotation(M_PI / 3, 1, 0, 0);
    self.rippleView.layer.transform = CATransform3DPerspect(rotate, CGPointMake(0, 0), 200);
}

- (BMWaveMaker *)rippleMaker {
    if (!_rippleMaker) {
        _rippleMaker = [[BMWaveMaker alloc] init];
        _rippleMaker.spanScale = 100.0f;
        _rippleMaker.originRadius = 0.9f;
        _rippleMaker.waveColor = [UIColor whiteColor];
        _rippleMaker.animationDuration = 10.0f;
        _rippleMaker.wavePathWidth = 1.5f;
    }
    return _rippleMaker;
}

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

#pragma mark - Restart

- (UIERealTimeBlurView *)blurView {
    if (!_blurView) {
        CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
        CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
//
//        UIImage *blurImage = [[UIImage imageNamed:@"Finish"] applyTintEffectWithColor:[UIColor whiteColor]];
//        UIImageView *blurView = [[UIImageView alloc] initWithImage:blurImage];
//        blurView.userInteractionEnabled = YES;
//        blurView.frame = self.view.frame;
        UIERealTimeBlurView *blurView = [[UIERealTimeBlurView alloc] initWithFrame:self.view.frame];
        [self.view addSubview:blurView];
        
        blurView.renderStatic = YES;
        
        UIButton *restartButton = [[UIButton alloc] init];
        [blurView addSubview:restartButton];
        restartButton.frame = CGRectMake((screenW - 44)/2, (screenH - 314)/2, 44, 214);
        [restartButton addTarget:self action:@selector(oneMoreIncense) forControlEvents:UIControlEventTouchUpInside];
        [restartButton setImage:[UIImage imageNamed:@"時"] forState:UIControlStateNormal];
        
        _blurView = blurView;
    }
    return _blurView;
}

- (void)oneMoreIncense {
    [self.blurView removeFromSuperview];
    [self makeIncense];
    [self makeFire];
    [self makeSmoke];
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
