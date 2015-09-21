//
//  CLFCardView.m
//  Incense
//
//  Created by CaiGavin on 9/20/15.
//  Copyright © 2015 CaiGavin. All rights reserved.
//

#import "CLFCardView.h"

@interface CLFCardView ()

@end

@implementation CLFCardView

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor lightGrayColor];
    }
    return self;
}

- (UIImageView *)shotView {
    if (!_shotView) {
        UIImageView *shotView = [[UIImageView alloc] init];
//        shotView.backgroundColor = [UIColor blueColor];
        [self addSubview:shotView];
        _shotView = shotView;
    }
    return _shotView;
}

- (UIView *)poemView {
    if (!_poemView) {
        UIView *poemView = [[UIView alloc] init];
        poemView.backgroundColor = [UIColor whiteColor];
        [self addSubview:poemView];
        _poemView = poemView;
    }
    return _poemView;
}

- (void)layoutSubviews {
    self.shotView.frame = CGRectMake(8, 8, (CGRectGetWidth(self.frame) - 24) * 0.5, CGRectGetHeight(self.frame) - 16);
    self.poemView.frame = CGRectMake(CGRectGetMaxX(self.shotView.frame) + 8, 8, CGRectGetWidth(self.shotView.frame), CGRectGetHeight(self.shotView.frame));
}



@end
