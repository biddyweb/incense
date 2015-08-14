//
//  CLFSmokeView.m
//  Incense
//
//  Created by CaiGavin on 8/11/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "CLFSmokeView.h"

@implementation CLFSmokeView

- (UIView *)smoke {
    if (_smoke == nil) {
        UIView *smoke = [[UIView alloc] init];
        smoke.frame = self.bounds;
        smoke.backgroundColor = [UIColor whiteColor];
        [self addSubview:smoke];
        _smoke = smoke;
    }
    return _smoke;
}

- (void)layoutSubviews {
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.startPoint = CGPointMake(0.0, 0.0);
    gradientLayer.endPoint = CGPointMake(0.0, 1.0);
    
    gradientLayer.frame = self.bounds;
    NSMutableArray *colors = [NSMutableArray array];

    [colors addObject:(id)[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f].CGColor];
    [colors addObject:(id)[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f].CGColor];
    [colors addObject:(id)[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.8f].CGColor];
    [colors addObject:(id)[UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:0.5f].CGColor];
    
    gradientLayer.locations = @[@0.30, @0.65, @.85, @1.0];
    gradientLayer.colors = colors;
    
    [gradientLayer setMask:self.smoke.layer];
    [self.layer addSublayer:gradientLayer];
}

@end
