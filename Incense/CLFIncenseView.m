//
//  CLFIncenseView.m
//  Incense
//
//  Created by CaiGavin on 8/10/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "CLFIncenseView.h"
#import "Masonry.h"
#import "CLFSmokeEmitterView.h"

@interface CLFIncenseView ()

@property (nonatomic, assign, getter=isAnimating) BOOL animating;

@end

@implementation CLFIncenseView

//- (instancetype)init {
//    if (self = [super init]) {
//        CLFSmokeEmitterView *emitterView = [[CLFSmokeEmitterView alloc] initWithFrame:CGRectZero];
//        [self addSubview:emitterView];
//    }
//    return self;
//}

- (UIView *)incenseHeadView {
    if (_incenseHeadView == nil) {
        UIView *incenseHeadView = [[UIView alloc] init];
        incenseHeadView.backgroundColor = [UIColor redColor];
        [self addSubview:incenseHeadView];
        _incenseHeadView = incenseHeadView;
    }
    return _incenseHeadView;
}

- (UIView *)incenseDustView {
    if (_incenseDustView == nil) {
        UIView *incenseDustView = [[UIView alloc] init];
        incenseDustView.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:incenseDustView];
        _incenseDustView = incenseDustView;
    }
    return _incenseDustView;
}

- (void)layoutSubviews {
    [self.incenseHeadView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.height.equalTo(@10);
    }];
    
    [self.incenseDustView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.incenseHeadView.mas_bottom);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.height.equalTo(@5);
    }];
}

- (void)setBrightnessCallback:(void (^)(CLFIncenseView *))brightnessCallback {
    _brightnessCallback = brightnessCallback;
    
    _displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(invokeBrightnessCallback)];
    _displaylink.frameInterval = 8;
    [_displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    self.animating = NO;
}

- (void)invokeBrightnessCallback {
    _brightnessCallback(self);
}

- (void)setBrightnessLevel:(CGFloat)brightnessLevel {
    if (self.isAnimating == NO && brightnessLevel >= 0.02f) {
        self.animating = YES;
        [UIView animateWithDuration:0.5f animations:^{
            self.incenseHeadView.backgroundColor = [UIColor yellowColor];
            self.incenseDustView.backgroundColor = [UIColor blackColor];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5f animations:^{
                self.incenseHeadView.backgroundColor = [UIColor redColor];
                self.incenseDustView.backgroundColor = [UIColor grayColor];
            } completion:^(BOOL finished) {
                self.animating = NO;
            }];
        }];
    }
}

@end
