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
        dotView.backgroundColor = [UIColor clearColor];
        UIImageView *dot = nil;
        for (UIView* subview in dotView.subviews) {
            if ([subview isKindOfClass:[UIImageView class]]) {
                dot = (UIImageView *)subview;
                break;
            }
        }
        
        if (dot == nil) {
            CGFloat dotX = dotView.frame.size.width * 0.25;
            CGFloat dotY = dotView.frame.size.height * 0.25;
            CGFloat dotW = dotView.frame.size.width * 0.5;
            CGFloat dotH = dotView.frame.size.width * 0.5;
            dot = [[UIImageView alloc] initWithFrame:CGRectMake(dotX, dotY, dotW, dotH)];
            dot.layer.cornerRadius = 2.5;
            dot.layer.masksToBounds = YES;
            [dotView addSubview:dot];
        }
        
        if (i == self.currentPage) {
            dot.backgroundColor = [UIColor redColor];
        } else {
            dot.backgroundColor = [UIColor colorWithRed:231/255.0 green:231/255.0 blue:231/255.0 alpha:1.0];
        }
    }
}

- (void)setCurrentPage:(NSInteger)currentPage {
    [super setCurrentPage:currentPage];
    [self updatePageDots];
}

@end
