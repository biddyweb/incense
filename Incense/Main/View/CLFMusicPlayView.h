//
//  CLFMusicPlayView.h
//  Incense
//
//  Created by CaiGavin on 8/20/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CLFMusicPlayView : UIView

@property (nonatomic, assign, getter=isShown) BOOL show;

- (void)showMusicButtons;
- (void)stopPlayMusic;

@end
