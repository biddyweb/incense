//
//  CLFEndView.h
//  Incense
//
//  Created by CaiGavin on 8/21/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CLFEndViewDelegate <NSObject>

- (void)oneMoreIncense;

@end

@interface CLFEndView : UIView

@property (nonatomic, weak) id<CLFEndViewDelegate> delegate;

- (void)setupWithFailure;
- (void)setupWithBurntOffNumber:(NSString *)numberString;

@end
