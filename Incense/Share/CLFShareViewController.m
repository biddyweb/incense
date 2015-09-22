//
//  CLFShareViewController.m
//  Incense
//
//  Created by CaiGavin on 9/21/15.
//  Copyright © 2015 CaiGavin. All rights reserved.
//

#import "CLFShareViewController.h"
#import "CLFCardView.h"
#import "CLFIncenseCommonHeader.h"
#import "WeixinActivity.h"

@interface CLFShareViewController ()

@property (nonatomic, weak) CLFCardView *cardView;
@property (nonatomic, weak) UIButton *shareButton;

@end

@implementation CLFShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:233 / 255.0 green:233 / 255.0 blue:233 / 255.0 alpha:1.0];
//    [self loadSubViews];
    self.shareButton.frame = CGRectMake((Incense_Screen_Width - 50) * 0.5, Incense_Screen_Height - 115, 50, 50);
    CGFloat cardViewX = 20.0f;
    CGFloat cardViewW = Incense_Screen_Width - 2.0f * cardViewX;
    CGFloat cardViewH = (cardViewW / 4.0f) * 3.0f;
    self.cardView.frame = CGRectMake(cardViewX, Incense_Screen_Height + 10, cardViewW, cardViewH);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showCardView];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)setContainerRatio:(CGFloat)containerRatio {
    _containerRatio = containerRatio;
    self.cardView.containerRatio = containerRatio;
}

- (void)setContainerSnapShot:(UIView *)containerSnapShot {
    _containerSnapShot = containerSnapShot;
    self.cardView.incenseSnapshot = containerSnapShot;
}

- (void)setNumberSnapShot:(UIView *)numberSnapShot {
    _numberSnapShot = numberSnapShot;
    numberSnapShot.frame = CGRectMake(8, 15, 20, 20 * self.numberRatio);
//    numberSnapShot.backgroundColor = [UIColor greenColor];
    [self.cardView addSubview:numberSnapShot];
}

- (CLFCardView *)cardView {
    if (!_cardView) {
        CLFCardView *cardView = [[CLFCardView alloc] init];
        cardView.layer.shadowColor = [[UIColor blackColor] CGColor];
        cardView.layer.shadowOffset = CGSizeMake(0.0f, 12.0f);
        cardView.layer.shadowOpacity = 0.1f;
        cardView.layer.shadowRadius = 6.0f;
        [self.view addSubview:cardView];
        _cardView = cardView;
    }
    return _cardView;
}

- (UIButton *)shareButton {
    if (!_shareButton) {
        UIButton *shareButton = [[UIButton alloc] init];
        [shareButton addTarget:self action:@selector(showShareActivity) forControlEvents:UIControlEventTouchUpInside];
//        shareButton.backgroundColor = [UIColor blueColor];
        [shareButton setImage:[UIImage imageNamed:@"ShareButton"] forState:UIControlStateNormal];
        shareButton.layer.shadowColor = [[UIColor blackColor] CGColor];
        shareButton.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
        shareButton.layer.shadowOpacity = 0.1f;
        shareButton.layer.shadowRadius = 6.0f;
        shareButton.adjustsImageWhenHighlighted = NO;
        [self.view addSubview:shareButton];
        _shareButton = shareButton;
    }
    return _shareButton;
}

- (void)showCardView {
    CGFloat cardViewX = 20.0f;
    CGFloat cardViewY = Incense_Screen_Height * 0.15f;
    CGFloat cardViewW = Incense_Screen_Width - 2.0f * cardViewX;
    CGFloat cardViewH = (cardViewW / 4.0f) * 3.0f;
    
    [UIView animateWithDuration:1.0f
                          delay:0.0f
         usingSpringWithDamping:0.8f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.cardView.frame = CGRectMake(cardViewX, cardViewY, cardViewW, cardViewH);
    }
                     completion:nil];
}

- (void)showShareActivity {
    UIImage *screenShot = [self takeSnapshotOfView:self.cardView];
    NSArray *actItems = @[screenShot];
    NSArray *activity = @[[[WeixinSessionActivity alloc] init], [[WeixinTimelineActivity alloc] init]];
    
    UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:actItems applicationActivities:activity];
    activityView.excludedActivityTypes = @[UIActivityTypePrint,
                                           UIActivityTypeCopyToPasteboard,
                                           UIActivityTypeAssignToContact,
                                           UIActivityTypeMessage,
                                           UIActivityTypeAddToReadingList];
    [self presentViewController:activityView animated:YES completion:nil];
    
    [activityView setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *error) {
    }];
}

- (UIImage *)takeSnapshotOfView:(UIView *)view {
    CGFloat reductionFactor = 0.3;
    UIGraphicsBeginImageContext(CGSizeMake(view.frame.size.width/reductionFactor, view.frame.size.height/reductionFactor));
    [view drawViewHierarchyInRect:CGRectMake(0, 0, view.frame.size.width/reductionFactor, view.frame.size.height/reductionFactor) afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
