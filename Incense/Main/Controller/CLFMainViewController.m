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

@interface CLFMainViewController () <CLFFireDelegate, CLFIncenseViewDelegate>
@property (nonatomic, weak)   CLFSmokeView    *smokeView;
@property (nonatomic, weak)   CLFIncenseView  *incenseView;
@property (nonatomic, weak)   CLFFire         *fire;
@property (nonatomic, weak)   UIButton        *restartButton;

@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, weak)   UIView          *rippleView;
@property (nonatomic, strong) BMWaveMaker     *rippleMaker;

@end

@implementation CLFMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self makeIncense];
    [self makeFire];
    [self makeSmoke];
    [self makeRipple];
    
    [self.rippleMaker spanWaveContinuallyWithTimeInterval:2.0f];
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
    self.restartButton.alpha = 0.0f;
    [UIView animateWithDuration:2.0f animations:^{
        self.incenseView.waver.alpha = 0.0f;
        self.incenseView.incenseHeadView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:2.0f animations:^{
                self.restartButton.alpha = 1.0f;
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
        incenseView.backgroundColor = [UIColor clearColor];
        incenseView.delegate = self;
        [self.view addSubview:incenseView];
        _incenseView = incenseView;
    }
    return _incenseView;
}

- (void)makeIncense {
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;

    self.incenseView.frame = CGRectMake(0, screenH - 300, screenW, 200);
    self.incenseView.waver.alpha = 0.0f;
    self.incenseView.incenseHeadView.alpha = 0.0f;
    
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
    scale.m34 = -1.0f / disZ;
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
    [UIView animateWithDuration:0.1 animations:^{
        [self.incenseView removeFromSuperview];
        [self.smokeView removeFromSuperview];
        [self.fire removeFromSuperview];
        [self.restartButton removeFromSuperview];
        self.incenseView = nil;
        self.smokeView = nil;
        self.fire = nil;
        self.restartButton = nil;
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
