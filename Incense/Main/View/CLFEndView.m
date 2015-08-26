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
        
        UIButton *restartButton = [[UIButton alloc] init];
        [_finishView addSubview:restartButton];
        
        restartButton.imageView.bounds = CGRectMake(0, 0, 24, 24);
        [restartButton setContentHorizontalAlignment: UIControlContentHorizontalAlignmentCenter];
        [restartButton setContentVerticalAlignment: UIControlContentVerticalAlignmentTop];
        [restartButton setImageEdgeInsets:UIEdgeInsetsMake(5, 11, 17, 11)];
        restartButton.contentMode = UIViewContentModeTop;
        [restartButton setImage:[UIImage imageNamed:@"轮回"] forState:UIControlStateNormal];
        
        [restartButton addTarget:self action:@selector(wantOneMoreIncense) forControlEvents:UIControlEventTouchUpInside];
        _restartButton = restartButton;
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
}

- (void)setupWithBurntOffNumber:(NSString *)numberString {
    CGFloat digitW = 20 * Size_Ratio_To_iPhone6;
    CGFloat digitH = digitW + 2 * Size_Ratio_To_iPhone6;
    self.blurView.alpha = 1.0f;
    self.finishImageView.frame = CGRectMake((Incense_Screen_Width - digitW) * 0.5, Incense_Screen_Height * 0.25, digitW, 300);
    
    NSInteger totalNumber = numberString.length;

    CGFloat digitX = 0;
    for (NSInteger i = 0; i <= totalNumber; i++) {
        CGFloat digitY = i * (digitH + 10);
        UIImageView *digitImageView = [[UIImageView alloc] init];
        if (i == totalNumber) {
            digitImageView.frame = CGRectMake(digitW * 0.5 - 3, digitY + 3, 6, 6);
            digitImageView.image = [UIImage imageNamed:@"period"];
        } else {
            digitImageView.frame = CGRectMake(digitX, digitY, digitW, digitH);
            NSRange range = NSMakeRange(i, 1);
            NSString *imageName = [numberString substringWithRange:range];
            digitImageView.image = [UIImage imageNamed:imageName];
        }
        [self.finishImageView addSubview:digitImageView];
    }
}

- (void)setupWithFailure {
    self.blurView.alpha = 0.0f;
    CGFloat finishViewW = 22 * Size_Ratio_To_iPhone6;
    CGFloat finishViewH = 44 * Size_Ratio_To_iPhone6;
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
}

@end
