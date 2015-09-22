//
//  CLFCardView.m
//  Incense
//
//  Created by CaiGavin on 9/20/15.
//  Copyright © 2015 CaiGavin. All rights reserved.
//

#import "CLFCardView.h"
#import "BMWaveMaker.h"
#include "CLFFunctions.h"
#import "CLFIncenseCommonHeader.h"
#import "CLFTools.h"

@interface CLFCardView ()

@property (nonatomic, weak) UIView *rippleView;
@property (nonatomic, strong) BMWaveMaker *rippleMaker;
@property (nonatomic, weak) UIImageView *shadowView;

@end

@implementation CLFCardView

static BOOL rippleMade = NO;

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor colorWithRed:245 / 255.0 green:245 / 255.0 blue:245 / 255.0 alpha:1.0];
    }
    return self;
}

- (void)setIncenseSnapshot:(UIView *)incenseSnapshot {
    _incenseSnapshot = incenseSnapshot;
    
    CGFloat cardViewH = CGRectGetHeight(self.frame);
    
    CGFloat incenseSnapshotW = 260;
    CGFloat incenseSnapshotH = incenseSnapshotW * self.containerRatio;
    CGFloat incenseSnapshotX = -0.5 * (incenseSnapshotW - (Incense_Screen_Width - 40 - 36) * 0.5);
    CGFloat incenseSnapshotY = CGRectGetHeight(self.frame) - 65 - incenseSnapshotH;
    incenseSnapshot.frame = CGRectMake(incenseSnapshotX, incenseSnapshotY, incenseSnapshotW, incenseSnapshotH);
    [self.shotView addSubview:incenseSnapshot];
    
    [CLFTools positionFloatingInView:incenseSnapshot
                          withValue1:(cardViewH - 63)
                              value2:(cardViewH - 66)
                       layerPosition:CGPointMake(incenseSnapshotX, cardViewH - 63)
                         anchorPoint:CGPointMake(0, 1)
                       animationTime:4.0f];
    
    self.shadowView.frame = CGRectMake((incenseSnapshotX + 0.5 * incenseSnapshotW - 3), cardViewH - 62, 6, 3);
    [CLFTools boundsFloatingInView:self.shadowView
                         withRect1:CGRectMake(0, 0, 6, 3)
                             rect2:CGRectMake(0, 0, 3, 1.5)
                     layerPosition:CGPointMake(incenseSnapshotX + 0.5 * incenseSnapshotW, cardViewH - 60)
                       anchorPoint:CGPointMake(0.5, 0.5)
                     animationTime:4.0f];
}


- (UIImageView *)shadowView {
    if (!_shadowView) {
        UIImageView *incenseShadowView = [[UIImageView alloc] init];
        incenseShadowView.image = [UIImage imageNamed:@"影"];
        [self.shotView addSubview:incenseShadowView];
        _shadowView = incenseShadowView;
    }
    return _shadowView;
}

- (UIImageView *)shotView {
    if (!_shotView) {
        UIImageView *shotView = [[UIImageView alloc] init];
//        shotView.backgroundColor = [UIColor blueColor];
        [self addSubview:shotView];
        _shotView = shotView;
    }
    return _shotView;
}

- (UIView *)poemView {
    if (!_poemView) {
        UIView *poemView = [[UIView alloc] init];
        poemView.backgroundColor = [UIColor whiteColor];
        [self addSubview:poemView];
        _poemView = poemView;
    }
    return _poemView;
}

- (void)layoutSubviews {
    self.shotView.frame = CGRectMake(8, 20, (CGRectGetWidth(self.frame) - 36) * 0.5, CGRectGetHeight(self.frame) - 40);
    self.poemView.frame = CGRectMake(CGRectGetMaxX(self.shotView.frame) + 8, 20, CGRectGetWidth(self.shotView.frame), CGRectGetHeight(self.shotView.frame));
    
    if (!rippleMade) {
        [self makeRipple];
        rippleMade = YES;
    }
}

- (UIView *)rippleView {
    if (!_rippleView) {
        UIView *rippleView = [[UIView alloc] init];
        rippleView.frame = CGRectMake(0, CGRectGetHeight(self.frame) - 110, CGRectGetWidth(self.shotView.frame), 100);
//        rippleView.backgroundColor = [UIColor blueColor];
        rippleView.backgroundColor = [UIColor clearColor];
        [self.shotView addSubview:rippleView];
        _rippleView = rippleView;
    }
    return _rippleView;
}

- (void)makeRipple {
    self.rippleView.alpha = 1.0f;
    
    self.rippleMaker.animationView = self.rippleView;
    
    [self.rippleMaker spanWaveContinuallyWithTimeInterval:4];
    
    CATransform3D rotate = CATransform3DMakeRotation(M_PI / 3, 1, 0, 0);
    self.rippleView.layer.transform = CATransform3DPerspect(rotate, CGPointMake(0, 0), 200);
}

- (BMWaveMaker *)rippleMaker {
    if (!_rippleMaker) {
        _rippleMaker = [[BMWaveMaker alloc] init];
        _rippleMaker.spanScale = 60.0f;
        _rippleMaker.originRadius = 0.9f;
        _rippleMaker.waveColor = [UIColor whiteColor];
        _rippleMaker.animationDuration = 30.0f;
        _rippleMaker.wavePathWidth = 1.5f;
    }
    return _rippleMaker;
}




@end
