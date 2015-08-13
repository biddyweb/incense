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

@property (nonatomic, assign, getter=isAnimating) BOOL animating;
@property (nonatomic, weak) UIImageView *lightView;
@property (nonatomic, weak) UIView *incenseSticker;

@end

@implementation CLFIncenseView

static CGFloat headHeight;
static CGFloat waverHeight;
static CGFloat incenseWidth = 5.0f;
static CGFloat incenseStickerWidth = 2.0f;;

- (instancetype)init {
    if (self = [super init]) {
        headHeight = 0.0f;
        waverHeight = - [UIScreen mainScreen].bounds.size.height;
    }
    return self;
}

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
        [self.incenseHeadView addSubview:lightView];
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
        _incenseBodyView = incenseBodyView;
    }
    return _incenseBodyView;
}

- (UIView *)incenseHeadView {
    if (!_incenseHeadView) {
        UIView *incenseHeadView = [[UIView alloc] init];
        incenseHeadView.backgroundColor = [UIColor redColor];
        [self.incenseBodyView addSubview:incenseHeadView];
        _incenseHeadView = incenseHeadView;
    }
    return _incenseHeadView;
}

- (UIView *)incenseDustView {
    if (!_incenseDustView) {
        UIView *incenseDustView = [[UIView alloc] init];
        incenseDustView.backgroundColor = [UIColor lightGrayColor];
        [self.incenseBodyView addSubview:incenseDustView];
        _incenseDustView = incenseDustView;
    }
    return _incenseDustView;
}

- (UIView *)headDustView {
    if (!_headDustView) {
        UIView *headDustView = [[UIView alloc] init];
        headDustView.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:headDustView];
        _headDustView = headDustView;
    }
    return _headDustView;
}

- (UIView *)incenseSticker {
    if (!_incenseSticker) {
        UIView *incenseSticker = [[UIView alloc] init];
        incenseSticker.backgroundColor = [UIColor blackColor];
        incenseSticker.layer.cornerRadius = 1.0f;
        [self.incenseBodyView addSubview:incenseSticker];
        _incenseSticker = incenseSticker;
    }
    return _incenseSticker;
}

- (void)layoutSubviews {
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    
    [self.incenseBodyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(incenseWidth));
        make.centerX.equalTo(self);
        make.top.equalTo(self);
        make.height.equalTo(self).offset(-50);
    }];
    
    [self.incenseDustView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.incenseHeadView.mas_bottom);
        make.left.equalTo(self.incenseBodyView);
        make.right.equalTo(self.incenseBodyView);
        make.height.equalTo(@2);
    }];
    
    self.headDustView.frame = CGRectMake((screenW - 5) / 2, 0, 5, headDustHeight);
    
    [self.incenseHeadView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.incenseBodyView);
        make.left.equalTo(self.incenseBodyView);
        make.right.equalTo(self.incenseBodyView);
        make.height.equalTo(@8);
    }];
    
    [self.incenseSticker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
        make.centerX.equalTo(self);
        make.height.equalTo(@70);
        make.width.equalTo(@(incenseStickerWidth));
    }];
    
    self.waver.frame = CGRectMake(0, 0, screenW, waverHeight);
    
//    UIView *layerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, incenseWidth, 10)];
//    
//    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
//    gradientLayer.startPoint = CGPointMake(0.0, 0.0);
//    gradientLayer.endPoint = CGPointMake(0.0, 1.0);
//    
//    gradientLayer.frame = layerView.bounds;
//    NSMutableArray *colors = [NSMutableArray array];
//    
//    [colors addObject:(id)[UIColor colorWithRed:0.6f green:0.0f blue:0.0f alpha:1.0f].CGColor];
//    [colors addObject:(id)[UIColor colorWithRed:0.8f green:0.0f blue:0.0f alpha:1.0f].CGColor];
//    [colors addObject:(id)[UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:1.0f].CGColor];
//    
//    gradientLayer.colors = colors;
//    
//    [layerView.layer insertSublayer:gradientLayer atIndex:0];
//    [self.incenseHeadView addSubview:layerView];
    
    [self.lightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.incenseHeadView);
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
            self.incenseHeadView.backgroundColor = [UIColor yellowColor];
            self.incenseDustView.backgroundColor = [UIColor blackColor];
            self.headDustView.alpha = 0.5f;
            self.lightView.alpha = 1.0f;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:1.0f animations:^{
                self.incenseHeadView.backgroundColor = [UIColor redColor];
                self.incenseDustView.backgroundColor = [UIColor grayColor];
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
        headHeight -= 0.4;
        if (!self.headDustView.alpha) {
            self.headDustView.alpha = 1.0f;
        }
        self.headDustView.frame = CGRectMake(0, 0, incenseWidth, headHeight);
    }
    
    if (newHeight <= 65) {
        [self.delegate incenseDidBurnOff];
    }
}

@end
