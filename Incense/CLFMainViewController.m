//
//  ViewController.m
//  Incense
//
//  Created by CaiGavin on 8/10/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "CLFMainViewController.h"
#import "Waver.h"
#import "CLFFire.h"
#import "CLFIncenseView.h"
#import "CLFSmokeView.h"
#import "Masonry.h"
#import <AVFoundation/AVFoundation.h>
#import "BMWaveMaker.h"
#import <QuartzCore/QuartzCore.h>

@interface CLFMainViewController () <CLFFireDelegate>
@property (nonatomic, weak) CLFSmokeView *smokeView;
@property (nonatomic, weak) CLFIncenseView *incenseView;
@property (nonatomic, weak) Waver *waver;
@property (nonatomic, weak) CLFFire *fire;
@property (nonatomic, weak) UIButton *restartButton;

@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, assign) CGFloat animateTime;
@property (nonatomic, weak) UIView *rippleView;
@property (nonatomic, strong) BMWaveMaker *rippleMaker;

@end

@implementation CLFMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self makeIncense];
    [self makeFire];
    [self makeSmoke];
    [self makeRipple];
    
    [self.rippleMaker spanWaveContinuallyWithTimeInterval:2.0f];
    self.animateTime = 10.0f;
}

- (void)lightTheIncense {
    [self setupRecorder];
    
    Waver *waver = [[Waver alloc] init];
    [self.view addSubview:waver];
    
    [waver mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.incenseView.mas_top);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.view);
    }];
    waver.alpha = 0;
    
    __block AVAudioRecorder *weakRecorder = self.recorder;
    
    waver.waverLevelCallback = ^(Waver * waver) {
        [weakRecorder updateMeters];
        CGFloat normalizedValue = pow (10, [weakRecorder averagePowerForChannel:0] / 40); // 5
        waver.level = normalizedValue;
    };
    self.waver = waver;
    
    self.incenseView.brightnessCallback = ^(CLFIncenseView *incense) {
        [weakRecorder updateMeters];
        CGFloat normalizedValue = pow (10, [weakRecorder averagePowerForChannel:0] / 40);
        incense.brightnessLevel = normalizedValue;
    };
    
    self.fire.dragEnable = NO;
    [UIView animateWithDuration:3.0 animations:^{
        self.fire.alpha = 0.0f;
        self.incenseView.incenseHeadView.alpha = 1.0f;
        self.incenseView.incenseDustView.alpha = 1.0f;
        self.waver.alpha = 1.0f;
    } completion:^(BOOL finished) {
        if (finished) {
            [self.fire removeFromSuperview];
            [self timeFlow];
        }
    }];
}

#pragma mark - IncenseLighted

- (void)timeFlow {
    [UIView animateWithDuration:self.animateTime animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        // 执行时会导致烟雾抖动一下. 要换成 frame?
        // 好吧, 换成 frame 一样抖
        // 好吧, autolayout 和 Core Animation 有冲突, 还是用 frame 吧
//        [self.incenseView layoutIfNeeded];
        self.incenseView.bounds = CGRectMake(0, 0, 6, 15);
        self.smokeView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:2 animations:^{
                self.incenseView.incenseDustView.alpha = 0;
                self.incenseView.incenseHeadView.alpha = 0;
            }];
        }
    }];
    
    // 这一小块要放到 Waver 里面去吗=,=
    CABasicAnimation *anim = [CABasicAnimation animation];
    anim.keyPath = @"bounds";
    anim.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), [UIScreen mainScreen].bounds.size.height - 115)];
    anim.duration = self.animateTime;
    anim.delegate = self;
    anim.removedOnCompletion = NO;
    anim.fillMode = kCAFillModeForwards;
    
    for (CAGradientLayer *layer in self.waver.gradientLayers) {
        [layer addAnimation:anim forKey:nil];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    self.restartButton.alpha = 0.0f;
    [UIView animateWithDuration:2.0f animations:^{
        self.waver.alpha = 0.0f;
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:2.0f animations:^{
                self.restartButton.alpha = 1.0f;
            }];
        }
    }];
    [self.waver.displaylink invalidate];
    [self.incenseView.displaylink invalidate];
}

