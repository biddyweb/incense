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
#import "CLFTools.h"

@interface CLFShareViewController ()

@property (nonatomic, weak) CLFCardView *cardView;
@property (nonatomic, weak) UIButton *shareButton;
@property (nonatomic, weak) UIView   *container;

@end

@implementation CLFShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.view.backgroundColor = [UIColor colorWithRed:233 / 255.0 green:233 / 255.0 blue:233 / 255.0 alpha:1.0];
    self.view.backgroundColor = [UIColor whiteColor];
    self.shareButton.adjustsImageWhenHighlighted = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showCardView];
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissToMain)];
    [self.view addGestureRecognizer:tapRecognizer];
}

- (void)dismissToMain {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)setContainerRatio:(CGFloat)containerRatio {
    _containerRatio = containerRatio;
    self.cardView.containerRatio = containerRatio;
}

- (void)setContainerSnapShot:(UIImageView *)containerSnapShot {
    _containerSnapShot = containerSnapShot;
    self.cardView.incenseSnapshot = containerSnapShot;
}

- (void)setBurntNumber:(NSInteger)burntNumber {
    _burntNumber = burntNumber;
    self.cardView.burntNumber = burntNumber;
}

- (UIView *)container {
    if (!_container) {
        UIView *container = [[UIView alloc] init];
        container.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:container];
        _container = container;
    }
    return _container;
}

- (CLFCardView *)cardView {
    if (!_cardView) {
        CLFCardView *cardView = [[CLFCardView alloc] init];
        [cardView getPoem];
        cardView.layer.shadowColor = [[UIColor blackColor] CGColor];
        cardView.layer.shadowOffset = CGSizeMake(0.0f, 12.0f);
        cardView.layer.shadowOpacity = 0.1f;
        cardView.layer.shadowRadius = 6.0f;
        CGFloat cardViewX = 20.0f;
        CGFloat cardViewW = Incense_Screen_Width - 2.0f * cardViewX;
        CGFloat cardViewH = (cardViewW / 4.0f) * 3.0f;
        cardView.layer.borderWidth = 1.5f;
        cardView.layer.borderColor = [[UIColor whiteColor] CGColor];
        cardView.frame = CGRectMake(cardViewX, Incense_Screen_Height + 10, cardViewW, cardViewH);
        [cardView.layer setShadowPath:[[UIBezierPath bezierPathWithRect:cardView.bounds] CGPath]];
        [self.container addSubview:cardView];
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
        shareButton.frame = CGRectMake((Incense_Screen_Width - 50) * 0.5, Incense_Screen_Height - 115, 50, 50);
        shareButton.layer.shadowColor = [[UIColor blackColor] CGColor];
        shareButton.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
        shareButton.layer.shadowOpacity = 0.1f;
        shareButton.layer.shadowRadius = 6.0f;
        [shareButton.layer setShadowPath:[[UIBezierPath bezierPathWithOvalInRect:shareButton.bounds] CGPath]];
        
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
    
    CGFloat padding =  (Incense_Screen_Width - cardViewH) * 0.33;
    
    self.container.frame = CGRectMake(0, cardViewY - padding, Incense_Screen_Width, Incense_Screen_Width);
    
    [UIView animateWithDuration:1.0f
                          delay:0.0f
         usingSpringWithDamping:0.8f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.cardView.frame = CGRectMake(cardViewX, padding, cardViewW, cardViewH);
    }
                     completion:^(BOOL finished) {
                         [self.cardView makeRipple];
                     }];
}

- (void)showShareActivity {
    UIImage *screenShot = [CLFTools takeSnapshotOfView:self.container];
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

@end
