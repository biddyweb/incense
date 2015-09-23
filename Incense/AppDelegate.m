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
#import "AppDelegate.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "WXApi.h"

@interface AppDelegate () <UIAlertViewDelegate, WXApiDelegate>

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
    [WXApi registerApp:@"wxf2f0e430f493af01"];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];

    [Fabric with:@[[Crashlytics class]]];

    NSString *key = (NSString *)kCFBundleVersionKey;
    NSString *version = [NSBundle mainBundle].infoDictionary[key];
    NSString *oldVersion = [[NSUserDefaults standardUserDefaults] valueForKey:@"firstLaunch"];

    if ([version isEqualToString:oldVersion]) {
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
        leaveTime = [NSDate date];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    if (![application.keyWindow.rootViewController isKindOfClass:[CLFMainViewController class]]) {
        return;
    }
    CLFMainViewController *mainVC = (CLFMainViewController *) application.keyWindow.rootViewController;
    if (mainVC.burning) { // 正在燃烧
        [mainVC.recorder pause];
        CLFIncenseView *incense = mainVC.incenseView;
        timeHaveGone = [incense timeHaveGone];
        incense.displaylink.paused = YES; // 暂停动画
        leaveTime = [NSDate date];
        UIApplicationState state = application.applicationState;

        if (state == UIApplicationStateInactive) {
            // 锁屏
            [self addFinishedNotificationWithTimeHaveGone:timeHaveGone];
            leaveBySwitch = NO;

        } else if (state == UIApplicationStateBackground) { // 进入后台
            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"kDisplayStatusLocked"]) {
                [self addAlertNotification];
                leaveBySwitch = YES;
            } else {
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

        notification.alertBody = @"香已燃尽，起来休息下吧";
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

        notification.alertBody = @"志士惜日短，愁人知夜长";

        notification.userInfo = @{@"identifier" : @"switchNotification"};

        notification.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kDisplayStatusLocked"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [application cancelAllLocalNotifications];

    [self appLaunchTimes];
}

static CGFloat totalLeaveBackInterval = 0;

- (void)applicationDidBecomeActive:(UIApplication *)application {

    if (![application.keyWindow.rootViewController isKindOfClass:[CLFMainViewController class]]) { //
        firstLaunch = NO;
        return;
    }

    if (!firstLaunch) {
        CLFMainViewController *mainVC = (CLFMainViewController *) application.keyWindow.rootViewController;
        if (mainVC.burning) {
            [mainVC.recorder record];
            backTime = [NSDate date];
            NSTimeInterval leaveTimeInterval = [leaveTime timeIntervalSince1970];
            NSTimeInterval backTimeInterval = [backTime timeIntervalSince1970];
            CGFloat leaveBackInterval = backTimeInterval - leaveTimeInterval;

            CLFIncenseView *incense = mainVC.incenseView;
            incense.displaylink.paused = NO;

            if (leaveBySwitch && leaveBackInterval > 10) {
                [mainVC incenseDidBurnOffFromBackgroundWithResult:@"failure"];
            } else if (leaveBackInterval > Incense_Burn_Off_Time - timeHaveGone) {  // If the incense have burnt off when user come back.
                totalLeaveBackInterval += Incense_Burn_Off_Time - timeHaveGone;

                [incense renewStatusWithTheTimeHaveGone:leaveBackInterval];
                [mainVC renewSmokeStatusWithTimeHaveGone:Incense_Burn_Off_Time - timeHaveGone];
            } else {
                totalLeaveBackInterval += leaveBackInterval;

                [incense renewStatusWithTheTimeHaveGone:leaveBackInterval];
                [mainVC renewSmokeStatusWithTimeHaveGone:leaveBackInterval];
            }
        }
    } else {
        firstLaunch = NO;
    }
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"喜欢【一炷香】 么?"
                                                        message:@"给个好评吧~"
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


#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CLFPoems" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CLFPoems.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
