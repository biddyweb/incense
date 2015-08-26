//
//  CLFEndButton.m
//  Incense
//
//  Created by CaiGavin on 8/26/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "CLFEndButton.h"
#import "Masonry.h"
#import "CLFIncenseCommonHeader.h"

@implementation CLFEndButton

- (instancetype)init {
    if (self = [super init]) {
        UIImageView *endImageView = [[UIImageView alloc] init];
        [self addSubview:endImageView];
        _endImageView = endImageView;
    }
    return self;
}

- (void)layoutSubviews {
    [self.endImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(22 * Size_Ratio_To_iPhone6));
        make.height.equalTo(@(110 * Size_Ratio_To_iPhone6));
        make.centerX.equalTo(self);
        make.centerY.equalTo(self).multipliedBy(2.0f / 3);
    }];
}

@end
