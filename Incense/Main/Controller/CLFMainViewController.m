//
//  ViewController.m
//  Incense
//
//  Created by CaiGavin on 8/10/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//


#warning 分享的时候: This app is not allowed to query for scheme weixin

#import "CLFMainViewController.h"
#import "CLFCloud.h"
#import "CLFIncenseView.h"
#import "BMWaveMaker.h"
#import "Waver.h"
#import "UIImage+animatedGIF.h"
#import "CLFTools.h"
#import "CLFAudioPlayView.h"
#import "CLFEndView.h"
#import "CLFIncenseCommonHeader.h"
#import "CLFShareViewController.h"
#import "CLFModalTransitionManager.h"

#import "Poem.h"
#import "AppDelegate.h"

@interface CLFMainViewController () <CLFCloudDelegate, CLFIncenseViewDelegate, CLFEndViewDelegate>

@property (nonatomic, weak)                      UIImageView            *incenseShadowView;
@property (nonatomic, weak)                      CLFCloud               *cloud;
@property (nonatomic, weak)                      UIImageView            *smoke;
@property (nonatomic, strong)                    UIImageView            *fire;

@property (nonatomic, weak)                      UIView                 *rippleView;
@property (nonatomic, strong)                    BMWaveMaker            *rippleMaker;

@property (nonatomic, weak)                      CLFEndView             *endView;

@property (nonatomic, weak)                      CLFAudioPlayView       *audioView;
@property (nonatomic, strong)                    NSTimer                *musicTimer;

@property (nonatomic, weak)                      UITapGestureRecognizer *tap;

@property (nonatomic, strong)                    CLFModalTransitionManager *modalTransitionManager;

@property (nonatomic, weak)                      Poem                      *poem;

@end

@implementation CLFMainViewController

static CGFloat cloudLocation = -380.0f;
static CGFloat smokeLocation = -520.0f;
static CGFloat animationTime = 4.0f;
static CGFloat smokeChangeRate = 0.0f;
static BOOL    needSpan = YES;

static const CGFloat kWaverVoiceFactor = 10.0f;
static const CGFloat kFireVoiceFactor = 40.0f;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor colorWithRed:231 / 255.0f green:231 / 255.0f blue:231 / 255.0f alpha:1.0f];
        self.burning = NO;
        if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
            [self prefersStatusBarHidden];
            [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
        }
    }
    return self;
}

- (UIView *)container {
    if (!_container) {
        UIView *container = [[UIView alloc] init];
//        container.backgroundColor = [UIColor greenColor];
        container.tag = 111;
        [self.view addSubview:container];
        _container = container;
    }
    return _container;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadNewPoems];
    
    self.modalTransitionManager = [[CLFModalTransitionManager alloc] init];
    self.container.frame = CGRectMake(0, Incense_Screen_Height - Incense_Location - 200 * Size_Ratio_To_iPhone6, Incense_Screen_Width, 200 * Size_Ratio_To_iPhone6);
    [self makeIncense];
    [self makeCloud];
    [self makeRipple];
    
    [self makeAudioView];
    
    smokeChangeRate = (cloudLocation - smokeLocation) / (1.0f * (Incense_Burn_Off_Time * (60 / 20.0f)));
    self.smoke.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) + 50);
    [self fireAppearInSky];
}

// 修复 restartButton 停止转动的 bug
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.endView) {
        [self.endView restartButtonBeginRotate];
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)loadNewPoems {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *managedContext = appDelegate.managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Poem" inManagedObjectContext:managedContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    NSError *error;
    NSArray *arr = [managedContext executeFetchRequest:request error:&error];
    
    Poem *lastPoem = [arr lastObject];
    NSNumber *finalPoemID = lastPoem.poemid;

    CKContainer *container = [CKContainer defaultContainer];
    CKDatabase *database = [container publicCloudDatabase];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"poemID > %@", finalPoemID];

    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Poems" predicate:predicate];
    [database performQuery:query inZoneWithID:nil completionHandler:^(NSArray<CKRecord *> * _Nullable results, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"error %@", error);
        } else {
            if (results.count) {
                self.poem = [NSEntityDescription insertNewObjectForEntityForName:@"Poem" inManagedObjectContext:managedContext];
                
                for (CKRecord *result in results) {
                    self.poem.firstline = (NSString *)[result valueForKey:@"FirstLine"];
                    self.poem.secondline = (NSString *)[result valueForKey:@"SecondLine"];
                    self.poem.author = (NSString *)[result valueForKey:@"Author"];
                    self.poem.poemid = (NSNumber *)[result valueForKey:@"poemID"];
                }
                [appDelegate saveContext];
            }
        }
    }];

}

