//
//  CLFMathTools.m
//  Incense
//
//  Created by CaiGavin on 8/20/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "CLFMathTools.h"

@implementation CLFMathTools

+ (NSArray *)digitInInteger:(NSInteger)integer {
    NSMutableArray *digitArrayM = [NSMutableArray array];
    while (integer) {
        [digitArrayM addObject:@(integer % 10)];
        integer /= 10;
    }
    NSArray *digitArray = [NSArray arrayWithArray:digitArrayM];
    return digitArray;
}

@end
