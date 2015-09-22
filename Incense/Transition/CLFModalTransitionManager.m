//
//  CLFModalTransitionManager.m
//  Incense
//
//  Created by CaiGavin on 9/21/15.
//  Copyright © 2015 CaiGavin. All rights reserved.
//

#import "CLFModalTransitionManager.h"
#import "CLFMainViewController.h"
#import "CLFShareViewController.h"

@interface CLFModalTransitionManager ()

@property (nonatomic, weak) UIView *homeSnapshot;
@property (nonatomic, weak) UIView *incenseSnapshot;

@end

@implementation CLFModalTransitionManager


- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 1.0;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    if (!_pushed) {
        [self pushInTransition:transitionContext];
    } else {
        [self popInTransition:transitionContext];
    }
    _pushed = !_pushed;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}

- (void)pushInTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    CLFMainViewController *fromViewController = (CLFMainViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    CLFShareViewController *toViewController = (CLFShareViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    self.homeSnapshot = [fromViewController.view snapshotViewAfterScreenUpdates:false];
    self.incenseSnapshot = [fromViewController.container snapshotViewAfterScreenUpdates:false];
    
    toViewController.containerRatio = 1.0f * CGRectGetHeight(fromViewController.container.frame) / CGRectGetWidth(fromViewController.container.frame);
    toViewController.containerSnapShot = self.incenseSnapshot;
    toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
    toViewController.view.alpha = 0.0;
    
    [containerView addSubview:self.homeSnapshot];
    [containerView addSubview:toViewController.view];
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:duration animations:^{
        toViewController.view.alpha = 1.0;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:(![transitionContext transitionWasCancelled])];
    }];
}

- (void)popInTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    CLFShareViewController *fromViewController = (CLFShareViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:duration animations:^{
        fromViewController.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:(![transitionContext transitionWasCancelled])];
    }];
}

@end
