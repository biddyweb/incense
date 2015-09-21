//
//  CLFCloud.m
//  Incense
//
//  Created by CaiGavin on 8/19/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "CLFIncenseCommonHeader.h"
#import "CLFCloud.h"
#import "CLFMathTools.h"

@interface CLFCloud ()

@property (nonatomic, weak) UIView *fireImage;
@property (nonatomic, weak) UILabel *timeLabel;

@end

@implementation CLFCloud

static CGFloat lengthNeedToBeCut;
static CGPoint beginPoint;
static CGFloat beginCenterY = -140.0f;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        // MARK: dragEnable? 
        self.dragEnable = YES;
        self.wouldBurnt = NO;
    }
    return self;
}

- (UIImageView *)cloudImageView {
    if (!_cloudImageView) {
        UIImageView *cloudImageView = [[UIImageView alloc] init];
        cloudImageView.image = [UIImage imageNamed:@"云雾"];
        [self addSubview:cloudImageView];
        _cloudImageView = cloudImageView;
    }
    return _cloudImageView;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        UILabel *timeLabel = [[UILabel alloc] init];
        timeLabel.textAlignment = NSTextAlignmentCenter;
        timeLabel.font = [UIFont fontWithName:@"STFangsong" size:18];
        timeLabel.textColor = [UIColor blackColor];
        timeLabel.text = @"叄拾";
        timeLabel.alpha = 0.0;
        [self addSubview:timeLabel];
        _timeLabel = timeLabel;
    }
    return _timeLabel;
}

- (void)layoutSubviews {
    self.cloudImageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    self.timeLabel.frame = CGRectMake((CGRectGetWidth(self.frame) - 100) * 0.5, CGRectGetHeight(self.frame) - 140, 100, 50);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.isDragEnable) {
        return;
    }

    UITouch *touch = [touches anyObject];
    beginPoint = [touch locationInView:self];
    beginCenterY = self.center.y;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.isDragEnable) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    
    CGPoint currentPoint = [touch locationInView:self];
    
    CGFloat offsetY = currentPoint.y - beginPoint.y;

    // MARK: Incense Height ---> 200 trigger
    CGFloat incenseToTopDistance = Incense_Screen_Height - 200 * Size_Ratio_To_iPhone6 - Incense_Location;
    // 火永远距离云的底部 80 但是还要考虑 Fire 的高度 24. 加上 24 才是 fire 的底部所在的位置. 24 似乎还差一点, 改成 20
    // 云初始位置永远是 -380
    // 以上数字都不随屏幕的变化而变化
    CGFloat fireLocationModifyFactor = CGRectGetHeight(self.frame) - 380 - 80 + 20;
    
    CGFloat newCenterY = self.center.y + offsetY;
    CGFloat distance = newCenterY - beginCenterY;
    CGFloat burnLine = incenseToTopDistance - fireLocationModifyFactor;
    
    // 当一炷香总时间为30分钟时,其可燃烧长度为 135, 当它的燃烧总时间为15分钟时,可燃烧长度为67.5
    int totalSeconds = 1800;
    if (distance >= burnLine) {
        if (distance >= burnLine + 67.5 * Size_Ratio_To_iPhone6) {
            newCenterY = beginCenterY + burnLine + 67.5 * Size_Ratio_To_iPhone6;
            distance = burnLine + 67.5 * Size_Ratio_To_iPhone6;
        }
        
        self.timeLabel.alpha = 1.0;
        totalSeconds -= (distance - burnLine) * (900 / (67.5 * Size_Ratio_To_iPhone6));
        
//        int seconds = totalSeconds % 60;
        CGFloat minutes = round(totalSeconds / 60.0);
        
//        NSLog(@"minutes %f round minutes %f", minutes, round(minutes));
        NSString *timeString = [NSString stringWithFormat:@"%@%@", [CLFMathTools numberToChinese:minutes], @"分"];
//        self.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
        if ([timeString isEqualToString:@"貳拾分"]) {
            timeString = @"貳拾分鐘";
        } else if ([timeString isEqualToString:@"叄拾分"]) {
            timeString = @"兩刻鐘整";
        } else if ([timeString isEqualToString:@"壹拾伍分"]) {
            timeString = @"一刻鐘整";
        }
        
        
        self.timeLabel.text = timeString;
        
        lengthNeedToBeCut = distance - burnLine;
        self.wouldBurnt = YES;

    } else if (distance < burnLine) {
        self.timeLabel.alpha = 0.0f;
        self.wouldBurnt = NO;
    }
    
    self.center = CGPointMake(self.center.x, newCenterY);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.isDragEnable) {
        return;
    }
//    NSLog(@"self.center.y %f", self.center.y);
    // MARK: 180???
    self.timeLabel.alpha = 0.0f;
    [self.delegate cloudRebound];
    if (self.wouldBurnt) {
        [self.delegate lightTheIncenseWithIncenseHeight:200.0f * Size_Ratio_To_iPhone6 - lengthNeedToBeCut];
        self.dragEnable = NO;
    }
}

@end

