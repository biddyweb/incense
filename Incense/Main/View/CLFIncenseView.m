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
#import "CLFCATransform3D.h"

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

static CGFloat headHeight;
static CGFloat waverHeight;
static CGFloat smokeHeight;
static CGFloat incenseHeight;
static CGFloat screenWidth;
static CGFloat screenHeight;

static const CGFloat kIncenseWidth = 5.0f;
static const CGFloat kIncenseStickWidth = 2.0f;
static const CGFloat kIncenseStickHeight = 70.0f;

- (instancetype)init
{
    self = [super init];
    if (self) {
        screenWidth = [UIScreen mainScreen].bounds.size.width;
        screenHeight = [UIScreen mainScreen].bounds.size.height;
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
        [self.headDustView addSubview:lightView];
        [lightView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.headDustView.mas_left).offset(2);
            make.top.equalTo(self.headDustView.mas_bottom).offset(-14);
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
        UIView *headDustView = [[UIView alloc] init];
        headDustView.backgroundColor = [UIColor clearColor];
        [self.incenseBodyView insertSubview:headDustView aboveSubview:self.waver];
//        [self.incenseBodyView addSubview:headDustView];
        _headDustView = headDustView;
    }
    return _headDustView;
}

#warning mark 待修改
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
        dustGradient.startPoint = CGPointMake(0.0, 0.0);
        dustGradient.endPoint = CGPointMake(0.0, 1.0);
        dustGradient.frame = self.headDustView.frame;
        
        NSMutableArray *colors = [NSMutableArray array];
        [colors addObject:(id)[UIColor colorWithRed:155/255.0 green:155/255.0 blue:155/255.0 alpha:1.0f].CGColor];
        [colors addObject:(id)[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f].CGColor];
        [colors addObject:(id)[UIColor colorWithRed:155/255.0 green:155/255.0 blue:155/255.0 alpha:1.0f].CGColor];
        
        dustGradient.colors = colors;
        
        dustGradient.locations = @[@0.05,@0.95, @1.0];
        
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
            make.height.equalTo(@(kIncenseStickHeight));
            make.width.equalTo(@(kIncenseStickWidth));
        }];
        _incenseStick = incenseStick;
    }
    return _incenseStick;
}

- (UIImageView *)smokeView {
    if (!_smokeView) {
        UIImageView *smokeView = [[UIImageView alloc] init];
        smokeView.image = [UIImage imageNamed:@"天"];
        [self addSubview:smokeView];
        [self bringSubviewToFront:smokeView];
        _smokeView = smokeView;
    }
    return _smokeView;
}

- (void)layoutSubviews {
    self.headDustView.frame = CGRectMake(0, -37, 35, 45);
    
    self.incenseStick.backgroundColor = [UIColor blackColor];
    
    self.waver.frame = CGRectMake(0, 0, screenWidth, waverHeight);
    
    self.smokeView.frame = CGRectMake(0, - (screenHeight - 460), screenWidth, smokeHeight);
}

- (void)setBrightnessCallback:(void (^)(CLFIncenseView *))brightnessCallback {
    _brightnessCallback = brightnessCallback;
    
    _displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(invokeBrightnessCallback)];
    _displaylink.frameInterval = 1;
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

static CGFloat x = 2.5f;
static CGFloat y = 0.0f;
static CGFloat theta = M_PI;
- (void)updateHeightWithBrightnessLevel:(CGFloat)brightnessLevel {
    incenseHeight -= 135.0f / 500;
    self.frame = (CGRect){self.frame.origin, {screenWidth, incenseHeight}};
    
    waverHeight -= 135.0f / 500;
    self.waver.frame = (CGRect) {{0, 0}, {screenWidth, waverHeight}};
    
    smokeHeight -= 135.0f / 500;
    self.smokeView.frame = (CGRect){self.smokeView.frame.origin, {screenWidth, smokeHeight}};
    

    
    if (x == 2.5) {
        y = 37.5;
        [self.dustPath moveToPoint:CGPointMake(x, y)];
    } else if (x <= 12.5) {
        [self.dustPath addLineToPoint:CGPointMake(2.5, 37.5 - x)];
        // 在两个函数切换时会突然加速= = 因为...函数的增长速率啊啊啊啊擦.
        // 第一个函数是线性增长,但椭圆不是啊擦 走过同样长度的周长?
        // 每移动一次, 灰烬的长度增加0.1, 则到了椭圆函数时,要调整 x 的值, 令 椭圆在(x, x + delta x)区间内的周长长度 c = 0.1 (0.1为每次移动后灰烬增加的高度);
        // --> 方程的解太坑爹...换方法吧
    } else if (x < 15.5 && x > 12.5) {
//        CGFloat temp = x - 10;
//        y = (1 / 6.0) * (135 - 4 * sqrt(-4 * temp * temp + 140 * temp - 325)); // 以(17.5, 22.5)为中心点, a = 15, b = 20 的椭圆.
//        y = (1 / 2.0) * (35 - sqrt(-4 * temp * temp + 140 * temp - 325));  // 以(17.5, 17.5)为圆心, r = 15 的圆.
//        CGFloat s = 15 * sqrt(1 - (1 - 400.0 / 225) * sin(x - 10 ));
//        NSLog(@"%f", s);
        CGFloat temp = 17.5 + 15 * cos(theta + x); // 椭圆的参数方程形式.
        y = 25 + 20 * sin(theta + x);
        
        [self.dustPath addLineToPoint:CGPointMake(temp, y)];
    } else {
        
    }
    
//    NSLog(@"x : %f, y : %f", x, y);
    if (x <= 12.5) {
        x += 0.1;
    } else {
        x += 0.005; // 要调整
    }
    
    self.dustLine.path = self.dustPath.CGPath;
    
    UIGraphicsEndImageContext();
    
    self.dustGradient.bounds = self.headDustView.bounds;
    
    if (incenseHeight <= 65.0f) {
        [self.delegate incenseDidBurnOff];
        self.lightView.alpha = 0.0f;
    }
}

- (void)initialSetup {
    headHeight = -0.0f;
    smokeHeight = -180.0f;
    incenseHeight = 200.0f;
    x = 2.5f;
    y = 0.0f;
}

@end
