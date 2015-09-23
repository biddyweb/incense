//
//  CLFCardView.m
//  Incense
//
//  Created by CaiGavin on 9/20/15.
//  Copyright © 2015 CaiGavin. All rights reserved.
//

#import "CLFCardView.h"
#import "BMWaveMaker.h"
#import "CLFIncenseCommonHeader.h"
#import "CLFTools.h"
#import "CLFPoemView.h"
#import "Poem.h"
#import "AppDelegate.h"

@interface CLFCardView ()

@property (nonatomic, weak) UIView *rippleView;
@property (nonatomic, strong) BMWaveMaker *rippleMaker;
@property (nonatomic, weak) UIImageView *shadowView;
@property (nonatomic, weak) UILabel *numberLabel;

@end

@implementation CLFCardView

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor colorWithRed:245 / 255.0 green:245 / 255.0 blue:245 / 255.0 alpha:1.0];
    }
    return self;
}

- (void)setIncenseSnapshot:(UIImageView *)incenseSnapshot {
    _incenseSnapshot = incenseSnapshot;
    
    CGFloat cardViewH = CGRectGetHeight(self.frame);
    
    CGFloat incenseSnapshotW = 260;
    CGFloat incenseSnapshotH = incenseSnapshotW * self.containerRatio;
    CGFloat incenseSnapshotX = -0.5 * (incenseSnapshotW - (Incense_Screen_Width - 40 - 36) * 0.5);
    CGFloat incenseSnapshotY = CGRectGetHeight(self.frame) - 65 - incenseSnapshotH;
    incenseSnapshot.frame = CGRectMake(incenseSnapshotX, incenseSnapshotY, incenseSnapshotW, incenseSnapshotH);
    [self.shotView addSubview:incenseSnapshot];
    
    [CLFTools positionFloatingInView:incenseSnapshot
                          withValue1:(cardViewH - 63)
                              value2:(cardViewH - 66)
                       layerPosition:CGPointMake(incenseSnapshotX, cardViewH - 63)
                         anchorPoint:CGPointMake(0, 1)
                       animationTime:4.0f];
    
    self.shadowView.frame = CGRectMake((incenseSnapshotX + 0.5 * incenseSnapshotW - 3), cardViewH - 62, 6, 3);
    [CLFTools boundsFloatingInView:self.shadowView
                         withRect1:CGRectMake(0, 0, 6, 3)
                             rect2:CGRectMake(0, 0, 3, 1.5)
                     layerPosition:CGPointMake(incenseSnapshotX + 0.5 * incenseSnapshotW, cardViewH - 60)
                       anchorPoint:CGPointMake(0.5, 0.5)
                     animationTime:4.0f];
}

- (void)setBurntNumber:(NSInteger)burntNumber {
    _burntNumber = burntNumber;
    self.numberLabel.text = [CLFTools numberToChinese:burntNumber];
    self.numberLabel.frame = CGRectMake(8, 20, 15, self.numberLabel.text.length * 14);
}

- (void)getPoem {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *managedContext = appDelegate.managedObjectContext;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Poem" inManagedObjectContext:managedContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    NSError *error;
    NSArray *arr = [managedContext executeFetchRequest:request error:&error];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger numberOfPoems = [defaults integerForKey:@"numberOfPoems"];
    
    Poem *poem = nil;
    
    if (!numberOfPoems) {
        numberOfPoems = arr.count;
    }
    
    if (numberOfPoems == arr.count) {
        int value = arc4random() % numberOfPoems;
        poem = arr[value];
    } else if (numberOfPoems < arr.count) {
        int value = arc4random() % arr.count + numberOfPoems;
        poem = arr[value];
        numberOfPoems = arr.count;
        [defaults setInteger:numberOfPoems forKey:@"numberOfPoems"];
    }
    
    self.poemView.firstLine.text = poem.firstline;
    self.poemView.secondLine.text = poem.secondline;
    self.poemView.authorLabel.text = poem.author;
}

- (UIImageView *)shadowView {
    if (!_shadowView) {
        UIImageView *incenseShadowView = [[UIImageView alloc] init];
        incenseShadowView.image = [UIImage imageNamed:@"影"];
        [self.shotView addSubview:incenseShadowView];
        _shadowView = incenseShadowView;
    }
    return _shadowView;
}

- (UIView *)shotView {
    if (!_shotView) {
        UIView *shotView = [[UIView alloc] init];
        [self addSubview:shotView];
        _shotView = shotView;
    }
    return _shotView;
}

- (CLFPoemView *)poemView {
    if (!_poemView) {
        CLFPoemView *poemView = [[CLFPoemView alloc] init];
        poemView.backgroundColor = [UIColor whiteColor];
        [self addSubview:poemView];
        _poemView = poemView;
    }
    return _poemView;
}

- (UILabel *)numberLabel {
    if (!_numberLabel) {
        UILabel *numberLabel = [[UILabel alloc] init];
        [self addSubview:numberLabel];
        numberLabel.font = [UIFont fontWithName:@"STFangsong" size:14];
        numberLabel.numberOfLines = 0;
        numberLabel.textColor = [UIColor blackColor];
        _numberLabel = numberLabel;
    }
    return _numberLabel;
}

- (void)layoutSubviews {
    self.shotView.frame = CGRectMake(8, 20, (CGRectGetWidth(self.frame) - 36) * 0.5, CGRectGetHeight(self.frame) - 40);
    self.poemView.frame = CGRectMake(CGRectGetMaxX(self.shotView.frame) + 8, 20, CGRectGetWidth(self.shotView.frame), CGRectGetHeight(self.shotView.frame));
}

- (UIView *)rippleView {
    if (!_rippleView) {
        UIView *rippleView = [[UIView alloc] init];
        rippleView.frame = CGRectMake(0, CGRectGetHeight(self.frame) - 110, CGRectGetWidth(self.shotView.frame), 100);
//        rippleView.backgroundColor = [UIColor blueColor];
        rippleView.backgroundColor = [UIColor clearColor];
        [self.shotView addSubview:rippleView];
        _rippleView = rippleView;
    }
    return _rippleView;
}

- (void)makeRipple {
    self.rippleView.alpha = 1.0f;
    
    self.rippleMaker.animationView = self.rippleView;
    
    [self.rippleMaker spanWaveContinuallyWithTimeInterval:4];
    
    CATransform3D rotate = CATransform3DMakeRotation(M_PI / 3, 1, 0, 0);
    self.rippleView.layer.transform = [CLFTools CATransform3DPerspect:rotate center:CGPointMake(0, 0) disZ:200];
}

- (BMWaveMaker *)rippleMaker {
    if (!_rippleMaker) {
        _rippleMaker = [[BMWaveMaker alloc] init];
        _rippleMaker.spanScale = 60.0f;
        _rippleMaker.originRadius = 0.9f;
        _rippleMaker.waveColor = [UIColor whiteColor];
        _rippleMaker.animationDuration = 30.0f;
        _rippleMaker.wavePathWidth = 1.5f;
    }
    return _rippleMaker;
}

@end
