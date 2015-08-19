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
#import <math.h>

@interface CLFIncenseView ()

@property (nonatomic, assign, getter=isBlowing)   BOOL            blowing;
@property (nonatomic, weak)                       UIImageView     *lightView;
@property (nonatomic, weak)                       UIView          *incenseStick;
@property (nonatomic, weak)                       UIView          *incenseBodyView;
@property (nonatomic, weak)                       UIView          *headDustView;
@property (nonatomic, weak)                       UIImageView     *smokeView;

@property (nonatomic)                             CAShapeLayer    *dustLine;
@property (nonatomic)                             CAGradientLayer *dustGradient;
@property (nonatomic)                             UIBezierPath    *dustPath;

@end

@implementation CLFIncenseView

static CGFloat headDustHeight;
static CGFloat waverHeight;
static CGFloat smokeHeight;
static CGFloat incenseHeight;
static CGFloat screenWidth;
static CGFloat screenHeight;
static CGFloat timeHaveGone;
static CGFloat sizeRatio;
static CGFloat incenseBurnOffLength;
static CGFloat incenseStickHeight;
static CGFloat incenseLocation;

static const CGFloat kIncenseWidth = 5.0f;
static const CGFloat kIncenseStickWidth = 2.0f;
static const CGFloat kSeconds = 60.0f; 

- (instancetype)init
{
    self = [super init];
    if (self) {
        screenWidth = [UIScreen mainScreen].bounds.size.width;
        screenHeight = [UIScreen mainScreen].bounds.size.height;
        waverHeight = -[UIScreen mainScreen].bounds.size.height;
        sizeRatio = screenHeight / 667.0f;
        incenseBurnOffLength = 64.0f * sizeRatio;
        incenseStickHeight = 70.0f * sizeRatio;
        incenseLocation = (screenHeight - 200 * sizeRatio) * 0.5;
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
        [self.headDustView addSubview:lightView];
        [lightView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.headDustView.mas_left).offset(2.5);
            make.top.equalTo(self.headDustView.mas_bottom).offset(-8);
            make.width.equalTo(@22);
            make.height.equalTo(@22);
        }];
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
            make.height.equalTo(self).offset(-40 * sizeRatio);
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
        UIView *headDustView = [[UIView alloc] init];
        headDustView.backgroundColor = [UIColor clearColor];
        [self.incenseBodyView insertSubview:headDustView aboveSubview:self.waver];
        _headDustView = headDustView;
    }
    return _headDustView;
}

- (CAShapeLayer *)dustLine {
    if (!_dustLine) {
        CAShapeLayer *dustLine = [CAShapeLayer layer];
        dustLine.lineCap = kCALineCapRound;
        dustLine.lineJoin = kCALineJoinRound;
        dustLine.fillColor = [UIColor clearColor].CGColor;
        dustLine.lineWidth = 5;
        dustLine.strokeColor = [UIColor whiteColor].CGColor;
        [self.headDustView.layer addSublayer:dustLine];
        
        CAGradientLayer *dustGradient = [CAGradientLayer layer];
        dustGradient.startPoint = CGPointMake(0.0f, 0.0f);
        dustGradient.endPoint = CGPointMake(0.0f, 1.0f);
        dustGradient.frame = self.headDustView.frame;
        
        NSMutableArray *colors = [NSMutableArray array];
        
        [colors addObject:(id)[UIColor colorWithRed:231/255.0 green:231/255.0 blue:231/255.0 alpha:1.0f].CGColor];
        [colors addObject:(id)[UIColor colorWithRed:195/255.0 green:195/255.0 blue:195/255.0 alpha:1.0f].CGColor];
        [colors addObject:(id)[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f].CGColor];

        
        dustGradient.colors = colors;
        dustGradient.locations = @[@0.0f, @0.9f, @1.0f];
        
        dustGradient.position = CGPointMake(0, 0);
        dustGradient.anchorPoint = CGPointMake(0, 0);
        
        [dustGradient setMask:dustLine];
        [self.headDustView.layer insertSublayer:dustGradient below:self.lightView.layer];
        
        _dustGradient = dustGradient;
        _dustLine = dustLine;
    }
    return _dustLine;
}