#pragma mark - LightTheIncense

/**
 *  light the incense. 
 *  1. Add a tapGestureRecognizer to allow user to choose white noises.
 *  2. Setup and Recorder so that the light of incense can interactive with users by voice.
 *  3. Cloud and fire would disapear gradually
 *  4. Time goes by
 */
- (void)lightTheIncenseWithIncenseHeight:(CGFloat)incenseHeight {
    self.incenseView.incenseHeight = incenseHeight;
    
    self.burning = YES;
    [self setupRecorder];
    __block AVAudioRecorder *weakRecorder = self.recorder;
    self.incenseView.waver.waverLevelCallback = ^(Waver *waver) {
        [weakRecorder updateMeters];
        CGFloat normalizedValue = pow (10, [weakRecorder averagePowerForChannel:0] / kWaverVoiceFactor);
        waver.level = normalizedValue;
    };
    
    [self timeFlow];
    
    self.fire.alpha = 1.0f;
    self.cloud.cloudImageView.alpha = 1.0f;
    [UIView animateWithDuration:4.0f animations:^{
        self.cloud.cloudImageView.alpha = 0.0f;
        self.incenseView.incenseHeadView.alpha = 1.0f;
        self.audioView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        [self.cloud removeFromSuperview]; // --> 此处 fire 被释放了
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showAudioView)];
        [self.view addGestureRecognizer:tapRecognizer];
        self.tap = tapRecognizer;

        self.audioView.userInteractionEnabled = YES;
    }];

    [UIView animateWithDuration:5.0f animations:^{
        self.fire.alpha = 0.0f;  // --> 此处创建了 cloud ????
        self.incenseView.waver.alpha = 1.0f;
        self.fire.transform = CGAffineTransformMakeScale(0.3, 0.3);
    } completion:^(BOOL finished) {
        [self.fire removeFromSuperview];
        self.fire.transform = CGAffineTransformIdentity;
    }];
}

/**
 *  Time goes by, incense would be shorter and smoke of incense ('waver' in this program) and smoke in sky would be longer and thicker.
 */

- (void)timeFlow {
    __block AVAudioRecorder *weakRecorder = self.recorder;
    
    self.incenseView.brightnessCallback = ^(CLFIncenseView *incense) {
        [weakRecorder updateMeters];
        CGFloat normalizedValue = pow (10, [weakRecorder averagePowerForChannel:0] / kFireVoiceFactor);
        incense.brightnessLevel = normalizedValue;
        smokeLocation += smokeChangeRate * Size_Ratio_To_iPhone6;
        self.smoke.frame = CGRectMake(0, smokeLocation, Incense_Screen_Width, 520);
    };
}

/**
 *  incense burnt off in normal way. Increase the burnt off number, stop the audio player/recorder and show a normal endView.
 */
- (void)incenseDidBurnOff {
    [self.view removeGestureRecognizer:self.tap];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger burntIncenseNumber = [defaults integerForKey:@"burntIncenseNumber"];
    
    if (burntIncenseNumber) {
        burntIncenseNumber++;
    } else {
        burntIncenseNumber = 1;
    }
    
    [defaults setInteger:burntIncenseNumber forKey:@"burntIncenseNumber"];
    
    [self.endView setupWithBurntOffNumber:[CLFTools numberToChinese:burntIncenseNumber]];
    [self.endView restartButtonBeginRotate];
    
    self.burning = NO;
    
    [self.audioView stopPlayAudio];
    self.audioView.userInteractionEnabled = NO;
    if (self.audioView.show) {
        [self showAudioView];
    }

    [UIView animateWithDuration:2.0f animations:^{
        self.incenseView.waver.alpha = 0.0f;
        self.incenseView.incenseHeadView.alpha = 0.0f;
        self.audioView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        self.endView.alpha = 0.0f;
        [UIView animateWithDuration:0.5f animations:^{
            self.endView.alpha = 1.0f;
        }];
    }];
    
    [self.recorder stop];
    [self.incenseView.waver.displaylink invalidate];
    [self.incenseView.displaylink invalidate];
}

