//
//  Waver.m
//  Waver
//
//  Created by kevinzhow on 14/12/14.
//  Copyright (c) 2014年 Catch Inc. All rights reserved.
//

#import "Waver.h"

@interface Waver ()

@property (nonatomic) CGFloat phase;
@property (nonatomic) CGFloat amplitude;
@property (nonatomic) NSMutableArray *waves;
@property (nonatomic) CGFloat waveHeight;
@property (nonatomic) CGFloat waveWidth;
@property (nonatomic) CGFloat waveMid;
@property (nonatomic) CGFloat maxAmplitude;

@end

@implementation Waver

- (id)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.gradientLayers = [NSMutableArray array];
    self.waves = [NSMutableArray array];
    
    self.frequency = 1.2f;
    
    self.amplitude = 1.0f;
    self.idleAmplitude = 0.04f;
    
    self.numberOfWaves = 20;
    self.phaseShift = -0.25f;
    self.density = 1.0f;
    
    self.waveColor = [UIColor whiteColor];
    self.mainWaveWidth = 3.0f;
    self.decorativeWavesWidth = 3.0f;
    
	self.waveHeight = CGRectGetHeight(self.bounds);
    self.waveWidth  = CGRectGetWidth(self.bounds);
    self.waveMid    = self.waveWidth / 2.0f;
    self.maxAmplitude = self.waveHeight - 4.0f;
}

- (void)setWaverLevelCallback:(void (^)(Waver * waver))waverLevelCallback {
    _waverLevelCallback = waverLevelCallback;

    _displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(invokeWaveCallback)];
    _displaylink.frameInterval = 8;
    [_displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    for (int i = 0; i < self.numberOfWaves; i++) {
        CAShapeLayer *waveline = [CAShapeLayer layer];
        waveline.lineCap       = kCALineCapButt;
        waveline.lineJoin      = kCALineJoinRound;
        waveline.strokeColor   = [[UIColor clearColor] CGColor];
        waveline.fillColor     = [[UIColor clearColor] CGColor];
        [waveline setLineWidth:(i == 0 ? self.mainWaveWidth : self.decorativeWavesWidth)];
        
        CGFloat progress = 1.0f - (CGFloat)i / self.numberOfWaves; // ??
        CGFloat multiplier = MIN(1.0, (progress / 3.0f * 2.0f) + (1.0f / 3.0f)); // ??
        
		UIColor *color = [self.waveColor colorWithAlphaComponent:(1.0 * multiplier * 0.4)];
		waveline.strokeColor = color.CGColor;
        [self.layer addSublayer:waveline];
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.startPoint = CGPointMake(0.0, 0.0);
        gradientLayer.endPoint = CGPointMake(0.0, 1.0);
        
        gradientLayer.frame = CGRectMake(0, 0, 375, [UIScreen mainScreen].bounds.size.height - 300);
        
        NSMutableArray *colors = [NSMutableArray array];
        
        [colors addObject:(id)[UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:0.0f].CGColor];
        [colors addObject:(id)[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.4f].CGColor];
        [colors addObject:(id)[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.7f].CGColor];
        [colors addObject:(id)[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f].CGColor];
        [colors addObject:(id)[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.8f].CGColor];
        [colors addObject:(id)[UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:0.4f].CGColor];
        
        gradientLayer.colors = colors;
        
        gradientLayer.position = CGPointMake(0, 0);
        gradientLayer.anchorPoint = CGPointMake(0, 0);
        
        [gradientLayer setMask:waveline];
        [self.layer addSublayer:gradientLayer];
        
        [self.gradientLayers addObject:gradientLayer];
        [self.waves addObject:waveline];
    }
}

-(void)invokeWaveCallback {
    _waverLevelCallback(self);
//    NSLog(@"invokeWaveCallback");
}

- (void)setLevel:(CGFloat)level {
    _level = level / 3;
    self.phase += self.phaseShift; // Move the wave
    self.amplitude = fmax(_level, self.idleAmplitude);
    [self updateMetersWithLevel:level];
}

- (void)updateMetersWithLevel:(CGFloat)level {
	self.waveHeight = CGRectGetHeight(self.bounds);
    self.waveHeight = self.waveHeight ? : [UIScreen mainScreen].bounds.size.height - 300;
    self.waveWidth = CGRectGetWidth(self.bounds);
    self.waveWidth  = self.waveWidth ? : [UIScreen mainScreen].bounds.size.width;
	self.waveMid    = self.waveHeight;
	self.maxAmplitude = self.waveHeight - 4.0f;
    
    UIGraphicsBeginImageContext(self.frame.size);
    
    for (int i = 0; i < self.numberOfWaves; i++) {
        UIBezierPath *wavelinePath = [UIBezierPath bezierPath];

        // Progress is a value between 1.0 and -0.5, determined by the current wave idx, which is used to alter the wave's amplitude.
        CGFloat progress = 1.0f - (CGFloat)i / self.numberOfWaves;
        CGFloat normedAmplitude = (1.0f * progress - 0.5f) * self.amplitude;
        
        for (CGFloat y = (self.density + self.waveHeight); y > 0; y -= self.density) {
            
            //Thanks to https://github.com/stefanceriu/SCSiriWaveformView
            // We use a parable to scale the sinus wave, that has its peak in the middle of the view.
            CGFloat scaling = -pow((y) / self.waveMid - 1, 2) + 1; // make center bigger
            
            CGFloat x = scaling * self.maxAmplitude * normedAmplitude * sinf(2 * M_PI *((y) / self.waveHeight) * self.frequency + self.phase) + (self.waveWidth * 0.5);
            
            if ((self.density + self.waveHeight - y) == 0) {
                [wavelinePath moveToPoint:CGPointMake(x, (self.density + self.waveHeight - y))];
            } else {
                [wavelinePath addLineToPoint:CGPointMake(x, (self.density + self.waveHeight - y))];
            }
        }
        CAShapeLayer *waveline = [self.waves objectAtIndex:i];
        waveline.path = [wavelinePath CGPath];
    }
    UIGraphicsEndImageContext();
    
    for (CAGradientLayer *layer in self.gradientLayers) {
        CGFloat gradientHeight = CGRectGetHeight(layer.bounds) + 2.5;
        layer.bounds = CGRectMake(0, 0, 375, gradientHeight);
    }
}

@end