- (UIBezierPath *)dustPath {
    if (!_dustPath) {
        UIBezierPath *dustPath = [UIBezierPath bezierPath];
        _dustPath = dustPath;
    }
    return _dustPath;
}

- (UIView *)incenseStick {
    if (!_incenseStick) {
        UIView *incenseStick = [[UIView alloc] init];
        incenseStick.layer.cornerRadius = 1.0f;
        [self.incenseBodyView insertSubview:incenseStick belowSubview:self.incenseHeadView];
        [incenseStick mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self);
            make.centerX.equalTo(self);
            make.height.equalTo(@(incenseStickHeight));
            make.width.equalTo(@(kIncenseStickWidth));
        }];
        _incenseStick = incenseStick;
    }
    return _incenseStick;
}

//- (UIImageView *)smokeView {
//    if (!_smokeView) {
//        UIImageView *smokeView = [[UIImageView alloc] init];
//        smokeView.image = [UIImage imageNamed:@"云"];
////        smokeView.backgroundColor = [UIColor blackColor];
//        [self addSubview:smokeView];
//        [self bringSubviewToFront:smokeView];
//        _smokeView = smokeView;
//    }
//    return _smokeView;
//}

- (void)layoutSubviews {
    self.headDustView.frame = CGRectMake(0, -headDustHeight + 2, 69, headDustHeight);
    
    self.incenseStick.backgroundColor = [UIColor blackColor];
    
    self.waver.frame = CGRectMake(0, -30, screenWidth, waverHeight);
    
//    self.smokeView.frame = CGRectMake(0, - (screenHeight - (incenseHeight + incenseLocation)) - smokeHeight - 10, screenWidth, smokeHeight);
}

- (void)setBrightnessCallback:(void (^)(CLFIncenseView *))brightnessCallback {
    _brightnessCallback = brightnessCallback;
    
    _displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(invokeBrightnessCallback)];
    _displaylink.frameInterval = 8;
    [_displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    self.blowing = NO;
}

- (void)invokeBrightnessCallback {
    _brightnessCallback(self);
}

- (void)setBrightnessLevel:(CGFloat)brightnessLevel {
    if (brightnessLevel >= 0.2f) {
        self.lightView.alpha = 1.0f * brightnessLevel * 2;
    } else {
        [UIView animateWithDuration:2.0f animations:^{
            self.lightView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            self.blowing = NO;
        }];
    }
    [self updateHeightWithBrightnessLevel:brightnessLevel];
}

- (CGFloat)timeHaveGone {
    return timeHaveGone;
}

- (void)renewStatusWithTheTimeHaveGone:(CGFloat)timeInterval {
    if (timeInterval == -1) { // 已经没用了
        incenseHeight = incenseBurnOffLength;
        smokeHeight = -315 * sizeRatio;
        waverHeight = -703 * sizeRatio;
        colorLocation = 0.0f;
    } else {
        CGFloat tempIncenseHeight = incenseHeight - timeInterval * (135.0f * sizeRatio / kSeconds);
        if (tempIncenseHeight > incenseBurnOffLength) {
            incenseHeight = tempIncenseHeight;
            waverHeight -= timeInterval * (135.0f * sizeRatio / kSeconds);
            smokeHeight -= timeInterval * (135.0f * sizeRatio / kSeconds);
            colorLocation -= timeInterval * (1.2 / 100) * (60 / self.displaylink.frameInterval);
        } else {
            incenseHeight = incenseBurnOffLength;
            smokeHeight = -315 * sizeRatio;
            waverHeight = -703 * sizeRatio;
            colorLocation = 0.0f;
        }
    }
}


static CGFloat x = 2.5f;
static CGFloat y = 0.0f;
static CGFloat theta = M_PI;
static CGFloat colorLocation = 0.8f;

