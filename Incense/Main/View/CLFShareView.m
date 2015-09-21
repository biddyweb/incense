//
//  CLFShareView.m
//  Incense
//
//  Created by CaiGavin on 9/20/15.
//  Copyright © 2015 CaiGavin. All rights reserved.
//

#import "CLFShareView.h"
#import "CLFCardView.h"
#import "CLFIncenseCommonHeader.h"

@interface CLFShareView ()

@end

@implementation CLFShareView

- (instancetype)init {
    if (self = [super init]) {
        CLFCardView *cardView = [[CLFCardView alloc] init];
        [self addSubview:cardView];
        _cardView = cardView;
        
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)layoutSubviews {
    self.cardView.frame = CGRectMake(8, 20, Incense_Screen_Width - 16, 250);
}

@end
