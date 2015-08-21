//
//  CLFMusicPlayView.m
//  Incense
//
//  Created by CaiGavin on 8/20/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "CLFMusicPlayView.h"
#import "CLFPlayButton.h"
#import "Masonry.h"
#import <AVFoundation/AVFoundation.h>

@interface CLFMusicPlayView () <AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer *musicPlayer;

@property (nonatomic, weak) CLFPlayButton *rainButton;
@property (nonatomic, weak) CLFPlayButton *dewButton;
@property (nonatomic, weak) CLFPlayButton *chirpButton;

@property (nonatomic, weak) CLFPlayButton *playingButton;

@property (nonatomic, strong) NSTimer     *musicTimer;

@end

@implementation CLFMusicPlayView

static CGFloat selfWidth;

- (instancetype)init {
    if (self = [super init]) {
        CLFPlayButton *rainButton = [[CLFPlayButton alloc] init];
        [rainButton setBackgroundImage:[UIImage imageNamed:@"PlayButton2"] forState:UIControlStateNormal];
        [rainButton setBackgroundImage:[UIImage imageNamed:@"PlayButton6"] forState:UIControlStateSelected];
        rainButton.name = @"2";
        [rainButton addTarget:self action:@selector(playMusicWithNamedButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:rainButton];
        _rainButton = rainButton;
        
        CLFPlayButton *dewButton = [[CLFPlayButton alloc] init];
        [dewButton setBackgroundImage:[UIImage imageNamed:@"PlayButton3"] forState:UIControlStateNormal];
        [dewButton setBackgroundImage:[UIImage imageNamed:@"PlayButton6"] forState:UIControlStateSelected];
        dewButton.name = @"3";
        [dewButton addTarget:self action:@selector(playMusicWithNamedButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:dewButton];
        _dewButton = dewButton;
        
        CLFPlayButton *chirpButton = [[CLFPlayButton alloc] init];
        [chirpButton setBackgroundImage:[UIImage imageNamed:@"PlayButton4"] forState:UIControlStateNormal];
        [chirpButton setBackgroundImage:[UIImage imageNamed:@"PlayButton6"] forState:UIControlStateSelected];
        chirpButton.name = @"4";
        [chirpButton addTarget:self action:@selector(playMusicWithNamedButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:chirpButton];
        _chirpButton = chirpButton;
        
        self.show = NO;

    }
    return self;
}

//- (CLFPlayButton *)createPlayButtonWithName:(NSString *)buttonName {
//    CLFPlayButton *button = [[CLFPlayButton alloc] init];
//    [button setBackgroundImage:[UIImage imageNamed:buttonName] forState:UIControlStateNormal];
//    [button setBackgroundImage:[UIImage imageNamed:@"6"] forState:UIControlStateSelected];
//    button.name = buttonName;
//    [button addTarget:self action:@selector(playMusicWithNamedButton:) forControlEvents:UIControlEventTouchUpInside];
//    return button;
//}

- (void)layoutSubviews {
    selfWidth = CGRectGetWidth(self.frame);
    
    self.dewButton.frame = CGRectMake(selfWidth * 0.5 - 11, 70, 22, 22);
    
    self.rainButton.frame = CGRectMake((selfWidth * 1.0f / 3) - 11, 70, 22, 22);
    
    self.chirpButton.frame = CGRectMake((selfWidth * 2.0f / 3) - 11, 70, 22, 22);
}

- (void)showMusicButtons {
    CGFloat location = self.isShown ? 70 : 10;
    [UIView animateWithDuration:0.5f delay:0.1f usingSpringWithDamping:0.6 initialSpringVelocity:10.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.dewButton.frame = CGRectMake(selfWidth * 0.5 - 11, location, 22, 22);
    } completion:nil];
    
    [UIView animateWithDuration:0.5f delay:0.0f usingSpringWithDamping:0.6 initialSpringVelocity:10.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.rainButton.frame = CGRectMake((selfWidth * 1.0f / 3) - 11, location, 22, 22);
    } completion:nil];
    
    [UIView animateWithDuration:0.5f delay:0.2f usingSpringWithDamping:0.6 initialSpringVelocity:10.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.chirpButton.frame = CGRectMake((selfWidth * 2.0f / 3) - 11, location, 22, 22);
    } completion:nil];
    self.show = !self.show;
}

- (void)showMusicList {
}

- (void)playMusicWithNamedButton:(CLFPlayButton *)namedButton {
    if ([self.playingButton isEqual:namedButton]) {
        namedButton.selected = NO;
        self.playingButton = nil;
        [self.musicPlayer pause];
        return;
    }
    
    
    NSString *musicPath = [[NSBundle mainBundle] pathForResource:namedButton.name ofType:@"mp3"];
    NSURL *musicURL = [[NSURL alloc] initFileURLWithPath:musicPath];
    if (musicPath) {
        self.musicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL error:nil];
        [self.musicPlayer prepareToPlay];
        self.musicPlayer.numberOfLoops = -1;
        self.musicPlayer.volume = 0.5f;
        NSLog(@"播放");
        [self.musicPlayer play];
        
        namedButton.selected = YES;
        self.playingButton.selected = NO;
        self.playingButton = namedButton;
    }
}

- (void)stopPlayMusic {
    NSTimer *musicTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(reduceVolume) userInfo:nil repeats:YES];
    self.musicTimer = musicTimer;
}

- (void)reduceVolume {
    if (self.musicPlayer.volume > 0.0f) {
        self.musicPlayer.volume -= 0.05f;
    } else {
        self.playingButton.selected = NO;
        self.playingButton = nil;
        [self.musicTimer invalidate];
        [self.musicPlayer stop];
    }
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player {
    [self.musicPlayer play];
}

@end
