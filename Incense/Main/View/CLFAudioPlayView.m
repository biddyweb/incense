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

@property (nonatomic, strong) AVAudioPlayer   *audioPlayer;

@property (nonatomic, strong) CAGradientLayer *maskLayer;

@property (nonatomic, weak)   CLFPlayButton   *rainButton;
@property (nonatomic, weak)   CLFPlayButton   *dewButton;
@property (nonatomic, weak)   CLFPlayButton   *chirpButton;

@property (nonatomic, weak)   CLFPlayButton   *playingButton;

@property (nonatomic, strong) NSTimer         *audioTimer;
@property (nonatomic, strong) NSTimer         *switchTimer;

@property (nonatomic, strong) NSArray         *statusLocationArray;

@end

@implementation CLFAudioPlayView

static CGFloat selfWidth;

- (instancetype)init {
    if (self = [super init]) {
        self.statusLocationArray = @[@(-51), @(-23)];
        
        CLFPlayButton *rainButton = [[CLFPlayButton alloc] init];
        [rainButton setImage:[UIImage imageNamed:@"RainButton"] forState:UIControlStateNormal];
        rainButton.name = @"2";
        rainButton.status = 0;
        [rainButton addTarget:self action:@selector(playAudioWithNamedButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:rainButton];
        _rainButton = rainButton;
        
        CLFPlayButton *dewButton = [[CLFPlayButton alloc] init];
        [dewButton setImage:[UIImage imageNamed:@"DewButton"] forState:UIControlStateNormal];
        dewButton.name = @"3";
        dewButton.status = 0;
        [dewButton addTarget:self action:@selector(playAudioWithNamedButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:dewButton];
        _dewButton = dewButton;
        
        CLFPlayButton *chirpButton = [[CLFPlayButton alloc] init];
        [chirpButton setImage:[UIImage imageNamed:@"ChirpButton"] forState:UIControlStateNormal];
        chirpButton.name = @"4";
        chirpButton.status = 0;

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
        maskLayer.locations = @[@0.0f, @0.3f, @0.6f, @1.0f];
        
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
    
    self.dewButton.frame = CGRectMake(selfWidth * 0.5 - 18, -77, 36, 132);
    self.rainButton.frame = CGRectMake((selfWidth * 1.0f / 3) - 18, -77, 36, 132);
    self.chirpButton.frame = CGRectMake((selfWidth * 2.0f / 3) - 18, -77, 36, 132);
}

- (void)showAudioButtons {
    CGFloat dewLocation = 0.0f;
    CGFloat rainLocation = 0.0f;
    CGFloat chirpLocation = 0.0f;
    if (self.show) {
        dewLocation = -77;
        rainLocation = dewLocation;
        chirpLocation = rainLocation;
        self.show = NO;
    } else {
        dewLocation = [self.statusLocationArray[self.dewButton.status] floatValue];
        rainLocation = [self.statusLocationArray[self.rainButton.status] floatValue];
        chirpLocation = [self.statusLocationArray[self.chirpButton.status] floatValue];
        self.show = YES;
    }
    
    [UIView animateWithDuration:0.5f animations:^{
        self.dewButton.frame = CGRectMake(selfWidth * 0.5 - 18, dewLocation, 36, 132);
        self.rainButton.frame = CGRectMake((selfWidth * 1.0f / 3) - 18, rainLocation, 36, 132);
        self.chirpButton.frame = CGRectMake((selfWidth * 2.0f / 3) - 18, chirpLocation, 36, 132);
    }];

    if (self.show) {
        self.switchTimer = [NSTimer scheduledTimerWithTimeInterval:6.0f target:self selector:@selector(showAudioButtons) userInfo:nil repeats:NO];
    } else {
        [self.switchTimer invalidate];
    }
}

- (void)playAudioWithNamedButton:(CLFPlayButton *)namedButton {
    [self.switchTimer invalidate];
    self.switchTimer = nil;
    self.switchTimer = [NSTimer scheduledTimerWithTimeInterval:6.0f target:self selector:@selector(showAudioButtons) userInfo:nil repeats:NO];
    
    if (self.show) {
        namedButton.status = !namedButton.status;
        CGFloat namedButtonY = [self.statusLocationArray[namedButton.status] floatValue];
        CGFloat namedButtonX = namedButton.frame.origin.x;
        [UIView animateWithDuration:0.5f animations:^{
            namedButton.frame = CGRectMake(namedButtonX, namedButtonY, 36, 132);
        } completion:^(BOOL finished) {
            
        }];
        
        if (![self.playingButton isEqual:namedButton]) {
            self.playingButton.status = 0;
            CGFloat playingButtonX = self.playingButton.frame.origin.x;
            CGFloat playingButtonY = -51;
            [UIView animateWithDuration:0.5f animations:^{
                self.playingButton.frame = CGRectMake(playingButtonX, playingButtonY, 36, 132);
            } completion:^(BOOL finished) {
                self.playingButton = namedButton;
            }];
        }
        
        if (namedButton.status) {
            NSString *musicPath = [[NSBundle mainBundle] pathForResource:namedButton.name ofType:@"mp3"];
            NSURL *musicURL = [[NSURL alloc] initFileURLWithPath:musicPath];
            if (musicPath) {
                self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL error:nil];
                [self.audioPlayer prepareToPlay];
                self.audioPlayer.numberOfLoops = -1;
                self.audioPlayer.volume = 0.5f;
                [self.audioPlayer play];
            }
        } else {
            [self.audioPlayer pause];
        }
        
    } else {
        [self showAudioButtons];
    }
}

- (void)stopPlayAudio {
    NSTimer *audioTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(reduceVolume) userInfo:nil repeats:YES];
    self.audioTimer = audioTimer;
}

- (void)reduceVolume {
    if (self.audioPlayer.volume > 0.0f) {
        self.audioPlayer.volume -= 0.05f;
    } else {
        self.playingButton.status = !self.playingButton.status;
        self.playingButton = nil;
        [self.audioTimer invalidate];
        [self.audioPlayer stop];
    }
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player {
    [self.audioPlayer play];
}

@end
