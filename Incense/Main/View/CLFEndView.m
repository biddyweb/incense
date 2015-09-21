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
#import "CLFShareView.h"
#import "CLFCardView.h"

@interface CLFEndView ()

@property (nonatomic, weak) UIImageView  *blurView;
@property (nonatomic, weak) UIView       *finishView;
//@property (nonatomic, weak) UIImageView  *finishImageView;
@property (nonatomic, weak) UIButton     *restartButton;
@property (nonatomic, weak) UIImageView  *shadowView;
@property (nonatomic, weak) UIButton     *shareButton;
@property (nonatomic, weak) CLFShareView *shareCardView;

@property (nonatomic, weak) UILabel      *numberLabel;

@end

@implementation CLFEndView

- (instancetype)init {
    if (self = [super init]) {
        self.userInteractionEnabled = YES;
        
        UIView *finishedView = [[UIView alloc] init];
        finishedView.backgroundColor = [UIColor clearColor];
        [self addSubview:finishedView];
        _finishView = finishedView;
        
//        UIImageView *finishImageView = [[UIImageView alloc] init];
//        [_finishView addSubview:finishImageView];
//        finishImageView.contentMode = UIViewContentModeTop;
//        finishImageView.backgroundColor = [UIColor clearColor];
//        _finishImageView = finishImageView;
        
        UILabel *numberLabel = [[UILabel alloc] init];
        [_finishView addSubview:numberLabel];
        numberLabel.numberOfLines = 0;
        numberLabel.font = [UIFont fontWithName:@"STFangsong" size:20];
        numberLabel.textColor = [UIColor blackColor];
        numberLabel.textAlignment = NSTextAlignmentCenter;
//        numberLabel.backgroundColor = [UIColor greenColor];
        [numberLabel sizeToFit];
        _numberLabel = numberLabel;
        
        UIImageView *shadowView = [[UIImageView alloc] init];
        shadowView.image = [UIImage imageNamed:@"影子"];
        [_finishView addSubview:shadowView];
        _shadowView = shadowView;
        
        UIButton *shareButton = [[UIButton alloc] init];
        [shareButton setTitle:@"分享" forState:UIControlStateNormal];
        shareButton.backgroundColor = [UIColor whiteColor];
        [shareButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        shareButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [shareButton addTarget:self action:@selector(showShareCard) forControlEvents:UIControlEventTouchUpInside];
        [_finishView addSubview:shareButton];
        _shareButton = shareButton;

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
    self.shareButton.frame = CGRectMake((Incense_Screen_Width - 100) * 0.5, self.shadowView.frame.origin.y - 50, 100, 30);
}

- (void)setupWithBurntOffNumber:(NSMutableString *)numberString incenseSnapShot:(UIView *)incenseShot {
    
    NSUInteger length = numberString.length;
    for (int i = 0; i < length - 1; i++) {
        [numberString insertString:@"\n\n" atIndex:3 * i + 1];
    }
    
    NSString *newNumberString = [NSString stringWithFormat:@"%@\n\n 。", numberString];
    NSMutableAttributedString *finalNumberString = [[NSMutableAttributedString alloc] initWithString:newNumberString];

    
    
    CGFloat digitW = 56 * Size_Ratio_To_iPhone6;
    self.shareButton.hidden = NO;
    self.numberLabel.frame = CGRectMake((Incense_Screen_Width - digitW) * 0.5 + 18, 0, digitW, 0.5 * Incense_Screen_Height);
    self.numberLabel.attributedText = [self arrangeAttributedString:finalNumberString];
    
    incenseShot.frame = CGRectMake(0, 100, 100, 50);
    incenseShot.backgroundColor = [UIColor greenColor];
    CLFCardView *card = self.shareCardView.cardView;
    [card.shotView addSubview:incenseShot];
}

- (NSMutableAttributedString *)arrangeAttributedString:(NSMutableAttributedString *)attributedString {
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"STFangsong" size:21] range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, attributedString.length - 1)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(attributedString.length - 1, 1)];
    
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.paragraphSpacing = -7;
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paraStyle range:NSMakeRange(0, attributedString.length - 3)];
    NSMutableParagraphStyle *paraStyle2 = [[NSMutableParagraphStyle alloc] init];
    paraStyle2.paragraphSpacing = -15;
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paraStyle2 range:NSMakeRange(attributedString.length - 3, 3)];
    return attributedString;
}

- (void)setupWithFailure {
    self.shareButton.hidden = YES;
    CGFloat finishViewW = 56 * Size_Ratio_To_iPhone6;
    self.numberLabel.frame = CGRectMake((Incense_Screen_Width - finishViewW) * 0.5 + 18, 0, finishViewW, 0.5 * Incense_Screen_Height);
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"滅\n\n 。"];
    self.numberLabel.attributedText = [self arrangeAttributedString:attributedString];
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
    if ([self.delegate respondsToSelector:@selector(showShareActivity)]) {
        [self.delegate showShareActivity];
    }
}

- (CLFShareView *)shareCardView {
    if (!_shareCardView) {
        CLFShareView *shareCardView = [[CLFShareView alloc] init];
        shareCardView.frame = self.frame;
        shareCardView.alpha = 0.0f;
        [self addSubview:shareCardView];
        _shareCardView = shareCardView;
    }
    return _shareCardView;
}

- (void)showShareCard {
    self.shareCardView.alpha = 1.0f;
}

@end
