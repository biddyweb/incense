//
//  CLFCardView.h
//  Incense
//
//  Created by CaiGavin on 9/20/15.
//  Copyright © 2015 CaiGavin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CloudKit/CloudKit.h>

@class CLFPoemView;
@interface CLFCardView : UIView

@property (nonatomic, weak) UIImageView *shotView;
@property (nonatomic, weak) CLFPoemView *poemView;
@property (nonatomic, weak) UIView      *incenseSnapshot;
@property (nonatomic, assign) CGFloat   containerRatio;

// should be an array
@property (nonatomic, copy) NSString    *poemString1;
@property (nonatomic, copy) NSString    *poemString2;
@property (nonatomic, copy) NSString    *authorString;

- (void)makeRipple;
- (void)getPoem;

@end
