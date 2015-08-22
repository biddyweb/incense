//
//  CLFAudioPlayView.h
//  Incense
//
//  Created by CaiGavin on 8/22/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CLFAudioPlayView : UIView

@property (nonatomic, assign, getter=isShown) BOOL show;

- (void)showAudioButtons;
- (void)stopPlayAudio;

@end
