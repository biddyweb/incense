//
//  ViewController.h
//  Incense
//
//  Created by CaiGavin on 8/10/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLFIncenseView;
@interface CLFMainViewController : UIViewController

@property (nonatomic, weak) CLFIncenseView *incenseView;
@property (nonatomic, assign, getter=isBurning) BOOL burning;

- (void)incenseDidBurnOffForALongTime;
- (void)renewSmokeStatusWithTimeHaveGone:(CGFloat)leaveBackInterval;

@end

