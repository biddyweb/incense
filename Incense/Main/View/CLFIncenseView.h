//
//  CLFIncenseView.h
//  Incense
//
//  Created by CaiGavin on 8/10/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CLFIncenseViewDelegate <NSObject>

- (void)incenseDidBurnOff;

@end

@class Waver;

@interface CLFIncenseView : UIView

@property (nonatomic, weak) UIView *headDustView;
@property (nonatomic, weak) UIView *incenseHeadView;
@property (nonatomic, weak) UIView *incenseDustView;
@property (nonatomic, weak) UIView *incenseBodyView;
@property (nonatomic, weak) Waver *waver;

@property (nonatomic, assign) CGFloat brightnessLevel;
@property (nonatomic, copy) void (^brightnessCallback)(CLFIncenseView * incense);
@property (nonatomic) CADisplayLink *displaylink;;

@property (nonatomic, weak) id<CLFIncenseViewDelegate> delegate;

@end
