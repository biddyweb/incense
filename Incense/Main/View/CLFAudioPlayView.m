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
@property (nonatomic, weak)   CLFPlayButton   *tideButton;
@property (nonatomic, weak)   CLFPlayButton   *chirpButton;

@property (nonatomic, weak)   CLFPlayButton   *playingButton;

@property (nonatomic, strong) NSTimer         *audioTimer;
@property (nonatomic, strong) NSTimer         *switchTimer;

@property (nonatomic, strong) NSArray         *statusLocationArray;

@end

@implementation CLFAudioPlayView

static CGFloat selfWidth;
static CGFloat audioButtonWidth = 60.0f;

- (instancetype)init {
    if (self = [super init]) {
        AVAudioSession *aSession = [AVAudioSession sharedInstance];
        NSError *error = nil;
        
        [aSession setCategory:AVAudioSessionCategoryMultiRoute error:&error];
        
        if (error) {
            NSLog(@"Error setting category: %@", [error description]);
        }

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleAudioSessionInterruption:)
                                                     name:AVAudioSessionInterruptionNotification
                                                   object:aSession];
        
        
        self.statusLocationArray = @[@(-51), @(-19)];
        
        CLFPlayButton *rainButton = [[CLFPlayButton alloc] init];
        
        [rainButton setImage:[UIImage imageNamed:@"RainButton"] forState:UIControlStateNormal];
        rainButton.name = @"2";
        rainButton.status = 0;
        [rainButton addTarget:self action:@selector(playAudioWithNamedButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:rainButton];
        _rainButton = rainButton;
        
        CLFPlayButton *tideButton = [[CLFPlayButton alloc] init];
        [tideButton setImage:[UIImage imageNamed:@"TideButton"] forState:UIControlStateNormal];
        tideButton.name = @"3";
        tideButton.status = 0;
        [tideButton addTarget:self action:@selector(playAudioWithNamedButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:tideButton];
        _tideButton = tideButton;
        
        CLFPlayButton *chirpButton = [[CLFPlayButton alloc] init];
        [chirpButton setImage:[UIImage imageNamed:@"ChirpButton"] forState:UIControlStateNormal];
        chirpButton.name = @"4";
        chirpButton.status = 0;

        [chirpButton addTarget:self action:@selector(playAudioWithNamedButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:chirpButton];
        _chirpButton = chirpButton;
        
        self.show = NO;
        
        self.layer.masksToBounds = YES;
        
//        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
    return self;
}

- (void)handleAudioSessionInterruption:(NSNotification*)notification {
    
    NSNumber *interruptionType = [[notification userInfo] objectForKey:AVAudioSessionInterruptionTypeKey];
    NSNumber *interruptionOption = [[notification userInfo] objectForKey:AVAudioSessionInterruptionOptionKey];
    
    switch (interruptionType.unsignedIntegerValue) {
        case AVAudioSessionInterruptionTypeBegan:{
            break;
        }
        case AVAudioSessionInterruptionTypeEnded:{
            if (interruptionOption.unsignedIntegerValue == AVAudioSessionInterruptionOptionShouldResume) {
                [self.audioPlayer play];
            }
            break;
        }
        default:
            break;
    }
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
    
    self.tideButton.frame = CGRectMake(selfWidth * 0.5 - audioButtonWidth * 0.5, -77, audioButtonWidth, 132);
    self.rainButton.frame = CGRectMake((selfWidth * 1.0f / 3) - audioButtonWidth * 0.5, -77, audioButtonWidth, 132);
    self.chirpButton.frame = CGRectMake((selfWidth * 2.0f / 3) - audioButtonWidth * 0.5, -77, audioButtonWidth, 132);
}



- (void)showAudioButtons {
    CGFloat tideLocation = 0.0f;
    CGFloat rainLocation = 0.0f;
    CGFloat chirpLocation = 0.0f;
    
    if (self.show) {
        tideLocation = -77;
        rainLocation = tideLocation;
        chirpLocation = rainLocation;
        self.show = NO;
    } else {
        tideLocation = [self.statusLocationArray[self.tideButton.status] floatValue];
        rainLocation = [self.statusLocationArray[self.rainButton.status] floatValue];
        chirpLocation = [self.statusLocationArray[self.chirpButton.status] floatValue];
        self.show = YES;
    }
    
    [UIView animateWithDuration:0.3f animations:^{
        self.tideButton.frame = CGRectMake(selfWidth * 0.5 - audioButtonWidth * 0.5, tideLocation, audioButtonWidth, 132);
        self.rainButton.frame = CGRectMake((selfWidth * 1.0f / 3) - audioButtonWidth * 0.5, rainLocation, audioButtonWidth, 132);
        self.chirpButton.frame = CGRectMake((selfWidth * 2.0f / 3) - audioButtonWidth * 0.5, chirpLocation, audioButtonWidth, 132);
    }];

    if (self.show) {
        if (!self.switchTimer) {
            self.switchTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(showAudioButtons) userInfo:nil repeats:NO];
        }
    } else {
        if (self.switchTimer) {
            [self.switchTimer invalidate];
            self.switchTimer = nil;
        }
    }
}

- (void)playAudioWithNamedButton:(CLFPlayButton *)namedButton {
    if (self.switchTimer) {
        [self.switchTimer invalidate];
        self.switchTimer = nil;
    }

    if (self.show) {
        if (!self.switchTimer) {
            self.switchTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(showAudioButtons) userInfo:nil repeats:NO];
        }
        
        if (![self.playingButton isEqual:namedButton]) {
            
            self.playingButton.status = 0;
            CGFloat playingButtonX = self.playingButton.frame.origin.x;
            CGFloat playingButtonY = -51;
            [UIView animateWithDuration:0.3f animations:^{
                self.playingButton.frame = CGRectMake(playingButtonX, playingButtonY, audioButtonWidth, 132);
                self.playingButton = namedButton;
            } completion:nil];
        }
        
        namedButton.status = !namedButton.status;   // 间隔很短的话...此时 nameButton 还没有切换,所以...
        CGFloat namedButtonY = [self.statusLocationArray[namedButton.status] floatValue];
        CGFloat namedButtonX = namedButton.frame.origin.x;
        [UIView animateWithDuration:0.3f animations:^{
            namedButton.frame = CGRectMake(namedButtonX, namedButtonY, audioButtonWidth, 132);
        } completion:nil];
        
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

@end
