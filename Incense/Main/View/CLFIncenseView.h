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
- (void)incenseDidBurnOffFromBackgroundWithResult:(NSString *)resultString;

@end

@class Waver;

@interface CLFIncenseView : UIView

@property (nonatomic, weak)                      UIImageView                *incenseHeadView;
@property (nonatomic, weak)                      UIImageView                *lightView;
@property (nonatomic, weak)                      Waver                      *waver;
@property (nonatomic, assign, getter=isBurntOff) BOOL    *burntOff;

@property (nonatomic, assign)                    CGFloat                    brightnessLevel;
@property (nonatomic, copy)                      void                       (^brightnessCallback)(CLFIncenseView * incense);
@property (nonatomic, strong)                    CADisplayLink              *displaylink;;

@property (nonatomic, weak)                      id<CLFIncenseViewDelegate> delegate;

- (void)initialSetupWithIncenseHeight:(CGFloat)height;
- (CGFloat)timeHaveGone;
- (void)renewStatusWithTheTimeHaveGone:(CGFloat)timeInterval;

@end
