//
//  CLFTools.m
//  Incense
//
//  Created by CaiGavin on 8/20/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "CLFTools.h"
#import <UIKit/UIKit.h>

@implementation CLFTools

+ (NSMutableString *)numberToChinese:(NSInteger)integer {
    if (integer > 99999) {
        integer = 99999;
    }
    
    NSMutableString *digitStr = [NSMutableString string];
    NSMutableString *resultStr = [NSMutableString string];
    
    NSArray *digitArray = @[@"萬", @"仟", @"佰", @"拾"];
    NSArray *numArray = @[@"零", @"壹", @"貳", @"叄", @"肆", @"伍", @"陸", @"柒", @"捌", @"玖"];
    
    NSInteger temp;
    while (integer) {
        temp = integer % 10;
        digitStr = [NSMutableString stringWithFormat:@"%ld%@", (long)temp, digitStr];
        integer /= 10;
    }
    
    for (NSInteger i = 0; i < digitStr.length; i++) {
        unichar digit = [digitStr characterAtIndex:i];
        if (digit == '0') {
            resultStr = [NSMutableString stringWithFormat:@"%@零", resultStr];
        } else {
            NSInteger digitInt = digit - 48;
            if (i != digitStr.length - 1) {
                resultStr = [NSMutableString stringWithFormat:@"%@%@%@", resultStr, numArray[digitInt], digitArray[4 - digitStr.length + 1 + i]];
            } else {
                resultStr = [NSMutableString stringWithFormat:@"%@%@", resultStr, numArray[digitInt]];
            }
        }
    }
    
    while ([resultStr containsString:@"零零"]) {
        NSRange range = NSMakeRange(0, resultStr.length);
        [resultStr replaceOccurrencesOfString:@"零零" withString:@"零" options:0 range:range];
    }
    
    NSMutableString *finialString = nil;
    if ([resultStr hasSuffix:@"零"]) {
        NSString *tempString = [resultStr substringToIndex:(resultStr.length - 1)];
        finialString = [NSMutableString stringWithString:tempString];
    } else {
        finialString = [NSMutableString stringWithString:resultStr];
    }

    return finialString;
}

/**
 *  Make incense floating above the ripple, and the shadow should react to the floating.
 */
+ (void)positionFloatingInView:(UIView *)view withValue1:(CGFloat)value1 value2:(CGFloat)value2 layerPosition:(CGPoint)position anchorPoint:(CGPoint)anchor animationTime:(CGFloat)time {
    
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animation];
    anim.keyPath = @"position.y";
    anim.repeatCount = 1500;
    anim.values = @[@(value1), @(value2), @(value1)];
    anim.duration = time;
    anim.removedOnCompletion = NO;
    anim.fillMode = kCAFillModeForwards;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    view.layer.position = position;
    view.layer.anchorPoint = anchor;
    [view.layer addAnimation:anim forKey:nil];
}

+ (void)boundsFloatingInView:(UIView *)view withRect1:(CGRect)rect1 rect2:(CGRect)rect2 layerPosition:(CGPoint)position anchorPoint:(CGPoint)anchor animationTime:(CGFloat)time {
    
    NSValue *bounds1 = [NSValue valueWithCGRect:rect1];
    NSValue *bounds2 = [NSValue valueWithCGRect:rect2];
    
    CAKeyframeAnimation *shadowAnim = [CAKeyframeAnimation animation];
    shadowAnim.keyPath = @"bounds";
    shadowAnim.repeatCount = 1500;
    shadowAnim.values = @[bounds1, bounds2, bounds1];
    shadowAnim.duration = time;
    shadowAnim.removedOnCompletion = NO;
    shadowAnim.fillMode = kCAFillModeForwards;
    shadowAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    view.layer.position = position;
    view.layer.anchorPoint = anchor;
    [view.layer addAnimation:shadowAnim forKey:nil];
}

+ (void)stopAnimationInView:(UIView *)view withPosition:(CGPoint)position anchor:(CGPoint)anchor {
    [view.layer removeAllAnimations];
    
    view.layer.position = position;
    view.layer.anchorPoint = anchor;
}

+ (NSMutableAttributedString *)arrangeAttributedString:(NSMutableAttributedString *)attributedString {
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"STFangsong" size:20] range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, attributedString.length - 1)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(attributedString.length - 1, 1)];
    
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.paragraphSpacing = -7;
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paraStyle range:NSMakeRange(0, attributedString.length - 3)];
    NSMutableParagraphStyle *paraStyle2 = [[NSMutableParagraphStyle alloc] init];
    paraStyle2.paragraphSpacing = -15;
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paraStyle2 range:NSMakeRange(attributedString.length - 3, 3)];
    return attributedString;
}

+ (CATransform3D)CATransform3DMakePerspective:(CGPoint)center disZ:(CGFloat)disZ {
    CATransform3D transToCenter = CATransform3DMakeTranslation(-center.x, -center.y, 0);
    CATransform3D transBack = CATransform3DMakeTranslation(center.x, center.y, 0);
    CATransform3D scale = CATransform3DIdentity;
    scale.m34 = -1.0f / disZ;
    return CATransform3DConcat(CATransform3DConcat(transToCenter, scale), transBack);
}

+ (CATransform3D)CATransform3DPerspect:(CATransform3D)t center:(CGPoint)center disZ:(CGFloat)disZ {
    return CATransform3DConcat(t, [self CATransform3DMakePerspective:center disZ:disZ]);
}

+ (UIImage *)takeSnapshotOfView:(UIView *)view {
    CGFloat reductionFactor = 0.3;
    UIGraphicsBeginImageContext(CGSizeMake(view.frame.size.width/reductionFactor, view.frame.size.height/reductionFactor));
    [view drawViewHierarchyInRect:CGRectMake(0, 0, view.frame.size.width/reductionFactor, view.frame.size.height/reductionFactor) afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
