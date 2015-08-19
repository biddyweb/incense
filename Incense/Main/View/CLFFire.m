//
//  CLFFire.m
//  Incense
//
//  Created by CaiGavin on 8/11/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "CLFFire.h"
#import "UIImage+animatedGIF.h"
#import "Masonry.h"

@interface CLFFire ()

@property (nonatomic, weak) UIImageView *fireImage;

@end

@implementation CLFFire

static CGPoint beginPoint;
static CGFloat screenHeight;
static CGFloat sizeRatio;
static const CGFloat kIncenseLocation = 200.0f;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"Fire" withExtension:@"gif"];
        self.fireImage.image = [UIImage animatedImageWithAnimatedGIFURL:url];
        screenHeight = [UIScreen mainScreen].bounds.size.height;
        sizeRatio = screenHeight / 667.0f;
    }
    return self;
}

- (UIImageView *)fireImage {
    if (!_fireImage) {
        UIImageView *fireImage = [[UIImageView alloc] init];
        [self addSubview:fireImage];
        [fireImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@24);
            make.width.equalTo(@18);
            make.center.equalTo(self);
        }];
        _fireImage = fireImage;
    }
    return _fireImage;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.isDragEnable) {
        return;
    }
    UITouch *touch = [touches anyObject];
    beginPoint = [touch locationInView:self];

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.isDragEnable) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    
    CGPoint currentPoint = [touch locationInView:self];
    
    CGFloat offsetY = currentPoint.y - beginPoint.y;
    
    CGFloat floorY = screenHeight - 200 * sizeRatio - kIncenseLocation - 5;
    
    CGFloat newCenterY;
    if (self.center.y + offsetY > floorY) {
        newCenterY = floorY;
    } else if (self.center.y + offsetY < 40) {
        newCenterY = 40;
    } else {
        newCenterY = self.center.y + offsetY;
    }
    
    CGFloat newCenterX = self.center.x;
    
    self.center = CGPointMake(newCenterX, newCenterY);
    
    if ( (newCenterX > [UIScreen mainScreen].bounds.size.width / 2 - 5 && newCenterX < [UIScreen mainScreen].bounds.size.width / 2 + 5) && newCenterY == floorY) {
        [self.delegate lightTheIncense];
        self.dragEnable = NO;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.isDragEnable) {
        return;
    }

    if (self.center.y > 180) {
        [self.delegate fireFallDown];
    }
}

@end
