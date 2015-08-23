//
//  CLFNewFeatureController.m
//  Incense
//
//  Created by CaiGavin on 8/20/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "CLFNewFeatureController.h"
#import "CLFMainViewController.h"
#import "CLFPageControl.h"
#import "Masonry.h"

@interface CLFNewFeatureController () <UIScrollViewDelegate>

@property (nonatomic, weak) UIScrollView   *scrollView;
@property (nonatomic, weak) CLFPageControl *pageControl;

@end

@implementation CLFNewFeatureController

static const NSInteger NewFeaturePages = 5;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor whiteColor];
        if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
            [self prefersStatusBarHidden];
            [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
        }
    }
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupScrollView];
    
    [self setupPageControl];
}

- (void)setupScrollView {
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.backgroundColor = [UIColor whiteColor];
    scrollView.frame = self.view.bounds;
    [self.view addSubview:scrollView];
    
    CGFloat pageW = CGRectGetWidth(scrollView.frame);
    CGFloat pageH = CGRectGetHeight(scrollView.frame);
    
    for (NSInteger i = 0; i < NewFeaturePages; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        
        NSString *name = [NSString stringWithFormat:@"NewFeature%ld", i + 1];
        imageView.image = [UIImage imageNamed:name];
        
        CGFloat pageX = i * pageW;
        CGFloat pageY = 0;
        imageView.frame = CGRectMake(pageX, pageY, pageW, pageH);
        
        [scrollView addSubview:imageView];
        
        if (NewFeaturePages - 1 == i) {
            [self setupLastImageView:imageView];
        }
    }
    
    scrollView.contentSize = CGSizeMake(NewFeaturePages * pageW, 0);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;
    scrollView.bounces = NO;
    scrollView.delegate = self;
    
    self.scrollView = scrollView;
}

- (void)setupLastImageView:(UIImageView *)imageView {
    imageView.userInteractionEnabled = YES;
    
    UIButton *startButton = [[UIButton alloc] init];
    [startButton addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];
    [imageView addSubview:startButton];
    
    [startButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(imageView);
        make.height.equalTo(imageView);
        make.centerX.equalTo(imageView);
    }];
}

- (void)start {
    [UIView animateWithDuration:2.0f animations:^{
        self.scrollView.alpha = 0.0f;
        self.pageControl.alpha = 0.0f;
    } completion:^(BOOL finished) {
        if (finished) {
            self.view.window.rootViewController = [[CLFMainViewController alloc] init];
        }
    }];
}

- (void)setupPageControl {
    CLFPageControl *pageControl = [[CLFPageControl alloc] init];
    pageControl.numberOfPages = NewFeaturePages;
    [self.view addSubview:pageControl];
    
    [pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).multipliedBy(2).offset(-50);
        make.height.equalTo(@30);
        make.width.equalTo(@100);
    }];
    
    pageControl.userInteractionEnabled = NO;
    
//    pageControl.currentPageIndicatorTintColor = [UIColor redColor];
//    pageControl.pageIndicatorTintColor = [UIColor colorWithRed:231/255.0 green:231/255.0 blue:231/255.0 alpha:1.0];

    self.pageControl = pageControl;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    
    NSInteger page = (offsetX + 0.5 * CGRectGetWidth(scrollView.frame)) / CGRectGetWidth(scrollView.frame);
    self.pageControl.currentPage = page;
//    if (page == 4) {
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self start];
//        });
//    }
}

@end

