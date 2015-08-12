//
//  CLFIncenseView.h
//  Incense
//
//  Created by CaiGavin on 8/10/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CLFIncenseView : UIView

@property (nonatomic, weak) UIView *incenseHeadView;
@property (nonatomic, weak) UIView *incenseDustView;

@property (nonatomic, assign) CGFloat brightnessLevel;
@property (nonatomic, copy) void (^brightnessCallback)(CLFIncenseView * incense);
@property (nonatomic) CADisplayLink *displaylink;;

@end
