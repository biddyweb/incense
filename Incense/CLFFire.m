//
//  CLFFire.m
//  Incense
//
//  Created by CaiGavin on 8/11/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "CLFFire.h"
#import "CLFFireEmitterView.h"

@interface CLFFire ()

@end

@implementation CLFFire

static CGPoint beginPoint;
static CGFloat kScreenH;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CLFFireEmitterView *emitterView = [[CLFFireEmitterView alloc] initWithFrame:CGRectZero];
        [self addSubview:emitterView];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.isDragEnable) {
        return;
    }
    UITouch *touch = [touches anyObject];
    beginPoint = [touch locationInView:self];
    kScreenH = [UIScreen mainScreen].bounds.size.height;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.isDragEnable) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    
    CGPoint currentPoint = [touch locationInView:self];
    
    CGFloat offsetX = currentPoint.x - beginPoint.x;
    CGFloat offsetY = currentPoint.y - beginPoint.y;
    
    CGFloat newCenterY;
    if (self.center.y + offsetY > kScreenH - 310) {
        newCenterY = kScreenH - 310;
    } else {
        newCenterY = self.center.y + offsetY;
    }
    
    CGFloat newCenterX = self.center.x + offsetX;
    
    self.center = CGPointMake(newCenterX, newCenterY);
    
    if ( (newCenterX > [UIScreen mainScreen].bounds.size.width / 2 - 10 && newCenterX < [UIScreen mainScreen].bounds.size.width / 2 + 10) && newCenterY == kScreenH - 310) {
        [self.delegate lightTheIncense];
    }
}

@end
