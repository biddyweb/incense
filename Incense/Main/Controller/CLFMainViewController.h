//
//  ViewController.h
//  Incense
//
//  Created by CaiGavin on 8/10/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class CLFIncenseView;
@interface CLFMainViewController : UIViewController

@property (nonatomic, weak)                     CLFIncenseView  *incenseView;
@property (nonatomic, assign, getter=isBurning) BOOL            burning;
@property (nonatomic, strong)                   AVAudioRecorder *recorder;
@property (nonatomic, weak)                     UIView          *container;

- (void)incenseDidBurnOffFromBackgroundWithResult:(NSString *)resultString;
- (void)renewSmokeStatusWithTimeHaveGone:(CGFloat)leaveBackInterval;

@end

