//
//  CLFTools.h
//  Incense
//
//  Created by CaiGavin on 8/20/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CLFTools : NSObject

+ (NSMutableString *)numberToChinese:(NSInteger)integer;

+ (void)boundsFloatingInView:(UIView *)view withRect1:(CGRect)rect1 rect2:(CGRect)rect2 layerPosition:(CGPoint)position anchorPoint:(CGPoint)anchor animationTime:(CGFloat)time;

+ (void)positionFloatingInView:(UIView *)view withValue1:(CGFloat)value1 value2:(CGFloat)value2 layerPosition:(CGPoint)position anchorPoint:(CGPoint)anchor animationTime:(CGFloat)time;

+ (void)stopAnimationInView:(UIView *)view withPosition:(CGPoint)position anchor:(CGPoint)anchor;

+ (NSMutableAttributedString *)arrangeAttributedString:(NSMutableAttributedString *)attributedString;

@end