/**
 *  If the user ignored the alert, show a incompletely burnt incense.
 */

- (void)incenseDidBurnOffFromBackgroundWithResult:(NSString *)resultString {
    [self.view removeGestureRecognizer:self.tap];
    self.burning = NO;
    
    self.audioView.userInteractionEnabled = NO;
    [self.audioView stopPlayAudio];
    
    self.audioView.alpha = 0.0f;
    self.incenseView.waver.alpha = 0.0f;
    self.incenseView.incenseHeadView.alpha = 0.0f;
    self.incenseView.lightView.alpha = 0.0f;
    [self.recorder stop];

    if ([resultString isEqualToString:@"failure"]) {
        [CLFTools stopAnimationInView:self.incenseView
                     withPosition:CGPointMake(0, Incense_Screen_Height - Incense_Location)
                           anchor:CGPointMake(0, 1)];
        
        [CLFTools stopAnimationInView:self.incenseShadowView
                     withPosition:CGPointMake(Incense_Screen_Width * 0.5, Incense_Screen_Height - Incense_Location + 10)
                           anchor:CGPointMake(0.5, 0.5)];
        
        [self showFailure];
        [self.rippleMaker stopWave];
        needSpan = YES;
    } else {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSInteger burntIncenseNumber = [defaults integerForKey:@"burntIncenseNumber"];
        
        if (burntIncenseNumber) {
            burntIncenseNumber++;
        } else {
            burntIncenseNumber = 1;
        }
        
        [defaults setInteger:burntIncenseNumber forKey:@"burntIncenseNumber"];
        
        [self.endView setupWithBurntOffNumber:[CLFTools numberToChinese:burntIncenseNumber]];
        self.endView.alpha = 1.0f;
        [self.endView restartButtonBeginRotate];
    }
    
    [self.incenseView.waver.displaylink invalidate];
    [self.incenseView.displaylink invalidate];
}

#pragma mark - Finished

- (CLFEndView *)endView {
    if (!_endView) {
        CLFEndView *endView = [[CLFEndView alloc] init];
        endView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
        endView.alpha = 0.0f;
        endView.delegate = self;
        [self.view addSubview:endView];
        _endView = endView;
    }
    return _endView;
}

- (void)showFailure {
    [self.endView setupWithFailure];
    self.endView.alpha = 1.0f;
}

/**
 *  Make a new incense for users.
 */
- (void)oneMoreIncense {
    [self.view bringSubviewToFront:self.smoke];
    self.smoke.layer.zPosition = 101;
    
    smokeLocation = -520.0f;
    cloudLocation = -380.0f;
    [UIView animateWithDuration:3.0f animations:^{
        self.smoke.frame = self.smoke.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) + 50);
        self.endView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        
        [self.endView removeFromSuperview];
        self.endView = nil;
        [self.incenseView removeFromSuperview];
        self.incenseView = nil;
        self.incenseShadowView.alpha = 1.0f;
        
        self.audioView.hidden = NO;
        
        [self makeIncense];
        [self makeCloud];
        [self makeRipple];
        
        [self fireAppearInSky];
    }];
}

#pragma mark - Incense

/**
 *  Make incense and the shadow above ripple.
 *
 */
- (CLFIncenseView *)incenseView {
    if (!_incenseView) {
        CLFIncenseView *incenseView = [[CLFIncenseView alloc] init];
        incenseView.delegate = self;
//        [self.view insertSubview:incenseView belowSubview:self.smoke];
        [self.container addSubview:incenseView];
        _incenseView = incenseView;
    }
    return _incenseView;
}

- (UIImageView *)incenseShadowView { 
    if (!_incenseShadowView) {
        UIImageView *incenseShadowView = [[UIImageView alloc] init];
        incenseShadowView.image = [UIImage imageNamed:@"影"];
        [self.view addSubview:incenseShadowView];
        _incenseShadowView = incenseShadowView;
    }
    return _incenseShadowView;
}

