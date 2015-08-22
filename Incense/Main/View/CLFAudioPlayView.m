//
//  CLFAudioPlayView.m
//  Incense
//
//  Created by CaiGavin on 8/22/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "CLFAudioPlayView.h"
#import "CLFPlayButton.h"
#import "Masonry.h"
#import <AVFoundation/AVFoundation.h>

@interface CLFAudioPlayView () <AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer *AudioPlayer;

@property (nonatomic, strong) CAGradientLayer *maskLayer;

@property (nonatomic, weak)   UIImageView   *topMaskView;
@property (nonatomic, weak)   UIImageView   *bottomMaskView;

@property (nonatomic, weak)   CLFPlayButton *rainButton;
@property (nonatomic, weak)   CLFPlayButton *dewButton;
@property (nonatomic, weak)   CLFPlayButton *chirpButton;

@property (nonatomic, weak)   CLFPlayButton *playingButton;

@property (nonatomic, strong) NSTimer       *AudioTimer;

@end

@implementation CLFAudioPlayView

static CGFloat selfWidth;

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor greenColor];
        
        CLFPlayButton *rainButton = [[CLFPlayButton alloc] init];
        [rainButton setImage:[UIImage imageNamed:@"RainButton"] forState:UIControlStateNormal];
        rainButton.name = @"2";
        [rainButton addTarget:self action:@selector(playAudioWithNamedButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:rainButton];
        _rainButton = rainButton;
        
        CLFPlayButton *dewButton = [[CLFPlayButton alloc] init];
        [dewButton setImage:[UIImage imageNamed:@"DewButton"] forState:UIControlStateNormal];
        dewButton.name = @"3";
        [dewButton addTarget:self action:@selector(playAudioWithNamedButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:dewButton];
        _dewButton = dewButton;
        
        CLFPlayButton *chirpButton = [[CLFPlayButton alloc] init];
        [chirpButton setImage:[UIImage imageNamed:@"ChirpButton"] forState:UIControlStateNormal];
        chirpButton.name = @"4";
//        chirpButton.backgroundColor = [UIColor grayColor];
        [chirpButton addTarget:self action:@selector(playAudioWithNamedButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:chirpButton];
        _chirpButton = chirpButton;
        
        self.show = NO;
        
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (CAGradientLayer *)maskLayer {
    if (!_maskLayer) {
        CAGradientLayer *maskLayer = [CAGradientLayer layer];
        maskLayer.startPoint = CGPointMake(0.0f, 0.0f);
        maskLayer.endPoint = CGPointMake(0.0f, 1.0f);
        maskLayer.frame = self.frame;
        
        NSMutableArray *colors = [NSMutableArray array];
        
        [colors addObject:(id)[UIColor colorWithRed:231/255.0 green:231/255.0 blue:231/255.0 alpha:1.0f].CGColor];
        [colors addObject:(id)[UIColor colorWithRed:231/255.0 green:231/255.0 blue:231/255.0 alpha:0.0f].CGColor];
        [colors addObject:(id)[UIColor colorWithRed:231/255.0 green:231/255.0 blue:231/255.0 alpha:0.0f].CGColor];
        [colors addObject:(id)[UIColor colorWithRed:231/255.0f green:231/255.0f blue:231/255.0f alpha:1.0f].CGColor];
        
        maskLayer.colors = colors;
        maskLayer.locations = @[@0.0f, @0.3f, @0.7f, @1.0f];
        
        maskLayer.position = CGPointMake(0, 0);
        maskLayer.anchorPoint = CGPointMake(0, 0);
        [self.layer addSublayer:maskLayer];
        _maskLayer = maskLayer;
    }
    return _maskLayer;
}

- (void)layoutSubviews {
    self.maskLayer.position = CGPointMake(0, 0);
    
    selfWidth = CGRectGetWidth(self.frame);
    
    // -23 停 // -51 鸟雨露 // -77 o
    self.dewButton.frame = CGRectMake(selfWidth * 0.5 - 18, -77, 36, 132);
    
    self.rainButton.frame = CGRectMake((selfWidth * 1.0f / 3) - 18, -77, 36, 132);
    
    self.chirpButton.frame = CGRectMake((selfWidth * 2.0f / 3) - 18, -77, 36, 132);
}

- (void)showAudioButtons {
    [UIView animateWithDuration:0.5f animations:^{
        self.dewButton.frame = CGRectMake(selfWidth * 0.5 - 18, -51, 36, 132);
        
        self.rainButton.frame = CGRectMake((selfWidth * 1.0f / 3) - 18, -51, 36, 132);
        
        self.chirpButton.frame = CGRectMake((selfWidth * 2.0f / 3) - 18, -51, 36, 132);
    }];
}

//  状态1 .......2............3..............1
//  o o o --> 鸟 雨 露 --> 鸟 停 露 --> 几秒后 o o o
- (void)playAudioWithNamedButton:(CLFPlayButton *)namedButton {
    
    
    
    
}

- (void)stopPlayAudio {
    
}

- (void)reduceVolume {
    
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player {
    
}



@end
