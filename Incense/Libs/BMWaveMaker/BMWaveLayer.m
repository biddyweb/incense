//
//  BMWaveLayer.m
//  BMWaveViewDemo
//
//  Created by DingXiao on 15/8/3.
//  Copyright (c) 2015年 Dennis. All rights reserved.
//

#import "BMWaveLayer.h"

@implementation BMWaveLayer

- (void)dealloc {
    [self removeAllAnimations];
}

- (void)startAnimation {
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = self.animationDuration;
    animationGroup.repeatCount = 0;
    animationGroup.removedOnCompletion = NO;
    animationGroup.fillMode = kCAFillModeForwards;
//    animationGroup.fillMode = kCAFillModeBoth;
    animationGroup.delegate = self;
    
    CAKeyframeAnimation *keyFrameAnimation = [CAKeyframeAnimation animation];
    keyFrameAnimation.keyPath = @"path";
    keyFrameAnimation.duration = self.animationDuration;
    keyFrameAnimation.values = @[
                                 (__bridge id)self.fromPath.CGPath,
                                 (__bridge id)self.toPath.CGPath
                                ];
    keyFrameAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
//    CABasicAnimation * opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
//    opacityAnimation.fromValue = @0.5;
//    opacityAnimation.toValue = @0;

//    by GavinCai
    
    CAKeyframeAnimation *opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.values = @[@0.8, @1.0, @1.0, @0];
    opacityAnimation.calculationMode = kCAAnimationLinear;
    opacityAnimation.keyTimes = @[@0.00, @0.3, @0.55, @1.0];
    
    animationGroup.animations = @[keyFrameAnimation, opacityAnimation];
    
    [self addAnimation:animationGroup forKey:@"wave"];
}

#pragma mark - animation delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self removeFromSuperlayer];
    if ([self.waveDelegate respondsToSelector:@selector(waveLayerDidFinishAnimation)]) {
        [self.waveDelegate waveLayerDidFinishAnimation];
    }
}

#pragma mark - getter
- (CFTimeInterval)animationDuration {
    if (_animationDuration <= 0) {
        _animationDuration = 1.0f;
    }
    return _animationDuration;
}


@end