- (void)makeIncense {
    CGFloat incenseHeight = 200.0f * Size_Ratio_To_iPhone6;
    [self.incenseView initialSetupWithIncenseHeight:incenseHeight];

    // Incense_Location should be modified. It's related with incenseHeight --> It is fine
    self.incenseView.frame = CGRectMake(0, 0, Incense_Screen_Width, incenseHeight);
    self.incenseView.waver.alpha = 0.0f;
    self.incenseView.incenseHeadView.alpha = 0.0f;
    
    self.incenseShadowView.frame = CGRectMake((Incense_Screen_Width - 6) / 2, Incense_Screen_Height - Incense_Location + 10, 6, 3);
    
    [CLFTools positionFloatingInView:self.incenseView
                          withValue1:(200 * Size_Ratio_To_iPhone6)
                              value2:(200 * Size_Ratio_To_iPhone6 - 5)
                       layerPosition:CGPointMake(0, Incense_Screen_Height - Incense_Location)
                         anchorPoint:CGPointMake(0, 1)
                       animationTime:animationTime];
    
    [CLFTools boundsFloatingInView:self.incenseShadowView
                         withRect1:CGRectMake(0, 0, 6, 3)
                             rect2:CGRectMake(0, 0, 3, 1.5)
                     layerPosition:CGPointMake(Incense_Screen_Width * 0.5, Incense_Screen_Height - Incense_Location + 10)
                       anchorPoint:CGPointMake(0.5, 0.5)
                     animationTime:animationTime];
    
}

#pragma mark - Smoke

/**
 *  Smoke here means the smoke in the sky. It's also used for transition.
 */
- (UIImageView *)smoke {
    if (!_smoke) {
        UIImageView *smoke = [[UIImageView alloc] init];
        smoke.image = [UIImage imageNamed:@"云雾"];
        smoke.alpha = 1.0f;
        smoke.frame = CGRectMake(0, smokeLocation, Incense_Screen_Width, 520);
        [self.view addSubview:smoke];
        _smoke = smoke;
    }
    return _smoke;
}

- (void)renewSmokeStatusWithTimeHaveGone:(CGFloat)leaveBackInterval {
    
    smokeLocation += smokeChangeRate * Size_Ratio_To_iPhone6 * leaveBackInterval * (60.0f / self.incenseView.displaylink.frameInterval);
}

#pragma mark - Cloud

/**
 *  Cloud exists before the incense is burnt. After the incense being lighted, cloud would disappear with fire.
 */
- (CLFCloud *)cloud {
    if (!_cloud) {
        CLFCloud *cloud = [[CLFCloud alloc] init];
        cloud.userInteractionEnabled = NO;
        cloud.delegate = self;
        [self.view addSubview:cloud];
        _cloud = cloud;
    }
    return _cloud;
}

- (void)makeCloud {
    self.cloud.alpha = 1.0f;
    self.cloud.dragEnable = YES;
    self.cloud.wouldBurnt = NO;
    // 140 是指一开始可见的部分高度
    self.cloud.frame = CGRectMake(0, cloudLocation, Incense_Screen_Width, 380 + 140 * Size_Ratio_To_iPhone6); // 也许要换成1042
}

