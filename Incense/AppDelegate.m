//
//  AppDelegate.m
//  Incense
//
//  Created by CaiGavin on 8/10/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "AppDelegate.h"
#import "CLFMainViewController.h"
#import "CLFNewFeatureController.h"
#import "CLFIncenseView.h"
#import "CLFIncenseCommonHeader.h"

@interface AppDelegate () <UIAlertViewDelegate>

@end

@implementation AppDelegate

static BOOL firstLaunch = YES;
static NSDate *leaveTime;
static NSDate *backTime;
static CGFloat timeHaveGone;
static BOOL leaveBySwitch = NO;

static void displayStatusChanged(CFNotificationCenterRef center,
                                 void *observer,
                                 CFStringRef name,
                                 const void *object,
                                 CFDictionaryRef userInfo) {
    if (name == CFSTR("com.apple.springboard.lockcomplete")) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kDisplayStatusLocked"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];
    
    NSString *key = (NSString *)kCFBundleVersionKey;
    NSString *version = [NSBundle mainBundle].infoDictionary[key];
    NSString *oldVersion = [[NSUserDefaults standardUserDefaults] valueForKey:@"firstLaunch"];
    
    NSLog(@"version %@, oldVersion %@", version, oldVersion);
    
    if ([version isEqualToString:oldVersion]) {
        NSLog(@"dududududud");
        self.window.rootViewController = [[CLFMainViewController alloc] init];
    } else {
        self.window.rootViewController = [[CLFNewFeatureController alloc] init];
        [[NSUserDefaults standardUserDefaults] setValue:version forKey:@"firstLaunch"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    NULL,
                                    displayStatusChanged,
                                    CFSTR("com.apple.springboard.lockcomplete"),
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
    
    [self appLaunchTimes];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    if (![application.keyWindow.rootViewController isKindOfClass:[CLFMainViewController class]]) {
        return;
    }
    CLFMainViewController *mainVC = (CLFMainViewController *) application.keyWindow.rootViewController;
    if (mainVC.burning) { // 正在燃烧
        [mainVC.recorder pause];
        CLFIncenseView *incense = mainVC.incenseView;
        timeHaveGone = [incense timeHaveGone];
        incense.displaylink.paused = YES; // 暂停动画
        NSLog(@"Resign TimeHaveGone %f", timeHaveGone);
        leaveTime = [NSDate date];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"Did Enter BackGround");
    if (![application.keyWindow.rootViewController isKindOfClass:[CLFMainViewController class]]) {
        return;
    }
    CLFMainViewController *mainVC = (CLFMainViewController *) application.keyWindow.rootViewController;
    if (mainVC.burning) { // 正在燃烧
        [mainVC.recorder pause];
        CLFIncenseView *incense = mainVC.incenseView;
        timeHaveGone = [incense timeHaveGone];
        incense.displaylink.paused = YES; // 暂停动画
        NSLog(@"time have gone %f", timeHaveGone);
        leaveTime = [NSDate date];
        UIApplicationState state = application.applicationState;
        
        if (state == UIApplicationStateInactive) {
            // 锁屏
            NSLog(@"Sent to background by locking screen");
            [self addFinishedNotificationWithTimeHaveGone:timeHaveGone];
            leaveBySwitch = NO;
            
        } else if (state == UIApplicationStateBackground) { // 进入后台
            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"kDisplayStatusLocked"]) {
                [self addAlertNotification];
                NSLog(@"switch");
                leaveBySwitch = YES;
            } else {
                NSLog(@"kkkk Sent to background by locking screen");
                leaveBySwitch = NO;
                [self addFinishedNotificationWithTimeHaveGone:timeHaveGone];
            }
        }
    }
}

