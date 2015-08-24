//
//  CLFIncenseView.m
//  Incense
//
//  Created by CaiGavin on 8/10/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "CLFIncenseView.h"
#import "CLFIncenseCommonHeader.h"
#import "Masonry.h"
#import "Waver.h"
#import <math.h>

@interface CLFIncenseView ()

@property (nonatomic, assign, getter=isBlowing)   BOOL            blowing;
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
static CGFloat incenseHeight;

static CGFloat timeHaveGone;
static CGFloat incenseBurnOffLength;
static CGFloat incenseStickHeight;

static const CGFloat kIncenseWidth = 5.0f;
static const CGFloat kIncenseStickWidth = 2.0f;


- (instancetype)init {
    self = [super init];
    if (self) {
        waverHeight = -[UIScreen mainScreen].bounds.size.height;
        incenseBurnOffLength = 64.0f * Size_Ratio_To_iPhone6;
        incenseStickHeight = 70.0f * Size_Ratio_To_iPhone6;
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
            make.top.equalTo(self.headDustView.mas_bottom).offset(-10.5);
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
            make.height.equalTo(self).offset(-50 * Size_Ratio_To_iPhone6);
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
        [colors addObject:(id)[UIColor colorWithRed:190/255.0 green:190/255.0 blue:190/255.0 alpha:1.0f].CGColor];
//        [colors addObject:(id)[UIColor colorWithRed:231/255.0 green:2/255.0 blue:2/255.0 alpha:1.0f].CGColor];
        [colors addObject:(id)[UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0f].CGColor];

        
        dustGradient.colors = colors;
        dustGradient.locations = @[@0.0f, @0.9f, @2.0f];
        
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

- (void)layoutSubviews {
    self.headDustView.frame = CGRectMake(0, -headDustHeight + 4, 69, headDustHeight);
    
    self.incenseStick.backgroundColor = [UIColor blackColor];
    
    self.waver.frame = CGRectMake(0, 0, Incense_Screen_Width, waverHeight);
}

- (void)setBrightnessCallback:(void (^)(CLFIncenseView *))brightnessCallback {
    _brightnessCallback = brightnessCallback;
    
    _displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(invokeBrightnessCallback)];
    _displaylink.frameInterval = 8;
    [_displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    self.blowing = NO;
}

- (void)invokeBrightnessCallback {
    UIGraphicsBeginImageContextWithOptions(self.headDustView.frame.size, NO, 0.0f);

    _brightnessCallback(self);
        UIGraphicsEndImageContext();
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


/**
 *  Return the time have passed by.
 */
- (CGFloat)timeHaveGone {
    return timeHaveGone;
}

/**
 *  The dust shape should be redrawed when users back to app from lockScreen status. This is so called modifyDust.
 */
static BOOL modifyDust = NO;
static BOOL burntOffFromBackground = NO;

- (void)renewStatusWithTheTimeHaveGone:(CGFloat)timeInterval {
    modifyDust = YES;
    CGFloat tempIncenseHeight = incenseHeight - timeInterval * (135.0f * Size_Ratio_To_iPhone6 / Incense_Burn_Off_Time);
    if (tempIncenseHeight > incenseBurnOffLength) {
        incenseHeight = tempIncenseHeight;
        waverHeight -= timeInterval * (135.0f * Size_Ratio_To_iPhone6 / Incense_Burn_Off_Time);
        colorLocation -= timeInterval * (2.2 / 100) * (60 / self.displaylink.frameInterval);
        x += timeInterval * 0.0072f * (60 / self.displaylink.frameInterval);
    } else {
        incenseHeight = incenseBurnOffLength;
        waverHeight = -703 * Size_Ratio_To_iPhone6;
        colorLocation = 0.0f;
        x = 5.5;
        burntOffFromBackground = YES;
        NSLog(@"Else timeInterval %f, incenseHeight %f", timeInterval, incenseHeight);
    }
}


/**
 *  Once the CADisplayLink method be called, one point should be drawed in context. We chose the Euler spiral as the shape of dust.
 *  At the same time adjust the height and dust gradient of incense.
 */

static CGFloat x = 2.5f;
static CGFloat y = 0.0f;
static CGFloat colorLocation = 0.8f;

- (void)updateHeightWithBrightnessLevel:(CGFloat)brightnessLevel {
    CGFloat declineDistance = Incense_Burn_Off_Time * 60 / self.displaylink.frameInterval;

    timeHaveGone += 1.0 / (60.0 / self.displaylink.frameInterval);
    
    incenseHeight -= 135.0f * Size_Ratio_To_iPhone6 / declineDistance;
    self.frame = (CGRect){self.frame.origin, {Incense_Screen_Width, incenseHeight}};
    
    waverHeight -= 135.0f * Size_Ratio_To_iPhone6 / declineDistance;
    self.waver.frame = (CGRect) {{0, 0}, {Incense_Screen_Width, waverHeight}};
    
    colorLocation = colorLocation - 0.1 / 100 > 0 ? colorLocation - 0.1 / 100 : 0.0f;
    self.dustGradient.locations = @[@0.0f, @(colorLocation), @1.0f];
    
    if (!modifyDust) {
        [self drawEulerSpiralDust];
    } else {
        CGFloat tempX = x;
        x = 2.5;
        while (x < tempX) {
            [self drawEulerSpiralDust];
        }
        modifyDust = NO;
    }
    
    self.dustGradient.bounds = self.headDustView.bounds;
    
    if (incenseHeight <= incenseBurnOffLength && !burntOffFromBackground) {
        [self.delegate incenseDidBurnOff];
        self.lightView.alpha = 0.0f;
    } else if (burntOffFromBackground) {
        [self.delegate incenseDidBurnOffFromBackgroundWithResult:@"success"];
        burntOffFromBackground = NO;
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
    
#warning - TODO: 位置换掉??
    if (x == 2.5) {
        e = x - 2.5;
        m = 2.5 + 40 * Size_Ratio_To_iPhone6 * integral(fresnelSin, 0, e, 10);
        n = 3.5 + 40 * Size_Ratio_To_iPhone6 * integral(fresnelCos, 0, e, 10);
        previousM = m;
        previousN = n;
        
        [self.dustPath moveToPoint:CGPointMake(m, headDustHeight - n)];
    } else if (x < 5.5){
        e = x - 2.5;
        m = 2.5 + 40 * Size_Ratio_To_iPhone6 * integral(fresnelSin, 0, e, 10);
        n = 3.5 + 40 * Size_Ratio_To_iPhone6 * integral(fresnelCos, 0, e, 10);
        
        eulerSpiralLength += distance(previousM, previousN, m, n);
        previousM = m;
        previousN = n;
        
        [self.dustPath addLineToPoint:CGPointMake(m, headDustHeight - n)];
    }
    
    x += 0.0072f / (Incense_Burn_Off_Time / 60.0f);
    self.dustLine.path = self.dustPath.CGPath;
    

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
    headDustHeight = 73.0f * Size_Ratio_To_iPhone6;
    incenseHeight = 200.0f * Size_Ratio_To_iPhone6;
    x = 2.5f;
    y = 0.0f;
    colorLocation = 0.8f;
    timeHaveGone = 0.0f;
    eulerSpiralLength = 0.0f;
}

@end