- (void)cloudRebound {
    [UIView animateKeyframesWithDuration:1.0f delay:0.0f options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        self.cloud.frame = CGRectMake(0, cloudLocation, Incense_Screen_Width, 380 + 140 * Size_Ratio_To_iPhone6);
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - Fire

/**
 *  Fire located on cloud, which used to light the incense (but in this program, whether the incense lighted is determined by the position of cloud).
 */
- (UIImageView *)fire {
    if (!_fire) {
        UIImageView *fire = [[UIImageView alloc] init];
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"Fire" withExtension:@"gif"];
        fire.image = [UIImage animatedImageWithAnimatedGIFURL:url];
        _fire = fire;
    }
    return _fire;
}

- (void)makeFire {
    self.cloud.cloudImageView.alpha = 1.0f;
    [self.cloud addSubview:self.fire];
    CGFloat fireW = 18;
    CGFloat fireH = 24;
    self.fire.alpha = 0.0f;
    self.fire.frame = CGRectMake((Incense_Screen_Width - fireW) / 2, (CGRectGetHeight(self.cloud.frame) - 80), fireW, fireH);
    [UIView animateWithDuration:0.5f animations:^{
        self.fire.alpha = 1.0f;
    } completion:^(BOOL finished) {
        self.cloud.userInteractionEnabled = YES;
    }];
}

- (void)fireAppearInSky {
    [UIView animateWithDuration:1.0f animations:^{
        self.smoke.frame = CGRectMake(0, -440 , Incense_Screen_Width, 520); // 让火焰的出现更自然
    } completion:^(BOOL finished) {
        [self makeFire];
        self.smoke.frame = CGRectMake(0, smokeLocation , Incense_Screen_Width, 520);
        self.smoke.layer.zPosition = 0;
    }];
}

#pragma mark - Ripple

/**
 *  eeeeeeee..........Ripple.
 */
- (UIView *)rippleView {
    if (!_rippleView) {
        UIView *rippleView = [[UIView alloc] init];
        rippleView.frame = CGRectMake(0, Incense_Screen_Height - Incense_Location - 80, Incense_Screen_Width, 180);
        rippleView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:rippleView];
        _rippleView = rippleView;
    }
    return _rippleView;
}

- (void)makeRipple {
    self.rippleView.alpha = 1.0f;

    self.rippleMaker.animationView = self.rippleView;
    
    if (needSpan) {
        [self.rippleMaker spanWaveContinuallyWithTimeInterval:animationTime];
        needSpan = NO;
    }

    CATransform3D rotate = CATransform3DMakeRotation(M_PI / 3, 1, 0, 0);
    self.rippleView.layer.transform = [CLFTools CATransform3DPerspect:rotate center:CGPointMake(0, 0) disZ:200];
}

- (BMWaveMaker *)rippleMaker {
    if (!_rippleMaker) {
        _rippleMaker = [[BMWaveMaker alloc] init];
        _rippleMaker.spanScale = 100.0f;
        _rippleMaker.originRadius = 0.9f;
        _rippleMaker.waveColor = [UIColor whiteColor];
        _rippleMaker.animationDuration = 30.0f;
        _rippleMaker.wavePathWidth = 1.5f;
    }
    return _rippleMaker;
}

#pragma mark - About Audio

/**
 *  audioView and musicView have the same function but different styles. we can switch between audioView and musicView by setting kMusicListStyle.
 *
 */
- (CLFAudioPlayView *)audioView {
    if (!_audioView) {
        CLFAudioPlayView *audioView = [[CLFAudioPlayView alloc] init];
        audioView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:audioView];
        _audioView = audioView;
    }
    return _audioView;
}

- (void)makeAudioView {
    self.audioView.userInteractionEnabled = NO;
    self.audioView.frame = CGRectMake(0, Incense_Screen_Height - 60, Incense_Screen_Width, 40);
    self.audioView.show = NO;
    self.audioView.alpha = 0.0f;
}

- (void)showAudioView {
    [self.audioView showAudioButtons];
}

- (void)setupRecorder {
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    
    NSDictionary *settings = @{AVSampleRateKey:          [NSNumber numberWithFloat: 44100.0],
                               AVFormatIDKey:            [NSNumber numberWithInt: kAudioFormatAppleLossless],
                               AVNumberOfChannelsKey:    [NSNumber numberWithInt: 2],
                               AVEncoderAudioQualityKey: [NSNumber numberWithInt: AVAudioQualityMin]};
        
    NSError *error;
    self.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    
    if (error) {
        NSLog(@"Ups, could not create recorder %@", error);
        return;
    }
        
    [self.recorder prepareToRecord];
    [self.recorder setMeteringEnabled:YES];
    [self.recorder record];
}

#pragma - Swith to ShareVC;

- (void)switchToShareVCWithView:(UIImageView *)view viewRatio:(CGFloat)viewRatio {
    CLFShareViewController *shareVC = [[CLFShareViewController alloc] init];
    self.modalTransitionManager.pushed = NO;
    self.modalTransitionManager.numberSnapshot = view;
    self.modalTransitionManager.numberRatio = viewRatio;
    shareVC.transitioningDelegate = self.modalTransitionManager;
    [self presentViewController:shareVC animated:true completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

