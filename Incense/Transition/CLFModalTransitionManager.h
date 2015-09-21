//
//  CLFModalTransitionManager.h
//  Incense
//
//  Created by CaiGavin on 9/21/15.
//  Copyright © 2015 CaiGavin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CLFModalTransitionManager : NSObject <UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate>

@property (nonatomic, assign, getter=isPushed) BOOL pushed;

@end