- (void)addFinishedNotificationWithTimeHaveGone:(CGFloat)timeHaveGone; {
    CGFloat notificationTimeInterval = Incense_Burn_Off_Time - timeHaveGone;
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    if (notification) {
        NSDate *currentDate   = [NSDate date];
        notification.timeZone = [NSTimeZone defaultTimeZone]; // 使用本地时区
        notification.fireDate = [currentDate dateByAddingTimeInterval:notificationTimeInterval];
        notification.repeatInterval = 0;
        
        notification.alertBody = @"施主,香已烧尽...";
        notification.alertAction = @"一炷香";
        
        notification.userInfo = @{@"identifier" : @"finishNotification"};
    
        notification.soundName = UILocalNotificationDefaultSoundName;
    
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

- (void)addAlertNotification {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    if (notification) {
        NSDate *currentDate   = [NSDate date];
        notification.timeZone = [NSTimeZone defaultTimeZone];
        notification.fireDate = [currentDate dateByAddingTimeInterval:1.0];
        notification.repeatInterval = 0;
        
        notification.alertBody = @"烧香要虔诚懂不懂啊白痴!";
        
        notification.userInfo = @{@"identifier" : @"switchNotification"};
        
        notification.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kDisplayStatusLocked"];
    [[NSUserDefaults standardUserDefaults] synchronize];
//    for (UILocalNotification *noti in application.scheduledLocalNotifications) {
//        noti.applicationIconBadgeNumber = 0;
//        [application scheduleLocalNotification:noti];
//    }
    
    [application cancelAllLocalNotifications];
    
    [self appLaunchTimes];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {

    if (![application.keyWindow.rootViewController isKindOfClass:[CLFMainViewController class]]) { //
        firstLaunch = NO;
        return;
    }
    
    if (!firstLaunch) {
        
        NSLog(@"enterHere...jiongjiongjiong...");
        CLFMainViewController *mainVC = (CLFMainViewController *) application.keyWindow.rootViewController;
        if (mainVC.burning) {
            [mainVC.recorder record];
            backTime = [NSDate date];
            NSTimeInterval leaveTimeInterval = [leaveTime timeIntervalSince1970];
            NSTimeInterval backTimeInterval = [backTime timeIntervalSince1970];
            CGFloat leaveBackInterval = backTimeInterval - leaveTimeInterval;
            
            if (leaveBackInterval > Incense_Burn_Off_Time - timeHaveGone) {
                leaveBackInterval = Incense_Burn_Off_Time - timeHaveGone;
            }
            
            CLFIncenseView *incense = mainVC.incenseView;
            incense.displaylink.paused = NO;
            
            if (leaveBySwitch && leaveBackInterval > 5) {
                [mainVC incenseDidBurnOffForALongTime];
            } else {
                NSLog(@"回来回来啦啦啦");
                NSLog(@"leaveBackInterval : %f", leaveBackInterval);
                [incense renewStatusWithTheTimeHaveGone:leaveBackInterval];
                [mainVC renewSmokeStatusWithTimeHaveGone:leaveBackInterval];
            }
        }
    } else {
        firstLaunch = NO;
    }
    
    NSLog(@"becomeActive %@", [NSDate date]);
}

- (void)appLaunchTimes {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger launchTime = [defaults integerForKey:@"launchTime"];
    
    if (launchTime) {
        launchTime ++;
    } else {
        launchTime = 1;
    }

    if ([[UIApplication sharedApplication].keyWindow.rootViewController isKindOfClass:[CLFNewFeatureController class]]) {
        return;
    }
    
    CLFMainViewController *mainVC = (CLFMainViewController *) [UIApplication sharedApplication].keyWindow.rootViewController;
    if (33 <= launchTime && !mainVC.burning) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"喜欢 一炷香 吗?"
                                                        message:@"亲~赏个好评吧~O(∩_∩)O~~"
                                                       delegate:self
                                              cancelButtonTitle:@"再看看"
                                              otherButtonTitles:@"准了!", nil];
        [alert show];
        launchTime = 0;
    }
    [defaults setInteger:launchTime forKey:@"launchTime"];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: {
            break;
        }
        case 1: {
            NSString *appid = @"1021176188";
            NSString *str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/cn/app/id%@?mt=8", appid];
            NSURL *url = [NSURL URLWithString:str];
            [[UIApplication sharedApplication] openURL:url];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSInteger launchTime = [defaults integerForKey:@"launchTime"];
            launchTime = -666666;
            [defaults setInteger:launchTime forKey:@"launchTime"];
            break;
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

@end
