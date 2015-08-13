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

@end

@implementation CLFIncenseView

static CGFloat headDustHeight;
static CGFloat waverHeight;

- (instancetype)init {
    if (self = [super init]) {
        headDustHeight = 0;
        waverHeight = - [UIScreen mainScreen].bounds.size.height;
    }
    return self;
}

- (Waver *)waver {
    if (!_waver) {
        Waver *waver = [[Waver alloc] init];
        waver.backgroundColor = [UIColor grayColor];
        waver.alpha = 0;
        [self addSubview:waver];
        _waver = waver;
    }
    return _waver;
}

- (UIView *)incenseBodyView {
    if (!_incenseBodyView) {
        UIView *incenseBodyView = [[UIView alloc] init];
        incenseBodyView.backgroundColor = [UIColor blackColor];
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

- (void)layoutSubviews {
    [self.incenseBodyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@6);
        make.center.equalTo(self);
        make.height.equalTo(self);
    }];
    
    [self.incenseHeadView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.incenseBodyView);
        make.left.equalTo(self.incenseBodyView);
        make.right.equalTo(self.incenseBodyView);
        make.height.equalTo(@8);
    }];
    
    [self.incenseDustView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.incenseHeadView.mas_bottom);
        make.left.equalTo(self.incenseBodyView);
        make.right.equalTo(self.incenseBodyView);
        make.height.equalTo(@3);
    }];
    
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    
#warning frame 要调整
    
//    [self.waver mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.superview);
//        make.left.equalTo(self.superview);
//        make.right.equalTo(self.superview);
//        make.bottom.equalTo(self.mas_top);
//    }];
    self.waver.frame = CGRectMake(0, 0, screenW, waverHeight);
    self.headDustView.frame = CGRectMake((screenW - 6) / 2, 0, 6, headDustHeight);
    
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
    CGFloat newHeight = CGRectGetHeight(self.frame) - 25 * brightnessLevel;
    self.frame = (CGRect){self.frame.origin, {CGRectGetWidth(self.frame), newHeight}};
    
    waverHeight -= 25 * brightnessLevel;
    self.waver.frame = (CGRect) {self.waver.frame.origin, {CGRectGetWidth(self.waver.frame), waverHeight}};
    
//    NSLog(@"%f", newWaverHeight);
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
