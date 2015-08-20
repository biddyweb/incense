//
//  CLFCloud.m
//  Incense
//
//  Created by CaiGavin on 8/19/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "CLFCloud.h"

@interface CLFCloud ()

@property (nonatomic, weak) UIView *fireImage;

@end

@implementation CLFCloud

static CGPoint beginPoint;
static CGFloat screenHeight;
static CGFloat sizeRatio;
static CGFloat beginCenterY = -140.0f;
static CGFloat incenseLocation = 200.0f;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        screenHeight = [UIScreen mainScreen].bounds.size.height;
        sizeRatio = screenHeight / 667.0f;
        self.dragEnable = YES;
        incenseLocation = (screenHeight - 200 * sizeRatio) * 0.3;
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

    
    CGFloat floorY = screenHeight - 200 * sizeRatio - incenseLocation;
    
    CGFloat newCenterY = self.center.y + offsetY;
    CGFloat distance = newCenterY - beginCenterY;
//    NSLog(@"distance %f floorY %f offsetY %f", distance, floorY, offsetY);
    
    if (distance > floorY - 57) {
        newCenterY = beginCenterY + floorY - 57;
        self.dragEnable = NO;
        [self.delegate lightTheIncense];
    }
    
    self.center = CGPointMake(self.center.x, newCenterY);
    
//    CGFloat newCenterY;
//    if (self.center.y + offsetY > floorY) {
//        newCenterY = floorY;
//    } else if (self.center.y + offsetY < 40) {
//        newCenterY = 40;
//    } else {
//        newCenterY = self.center.y + offsetY;
//    }
    
//    CGFloat newCenterX = self.center.x;
//    
//    self.center = CGPointMake(newCenterX, newCenterY);
//    
//    if ( (newCenterX > [UIScreen mainScreen].bounds.size.width / 2 - 5 && newCenterX < [UIScreen mainScreen].bounds.size.width / 2 + 5) && newCenterY == floorY) {
//        [self.delegate lightTheIncense];
//        self.dragEnable = NO;
//    }
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

