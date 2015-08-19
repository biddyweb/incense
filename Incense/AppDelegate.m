//
//  AppDelegate.m
//  Incense
//
//  Created by CaiGavin on 8/10/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "AppDelegate.h"
#import "CLFMainViewController.h"
#import "CLFIncenseView.h"

@interface AppDelegate ()

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
    // Override point for customization after application launch.
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    NULL,
                                    displayStatusChanged,
                                    CFSTR("com.apple.springboard.lockcomplete"),
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}


static UIBackgroundTaskIdentifier taskID;
- (void)applicationDidEnterBackground:(UIApplication *)application {
    CLFMainViewController *mainVC = (CLFMainViewController *) application.keyWindow.rootViewController;
    if (mainVC.burning) { // 正在燃烧
        CLFIncenseView *incense = mainVC.incenseView;
        timeHaveGone = [incense timeHaveGone];
        incense.displaylink.paused = YES; // 暂停动画
        NSLog(@"time have gone %f", timeHaveGone);
        leaveTime = [NSDate date];
        //    NSLog(@"enterBackground %@", [NSDate date]);
        
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

                taskID = [application beginBackgroundTaskWithExpirationHandler:^{
                    [application endBackgroundTask:taskID];
                    taskID = UIBackgroundTaskInvalid;
                }];
                
                NSLog(@"starting background task");
                
#warning - 此处待解决. 如何在本地通知没有被点击的情况下灭掉香? remaining
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ // 死锁???
//                    // Do the work associated with the task.
//                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                        NSLog(@"finishing background task");
//                        [application endBackgroundTask:taskID];
//                        taskID = UIBackgroundTaskInvalid;
//                    });
//                });
                
                
                NSLog(@"Finish background task");
                [[UIApplication sharedApplication] endBackgroundTask:taskID];
                taskID = UIBackgroundTaskInvalid;
                
            } else {
                NSLog(@"kkkk Sent to background by locking screen");
                leaveBySwitch = NO;
                [self addFinishedNotificationWithTimeHaveGone:timeHaveGone];
            }
        }
    }
}

- (void)addFinishedNotificationWithTimeHaveGone:(CGFloat)timeHaveGone; {
    CGFloat notificationTimeInterval = 60.0f - timeHaveGone;
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    if (notification) {
        // 设置通知的提醒时间
        NSDate *currentDate   = [NSDate date];
        notification.timeZone = [NSTimeZone defaultTimeZone]; // 使用本地时区
        notification.fireDate = [currentDate dateByAddingTimeInterval:notificationTimeInterval];
        
        notification.repeatInterval = 0;
        
        notification.alertBody = @"施主,香已烧尽...";
        notification.alertAction = @"一炷香";
        
        notification.userInfo = @{@"identifier" : @"finishNotification"};
        
        // 通知提示音 使用默认的
        //        notification.soundName= UILocalNotificationDefaultSoundName;
        
        // 将通知添加到系统中
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

- (void)addAlertNotification {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    if (notification) {
        // 设置通知的提醒时间
        NSDate *currentDate   = [NSDate date];
        notification.timeZone = [NSTimeZone defaultTimeZone]; // 使用本地时区
        notification.fireDate = [currentDate dateByAddingTimeInterval:1.0];
        
        notification.repeatInterval = 0;
        
        notification.alertBody = @"烧香要虔诚懂不懂啊白痴!";
        
        notification.userInfo = @{@"identifier" : @"switchNotification"};
        
        // 通知提示音 使用默认的
        //        notification.soundName= UILocalNotificationDefaultSoundName;
        
        // 将通知添加到系统中
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    CLFMainViewController *mainVC = (CLFMainViewController *) application.keyWindow.rootViewController;
    if ([notification.userInfo[@"identifier"] isEqualToString:@"switchNotification"]) {
        NSLog(@"乖乖回来就对啦");

    } else if ([notification.userInfo[@"identifier"] isEqualToString:@"finishNotification"]) {
        NSLog(@"烧完啦烧完啦烧完啦");
//        [mainVC incenseDidBurnOff];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kDisplayStatusLocked"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [application endBackgroundTask:taskID];
    taskID = UIBackgroundTaskInvalid;
    [application cancelAllLocalNotifications];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {

    if (!firstLaunch) {
        CLFMainViewController *mainVC = (CLFMainViewController *) application.keyWindow.rootViewController;
        if (mainVC.burning) {
            backTime = [NSDate date];
            NSTimeInterval leaveTimeInterval = [leaveTime timeIntervalSince1970];
            NSTimeInterval backTimeInterval = [backTime timeIntervalSince1970];
            CGFloat leaveBackInterval = backTimeInterval - leaveTimeInterval;
            
            CLFIncenseView *incense = mainVC.incenseView;
            incense.displaylink.paused = NO;
            
            
            
            
            if (leaveBySwitch && leaveBackInterval > 5) {
                    NSLog(@"叫你不及时回来!!");
//                    [incense renewStatusWithTheTimeHaveGone:-1];
                [mainVC incenseDidBurnOffForALongTime];
            } else if ((leaveBackInterval > 60 - timeHaveGone)) { // 这个条件永远不会用到??
                NSLog(@"超时啦啦啦啦啦啦啦啦啦");
//                  [incense renewStatusWithTheTimeHaveGone:-1];
                [mainVC incenseDidBurnOffForALongTime];
            } else {
                NSLog(@"回来回来啦啦啦");
                [incense renewStatusWithTheTimeHaveGone:leaveBackInterval];
            }
            
//            if ((leaveBySwitch && leaveBackInterval > 5) || (leaveBackInterval > 10 - timeHaveGone)) {
//                NSLog(@"超时啦啦啦啦啦啦啦啦啦");
//                [incense renewStatusWithTheTimeHaveGone:-1];
//            } else {
//                [incense renewStatusWithTheTimeHaveGone:leaveBackInterval];
//            }
            
            
        
            
        }
    } else {
        firstLaunch = NO;
    }
    
    
    NSLog(@"becomeActive %@", [NSDate date]);
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