#pragma mark - Incense

- (CLFIncenseView *)incenseView {
    if (!_incenseView) {
        CLFIncenseView *incenseView = [[CLFIncenseView alloc] init];
        incenseView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:incenseView];
        _incenseView = incenseView;
    }
    return _incenseView;
}

- (void)makeIncense {
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;

    self.incenseView.frame = CGRectMake((screenW - 6) / 2, screenH - 300, 6, 200);
    
    self.incenseView.incenseHeadView.alpha = 0.0f;
    self.incenseView.incenseDustView.alpha = 0.0f;
    
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animation];
    anim.keyPath = @"position.y";
    anim.repeatCount = 1000;
    anim.values = @[@(screenH - 95), @(screenH - 100), @(screenH - 95)];
    anim.duration = 4.0f;
    anim.removedOnCompletion = NO;
    anim.fillMode = kCAFillModeForwards;
    self.incenseView.layer.position = CGPointMake(screenW / 2, screenH - 100);
    self.incenseView.layer.anchorPoint = CGPointMake(0.5, 1);
    [self.incenseView.layer addAnimation:anim forKey:nil];

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
        UIView *rippleView = [[UIView alloc] init];
        rippleView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:rippleView];
        UIView *shadowView = [[UIView alloc] init];
        shadowView.backgroundColor = [UIColor blackColor];
        [rippleView addSubview:shadowView];
        [shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@10);
            make.width.equalTo(@10);
            make.center.equalTo(rippleView);
        }];
        shadowView.layer.cornerRadius = 5.0f;
        shadowView.layer.masksToBounds = YES;
        _rippleView = rippleView;
    }
    return _rippleView;
}

- (void)makeRipple {
    [self.rippleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
        make.height.equalTo(@180);
    }];
    CATransform3D rotate = CATransform3DMakeRotation(M_PI / 3, 1, 0, 0);
    self.rippleView.layer.transform = CATransform3DPerspect(rotate, CGPointMake(0, 0), 200);
}

- (BMWaveMaker *)rippleMaker {
    if (!_rippleMaker) {
        _rippleMaker = [[BMWaveMaker alloc] init];
        _rippleMaker.animationView = self.rippleView;
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
    scale.m34 = -1.0f/disZ;
    return CATransform3DConcat(CATransform3DConcat(transToCenter, scale), transBack);
}

CATransform3D CATransform3DPerspect(CATransform3D t, CGPoint center, float disZ) {
    return CATransform3DConcat(t, CATransform3DMakePerspective(center, disZ));
}


#pragma mark - Restart

- (UIButton *)restartButton {
    if (!_restartButton) {
        UIButton *restartButton = [[UIButton alloc] init];
        [restartButton setTitle:@"再上一柱香" forState:UIControlStateNormal];
        [restartButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        restartButton.backgroundColor = [UIColor whiteColor];
        [restartButton addTarget:self action:@selector(oneMoreIncense) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:restartButton];
        [restartButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.centerY.equalTo(self.view).offset(-100);
            make.width.equalTo(@120);
            make.height.equalTo(@50);
        }];
        _restartButton = restartButton;
    }
    return _restartButton;
}

- (void)oneMoreIncense {
    
    [UIView animateWithDuration:2.0 animations:^{
//        [self.incenseView removeFromSuperview];
        self.incenseView = nil;
        [self.waver removeFromSuperview];
        [self.smokeView removeFromSuperview];
        [self.fire removeFromSuperview];
        [self.restartButton removeFromSuperview];
    } completion:^(BOOL finished) {
            [self makeIncense];
            [self makeFire];
            [self makeSmoke];
    }];
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