- (void)updateHeightWithBrightnessLevel:(CGFloat)brightnessLevel {
    CGFloat declineDistance = kSeconds * 60 / self.displaylink.frameInterval;
//    CGFloat declineDistance = 500;
    
    timeHaveGone += 1.0 / (60.0 / self.displaylink.frameInterval);
    
    incenseHeight -= 135.0f * sizeRatio / declineDistance;
    self.frame = (CGRect){self.frame.origin, {screenWidth, incenseHeight}};
    
    waverHeight -= 135.0f * sizeRatio / declineDistance;
    self.waver.frame = (CGRect) {{0, 0}, {screenWidth, waverHeight}};
    
    smokeHeight -= 135.0f * sizeRatio / declineDistance;
    self.smokeView.frame = (CGRect){self.smokeView.frame.origin, {screenWidth, smokeHeight}};
    
    colorLocation = colorLocation - 0.5 / 100 > 0 ? colorLocation - 0.5 / 100 : 0.0f;
    self.dustGradient.locations = @[@0.0f, @(colorLocation), @1.0f];
    
    [self drawEulerSpiralDust];

    self.dustGradient.bounds = self.headDustView.bounds;
    
    if (incenseHeight <= incenseBurnOffLength) {
        [self.delegate incenseDidBurnOff];
        self.lightView.alpha = 0.0f;
    }
}

CGFloat previousM;
CGFloat previousN;
CGFloat eulerSpiralLength = 0.0f;

- (void)drawEulerSpiralDust {
    CGFloat e;
    CGFloat m;
    CGFloat n;
    UIGraphicsBeginImageContextWithOptions(self.headDustView.frame.size, NO, 0.0f);
    if (x == 2.5) {
        e = x - 2.5;
        m = 2.5 + 40 * sizeRatio * integral(fresnelSin, 0, e, 10);
        n = 40 * sizeRatio * integral(fresnelCos, 0, e, 10);
        previousM = m;
        previousN = n;
        
        [self.dustPath moveToPoint:CGPointMake(m, headDustHeight - n)];
    } else if (x < 5.5){
        e = x - 2.5;
        m = 2.5 + 40 * sizeRatio * integral(fresnelSin, 0, e, 10);
        n = 40 * sizeRatio * integral(fresnelCos, 0, e, 10);
        
        eulerSpiralLength += distance(previousM, previousN, m, n);
        previousM = m;
        previousN = n;
        
        [self.dustPath addLineToPoint:CGPointMake(m, headDustHeight - n)];
    }
    
    x += 0.0072f / (kSeconds / 60.0f);
    self.dustLine.path = self.dustPath.CGPath;
    
    UIGraphicsEndImageContext();
    
//    NSLog(@"eulerSpiralLength %f, incenseLength %f, totalLength %f", eulerSpiralLength, incenseHeight, eulerSpiralLength + incenseHeight);
}

CGFloat distance(CGFloat xm, CGFloat xn, CGFloat ym, CGFloat yn) {
    return sqrt((xm - ym) * (xm - ym) + (xn - yn) * (xn - yn));
}

CGFloat fresnelSin(CGFloat x) {
    return sin(x * x / 2.0f);
}

CGFloat fresnelCos(CGFloat x) {
    return cos(x * x / 2.0f);
}

CGFloat integral(CGFloat(*f)(CGFloat x), CGFloat low, CGFloat high, NSInteger n) {
    CGFloat step = (high - low) / n;
    CGFloat area = 0.0;
    CGFloat y = 0;
    
    for(NSInteger i = 0; i < n; i++) {
        y = f(low + i * step) + f(low + (i + 1) * step); // 梯形法
        area += (y * step)/2.0;
    }
    return area;
}

- (void)initialSetup {
    headDustHeight = 73.0f * sizeRatio;
    smokeHeight = - 118.0f * sizeRatio;
    incenseHeight = 200.0f * sizeRatio;
    x = 2.5f;
    y = 0.0f;
    colorLocation = 0.8f;
    timeHaveGone = 0.0f;
    eulerSpiralLength = 0.0f;
}

@end
