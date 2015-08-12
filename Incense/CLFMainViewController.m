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

@interface CLFMainViewController () <CLFFireDelegate>
@property (nonatomic, weak) CLFSmokeView *smokeView;
@property (nonatomic, weak) CLFIncenseView *incenseView;
@property (nonatomic, weak) Waver *waver;
@property (nonatomic, weak) CLFFire *fire;
@property (nonatomic, weak) UIButton *restartButton;

@property (nonatomic, strong) AVAudioRecorder *recorder;

@end

@implementation CLFMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self makeIncense];
    [self makeFire];
    [self makeSmoke];
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
        CGFloat normalizedValue = pow (10, [weakRecorder averagePowerForChannel:0] / 5);
        waver.level = normalizedValue;
    };
    self.waver = waver;
    
    self.incenseView.brightnessCallback = ^(CLFIncenseView *incense) {
        [weakRecorder updateMeters];
        CGFloat normalizedValue = pow (10, [weakRecorder averagePowerForChannel:0] / 5);
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
    [self.incenseView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@30);
    }];

    [UIView animateWithDuration:30 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [self.incenseView layoutIfNeeded];
        self.smokeView.alpha = 0.6f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:2 animations:^{
            self.incenseView.incenseDustView.alpha = 0;
            self.incenseView.incenseHeadView.alpha = 0;
        }];
    }];
    
    
    // 这一小块要放到 Waver 里面去吗=,=
    CABasicAnimation *anim = [CABasicAnimation animation];
    anim.keyPath = @"bounds";
    anim.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), [UIScreen mainScreen].bounds.size.height - 130)];
    anim.duration = 30;
    anim.delegate = self;
    anim.removedOnCompletion = NO;
    anim.fillMode = kCAFillModeForwards;
    
    for (CAGradientLayer *layer in self.waver.gradientLayers) {
        [layer addAnimation:anim forKey:nil];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    self.waver.alpha = 1.0f;
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
    if (_incenseView == nil) {
        CLFIncenseView *incenseView = [[CLFIncenseView alloc] init];
        incenseView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:incenseView];
        _incenseView = incenseView;
    }
    return _incenseView;
}

- (void)makeIncense {
    [self.incenseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@200);
        make.width.equalTo(@6);
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-100);
    }];
    self.incenseView.incenseHeadView.alpha = 0.0f;
    self.incenseView.incenseDustView.alpha = 0.0f;
}

#pragma mark - Fire

- (CLFFire *)fire {
    if (_fire == nil) {
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
    if (_smokeView == nil) {
        CLFSmokeView *smokeView = [[CLFSmokeView alloc] init];
        smokeView.backgroundColor = [UIColor clearColor];
        smokeView.alpha = 0.0f;
        [self.view addSubview:smokeView];
        _smokeView = smokeView;
    }
    return _smokeView;
}

- (void)makeSmoke {
    self.smokeView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 180);
}

#pragma mark - Restart

- (UIButton *)restartButton {
    if (_restartButton == nil) {
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

-(void)setupRecorder {
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
