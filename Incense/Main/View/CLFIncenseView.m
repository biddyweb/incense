//
//  CLFIncenseView.m
//  Incense
//
//  Created by CaiGavin on 8/10/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "CLFIncenseView.h"
#import "Masonry.h"

@interface CLFIncenseView ()

@property (nonatomic, assign, getter=isAnimating) BOOL animating;

@end

@implementation CLFIncenseView

static CGFloat headDustHeight;

- (instancetype)init {
    if (self = [super init]) {
        headDustHeight = 0;
    }
    return self;
}

- (UIView *)incenseHeadView {
    if (!_incenseHeadView) {
        UIView *incenseHeadView = [[UIView alloc] init];
        incenseHeadView.backgroundColor = [UIColor redColor];
        [self addSubview:incenseHeadView];
        _incenseHeadView = incenseHeadView;
    }
    return _incenseHeadView;
}

- (UIView *)incenseDustView {
    if (!_incenseDustView) {
        UIView *incenseDustView = [[UIView alloc] init];
        incenseDustView.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:incenseDustView];
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

- (void)layoutSubviews {
    [self.incenseHeadView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.height.equalTo(@8);
    }];
    
    [self.incenseDustView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.incenseHeadView.mas_bottom);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.height.equalTo(@3);
    }];
    
    self.headDustView.frame = CGRectMake(0, 0, 6, headDustHeight);
    
    UIView *layerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 6, 10)];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.startPoint = CGPointMake(0.0, 0.0);
    gradientLayer.endPoint = CGPointMake(0.0, 1.0);
    
    gradientLayer.frame = layerView.bounds;
    NSMutableArray *colors = [NSMutableArray array];
    
    [colors addObject:(id)[UIColor colorWithRed:0.6f green:0.0f blue:0.0f alpha:1.0f].CGColor];
    [colors addObject:(id)[UIColor colorWithRed:0.8f green:0.0f blue:0.0f alpha:1.0f].CGColor];
    [colors addObject:(id)[UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:1.0f].CGColor];
    
    gradientLayer.colors = colors;
    
    [layerView.layer insertSublayer:gradientLayer atIndex:0];
    [self.incenseHeadView addSubview:layerView];
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
        [UIView animateWithDuration:0.5f animations:^{
            self.incenseHeadView.backgroundColor = [UIColor yellowColor];
            self.incenseDustView.backgroundColor = [UIColor blackColor];
            self.headDustView.alpha = 0.5f;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5f animations:^{
                self.incenseHeadView.backgroundColor = [UIColor redColor];
                self.incenseDustView.backgroundColor = [UIColor grayColor];
                self.headDustView.alpha = 0.0f;
            } completion:^(BOOL finished) {
                self.animating = NO;
                headDustHeight = 0.1;
            }];
        }];
    }
    [self updateHeightWithBrightnessLevel:brightnessLevel];
}

- (void)updateHeightWithBrightnessLevel:(CGFloat)brightnessLevel {
    CGFloat newHeight = CGRectGetHeight(self.frame) - 2.5;
    self.frame = (CGRect){self.frame.origin, {CGRectGetWidth(self.frame), newHeight}};
    
    if (!self.isAnimating) {
        headDustHeight -= 0.4;
        if (!self.headDustView.alpha) {
            self.headDustView.alpha = 1.0f;
        }
        self.headDustView.frame = CGRectMake(0, 0, 6, headDustHeight);
    }
    
    if (newHeight <= 15) {
        [self.delegate incenseDidBurnOff];
    }
}

@end
