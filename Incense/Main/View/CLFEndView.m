//
//  CLFEndView.m
//  Incense
//
//  Created by CaiGavin on 8/21/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "CLFEndView.h"
#import "CLFIncenseCommonHeader.h"
#import "CLFEndButton.h"

@interface CLFEndView ()

@property (nonatomic, weak) UIImageView *blurView;
@property (nonatomic, weak) UIView      *finishView;
@property (nonatomic, weak) UIImageView *finishImageView;
@property (nonatomic, weak) UIButton    *restartButton;
@property (nonatomic, weak) UIImageView *shadowView;

@end

@implementation CLFEndView

- (instancetype)init {
    if (self = [super init]) {
        self.userInteractionEnabled = YES;
        
        UIView *finishedView = [[UIView alloc] init];
        finishedView.backgroundColor = [UIColor clearColor];
        [self addSubview:finishedView];
        _finishView = finishedView;
        
        UIImageView *finishImageView = [[UIImageView alloc] init];
        [_finishView addSubview:finishImageView];
        finishImageView.contentMode = UIViewContentModeTop;
        finishImageView.backgroundColor = [UIColor clearColor];
        _finishImageView = finishImageView;
        
        UIImageView *shadowView = [[UIImageView alloc] init];
        shadowView.image = [UIImage imageNamed:@"影子"];
        [_finishView addSubview:shadowView];
        _shadowView = shadowView;

        
        UIButton *restartButton = [[UIButton alloc] init];
        [_finishView addSubview:restartButton];
        restartButton.imageView.bounds = CGRectMake(0, 0, 24, 24);
        [restartButton setContentHorizontalAlignment: UIControlContentHorizontalAlignmentCenter];
        [restartButton setContentVerticalAlignment: UIControlContentVerticalAlignmentCenter];
        [restartButton setImageEdgeInsets:UIEdgeInsetsMake(11, 11, 11, 11)];
        restartButton.contentMode = UIViewContentModeTop;
        [restartButton setImage:[UIImage imageNamed:@"按钮"] forState:UIControlStateNormal];
        
        [restartButton addTarget:self action:@selector(wantOneMoreIncense) forControlEvents:UIControlEventTouchUpInside];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showTheShareView)];
        [restartButton addGestureRecognizer:longPress];
        restartButton.adjustsImageWhenHighlighted = NO;
        
        _restartButton = restartButton;
        
        CABasicAnimation* rotationAnimation;
        rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 1.5];
        rotationAnimation.duration = 3.0;
        rotationAnimation.cumulative = YES;
        rotationAnimation.repeatCount = 10000;
        [_restartButton.layer addAnimation:rotationAnimation forKey:@"rotationAnimation2"];
        
    }
    return self;
}

- (UIImageView *)blurView {
    if (!_blurView) {
        UIImageView *blurView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];

        blurView.userInteractionEnabled = YES;
        blurView.frame = self.frame;
        blurView.alpha = 0.0f;
        [self addSubview:blurView];

        CLFEndButton *restartButton = [[CLFEndButton alloc] init];
        [blurView addSubview:restartButton];
        restartButton.frame = self.frame;

        restartButton.backgroundColor = [UIColor clearColor];
        [restartButton addTarget:self action:@selector(showFinishView) forControlEvents:UIControlEventTouchUpInside];
        restartButton.endImageView.image = [UIImage imageNamed:@"時"];

        _blurView = blurView;
    }
    return _blurView;
}

- (void)layoutSubviews {
    self.finishView.frame = self.frame;
    CGFloat restartButtonW = 48;
    CGFloat restartButtonH = restartButtonW;
    
    self.restartButton.frame = CGRectMake((Incense_Screen_Width - restartButtonW) * 0.5, Incense_Screen_Height * 0.875, restartButtonW, restartButtonH);
    self.shadowView.frame = CGRectMake((Incense_Screen_Width - 26) * 0.5, Incense_Screen_Height * 0.875 + 13, 26, 26);
}

- (void)setupWithBurntOffNumber:(NSString *)numberString {
    CGFloat digitW = 20 * Size_Ratio_To_iPhone6;
    CGFloat digitH = digitW + 2 * Size_Ratio_To_iPhone6;
    self.blurView.alpha = 1.0f;
    self.finishImageView.frame = CGRectMake((Incense_Screen_Width - digitW) * 0.5, Incense_Screen_Height * 0.25 - 10, digitW, 300);
    
    NSInteger totalNumber = numberString.length;

    CGFloat digitX = 0;
    for (NSInteger i = 0; i <= totalNumber; i++) {
        CGFloat digitY = i * (digitH + 10);
        UIImageView *digitImageView = [[UIImageView alloc] init];
        if (i == totalNumber) {
            digitImageView.frame = CGRectMake(digitW * 0.5 - 5, digitY + 3, 10, 10);
            digitImageView.image = [UIImage imageNamed:@"句号"];
        } else {
            digitImageView.frame = CGRectMake(digitX, digitY, digitW, digitH);
            NSRange range = NSMakeRange(i, 1);
            NSString *imageName = [numberString substringWithRange:range];
            digitImageView.image = [UIImage imageNamed:imageName];
        }
        digitImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.finishImageView addSubview:digitImageView];
    }
}

- (void)setupWithFailure {
    self.blurView.alpha = 0.0f;
    CGFloat finishViewW = 22 * Size_Ratio_To_iPhone6;
    CGFloat finishViewH = 40 * Size_Ratio_To_iPhone6;
    self.finishImageView.frame = CGRectMake((Incense_Screen_Width - finishViewW) * 0.5, Incense_Screen_Height * 0.25 - finishViewH, finishViewW, finishViewH);
    self.finishImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.finishImageView.image = [UIImage imageNamed:@"灭"];
}

- (void)showFinishView {
    [UIView animateWithDuration:1.0f animations:^{
        self.blurView.alpha = 0.0f;
    }];
}

- (void)wantOneMoreIncense {
    if ([self.delegate respondsToSelector:@selector(oneMoreIncense)]) {
        [self.delegate oneMoreIncense];
    }
    
    [self.restartButton.layer removeAllAnimations];
    
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: -M_PI * 8.0];
    rotationAnimation.duration = 3.0;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 3;
    [self.restartButton.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)showTheShareView {
    if ([self.delegate respondsToSelector:@selector(showShareView)]) {
        [self.delegate showShareView];
    }
}


@end
