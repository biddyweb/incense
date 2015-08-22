//
//  CLFPageControl.m
//  Incense
//
//  Created by CaiGavin on 8/22/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "CLFPageControl.h"

@implementation CLFPageControl

- (void)updatePageDots {
    for (int i = 0; i < self.subviews.count; i++) {
        UIView *dotView = self.subviews[i];
        UIImageView *dot = nil;
        for (UIView* subview in dotView.subviews) {
            if ([subview isKindOfClass:[UIImageView class]]) {
                dot = (UIImageView *)subview;
                break;
            }
        }
        
        if (dot == nil) {
            dot = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, dotView.frame.size.width, dotView.frame.size.height)];
            [dotView addSubview:dot];
        }
        
        if (i == self.currentPage) {
            dot.image = [UIImage imageNamed:@"spark"];
        } else {
            dot.image = [UIImage imageNamed:@"PlayButton6"];
        }
    }
}

- (void)setCurrentPage:(NSInteger)currentPage {
    [super setCurrentPage:currentPage];
    [self updatePageDots];
}

@end
