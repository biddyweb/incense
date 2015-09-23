//
//  CLFCardView.h
//  Incense
//
//  Created by CaiGavin on 9/20/15.
//  Copyright © 2015 CaiGavin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class CLFPoemView;
@interface CLFCardView : UIView

@property (nonatomic, weak) UIView *shotView;
@property (nonatomic, weak) CLFPoemView *poemView;
@property (nonatomic, weak) UIImageView      *incenseSnapshot;
@property (nonatomic, assign) CGFloat   containerRatio;

- (void)makeRipple;
- (void)getPoem;

@end
