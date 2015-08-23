//
//  CLFCloud.m
//  Incense
//
//  Created by CaiGavin on 8/19/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "CLFIncenseCommonHeader.h"
#import "CLFCloud.h"

@interface CLFCloud ()

@property (nonatomic, weak) UIView *fireImage;

@end

@implementation CLFCloud

static CGPoint beginPoint;
static CGFloat beginCenterY = -140.0f;


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.dragEnable = YES;
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


- (void)layoutSubviews {
    self.cloudImageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.isDragEnable) {
        return;
    }

    UITouch *touch = [touches anyObject];
    beginPoint = [touch locationInView:self];
    NSLog(@"begin center Y %f", self.center.y);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.isDragEnable) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    
    CGPoint currentPoint = [touch locationInView:self];
    
    CGFloat offsetY = currentPoint.y - beginPoint.y;

    CGFloat floorY = Incense_Screen_Height - 200 * Size_Ratio_To_iPhone6 - Incense_Location;
    
    CGFloat newCenterY = self.center.y + offsetY;
    CGFloat distance = newCenterY - beginCenterY;

    if (distance > floorY - 54 * Size_Ratio_To_iPhone6) {
        newCenterY = beginCenterY + floorY - 54 * Size_Ratio_To_iPhone6;
        self.dragEnable = NO;
        [self.delegate lightTheIncense];
    }
    
    self.center = CGPointMake(self.center.x, newCenterY);    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.isDragEnable) {
        return;
    }
    if (self.center.y < 180) {
        [self.delegate cloudRebound];
    }
}

@end

