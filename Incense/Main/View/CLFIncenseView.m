//
//  CLFIncenseView.m
//  Incense
//
//  Created by CaiGavin on 8/10/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "CLFIncenseView.h"
#import "Masonry.h"
#import "Waver.h"

@interface CLFIncenseView ()

@property (nonatomic, assign, getter=isAnimating) BOOL        animating;
@property (nonatomic, weak)                       UIImageView *lightView;
@property (nonatomic, weak)                       UIView      *incenseStick;
@property (nonatomic, weak)                       UIView      *incenseBodyView;
@property (nonatomic, weak)                       UIImageView *headDustView;

@end

@implementation CLFIncenseView

static CGFloat headHeight;
static CGFloat waverHeight;
static CGFloat screenWidth;

static const CGFloat kIncenseWidth = 5.0f;
static const CGFloat kIncenseStickWidth = 2.0f;
static const CGFloat kIncenseStickHeight = 70.0f;

- (Waver *)waver {
    if (!_waver) {
        Waver *waver = [[Waver alloc] init];
        waver.backgroundColor = [UIColor clearColor];
        waver.alpha = 0.0f;
        [self addSubview:waver];
        _waver = waver;
    }
    return _waver;
}

- (UIImageView *)lightView {
    if (!_lightView) {
        UIImageView *lightView = [[UIImageView alloc] init];
        lightView.image = [UIImage imageNamed:@"spark"];
        lightView.alpha = 0.0f;
        [self.headDustView addSubview:lightView];

        _lightView = lightView;
    }
    return _lightView;
}

- (UIView *)incenseBodyView {
    if (!_incenseBodyView) {
        UIView *incenseBodyView = [[UIView alloc] init];
        incenseBodyView.backgroundColor = [UIColor blackColor];
        incenseBodyView.layer.cornerRadius = 3;
        [self addSubview:incenseBodyView];
        [incenseBodyView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(kIncenseWidth));
            make.centerX.equalTo(self);
            make.top.equalTo(self);
            make.height.equalTo(self).offset(-50);
        }];

        _incenseBodyView = incenseBodyView;
    }
    return _incenseBodyView;
}

- (UIView *)incenseHeadView {
    if (!_incenseHeadView) {
        UIImageView *incenseHeadView = [[UIImageView alloc] init];
        incenseHeadView.image = [UIImage imageNamed:@"星"];
        [self.incenseBodyView addSubview:incenseHeadView];
        [incenseHeadView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.incenseBodyView).offset(-2);
            make.left.equalTo(self.incenseBodyView);
            make.right.equalTo(self.incenseBodyView);
            make.height.equalTo(@8);
        }];
        _incenseHeadView = incenseHeadView;
    }
    return _incenseHeadView;
}

- (UIView *)headDustView {
    if (!_headDustView) {
        UIImageView *headDustView = [[UIImageView alloc] init];
        headDustView.image = [UIImage imageNamed:@"单独的灰"];
        [self.incenseBodyView addSubview:headDustView];
        _headDustView = headDustView;
    }
    return _headDustView;
}

- (UIView *)incenseStick {
    if (!_incenseStick) {
        UIView *incenseStick = [[UIView alloc] init];
        incenseStick.layer.cornerRadius = 1.0f;
        [self.incenseBodyView insertSubview:incenseStick belowSubview:self.incenseHeadView];
        [incenseStick mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self);
            make.centerX.equalTo(self);
            make.height.equalTo(@(kIncenseStickHeight));
            make.width.equalTo(@(kIncenseStickWidth));
        }];
        _incenseStick = incenseStick;
    }
    return _incenseStick;
}

- (void)layoutSubviews {
    self.headDustView.frame = CGRectMake(0, 3, 5, headHeight);
    
    self.incenseStick.backgroundColor = [UIColor blackColor];
    
    self.waver.frame = CGRectMake(0, 0, screenWidth, waverHeight);
    
    [self.lightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.headDustView);
        make.top.equalTo(self.headDustView.mas_bottom).offset(-7);
        make.width.equalTo(@22);
        make.height.equalTo(@22);
    }];
}

- (void)setBrightnessCallback:(void (^)(CLFIncenseView *))brightnessCallback {
    _brightnessCallback = brightnessCallback;
    
    _displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(invokeBrightnessCallback)];
    _displaylink.frameInterval = 8;
    [_displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    self.animating = NO;
}

- (void)invokeBrightnessCallback {
    _brightnessCallback(self);
}

- (void)setBrightnessLevel:(CGFloat)brightnessLevel {
    if (self.isAnimating == NO && brightnessLevel >= 0.02f) {
        self.animating = YES;
        self.headDustView.alpha = 1.0f;
        [UIView animateWithDuration:1.0f animations:^{
            self.headDustView.alpha = 0.5f;
            self.lightView.alpha = 1.0f;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:1.0f animations:^{
                self.headDustView.alpha = 0.0f;
                self.lightView.alpha = 0.0f;
            } completion:^(BOOL finished) {
                self.animating = NO;
                headHeight = 0.1;
            }];
        }];
    }
    [self updateHeightWithBrightnessLevel:brightnessLevel];
}

- (void)updateHeightWithBrightnessLevel:(CGFloat)brightnessLevel {
    CGFloat newHeight = CGRectGetHeight(self.frame) - 2;
    self.frame = (CGRect){self.frame.origin, {CGRectGetWidth(self.frame), newHeight}};
    
    waverHeight -= 2;
    self.waver.frame = (CGRect) {self.waver.frame.origin, {CGRectGetWidth(self.waver.frame), waverHeight}};

    if (!self.isAnimating) {
        headHeight -= 0.3;
        if (!self.headDustView.alpha) {
            self.headDustView.alpha = 1.0f;
        }
        self.headDustView.frame = CGRectMake(0, 0, kIncenseWidth, headHeight);
    }
    
    if (newHeight <= 65) {
        [self.delegate incenseDidBurnOff];
    }
}

- (void)initialSetup {
    headHeight = 0.0f;
    screenWidth = [UIScreen mainScreen].bounds.size.width;
    waverHeight = - [UIScreen mainScreen].bounds.size.height;
}

@end
