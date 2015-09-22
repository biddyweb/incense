//
//  CLFPoemView.m
//  Incense
//
//  Created by CaiGavin on 9/22/15.
//  Copyright © 2015 CaiGavin. All rights reserved.
//

#import "CLFPoemView.h"

@implementation CLFPoemView

- (instancetype)init {
    if (self = [super init]) {

    }
    return self;
}

- (UILabel *)firstLine {
    if (!_firstLine) {
        UILabel *firstLine = [[UILabel alloc] init];
        firstLine.numberOfLines = 0;
        
        // MARK: 4s 情况下， 字太长了囧
        firstLine.font = [UIFont fontWithName:@"STFangsong" size:22];
        firstLine.textColor = [UIColor blackColor];
        [self addSubview:firstLine];
//        firstLine.backgroundColor = [UIColor redColor];
        _firstLine = firstLine;
    }
    return _firstLine;
}

- (UILabel *)secondLine {
    if (!_secondLine) {
        UILabel *secondLine = [[UILabel alloc] init];
        secondLine.numberOfLines = 0;
        secondLine.font = [UIFont fontWithName:@"STFangsong" size:22];
        secondLine.textColor = [UIColor blackColor];
        [self addSubview:secondLine];
//        secondLine.backgroundColor = [UIColor greenColor];
        _secondLine = secondLine;
    }
    return _secondLine;
}

- (UILabel *)authorLabel {
    if (!_authorLabel) {
        UILabel *authorLabel = [[UILabel alloc] init];
        authorLabel.numberOfLines = 0;
        authorLabel.font = [UIFont fontWithName:@"STFangsong" size:14];
        authorLabel.textColor = [UIColor blackColor];
        [self addSubview:authorLabel];
//        authorLabel.backgroundColor = [UIColor blueColor];
        _authorLabel = authorLabel;
    }
    return _authorLabel;
}

- (void)layoutSubviews {
    NSLog(@"poemView layoutSubviews");
    self.firstLine.frame = CGRectMake(CGRectGetWidth(self.frame) - 42, 20, 22, self.firstLine.text.length * 22);
    self.secondLine.frame = CGRectMake(CGRectGetWidth(self.frame) - 72, 20, 22, self.secondLine.text.length * 22);
    self.authorLabel.frame = CGRectMake(8, CGRectGetHeight(self.frame) - 65, 15, 60);
}


@end
