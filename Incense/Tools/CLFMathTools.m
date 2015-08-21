//
//  CLFMathTools.m
//  Incense
//
//  Created by CaiGavin on 8/20/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "CLFMathTools.h"

@implementation CLFMathTools

+ (NSString *)numberToChinese:(NSInteger)integer {
    if (integer > 99999) {
        integer = 99999;
    }
    
    NSMutableString *digitStr = [NSMutableString string];
    NSMutableString *resultStr = [NSMutableString string];
    
    NSArray *digitArray = @[@"万", @"千", @"百", @"十"];
    NSArray *numArray = @[@"零", @"一", @"二", @"三", @"四", @"五", @"六", @"七", @"八", @"九"];
    
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
    
    NSString *finialString = nil;
    if ([resultStr hasSuffix:@"零"]) {
        finialString = [resultStr substringToIndex:(resultStr.length - 1)];
    } else {
        finialString = [NSString stringWithString:resultStr];
    }

    return finialString;
    
}

@end
