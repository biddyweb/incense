//
//  CLFCloud.h
//  Incense
//
//  Created by CaiGavin on 8/19/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CLFCloudDelegate <NSObject>

- (void)lightTheIncenseWithIncenseHeight:(CGFloat)incenseHeight;
- (void)cloudRebound;

@end

@interface CLFCloud : UIView

@property (nonatomic, assign, getter=isDragEnable) BOOL                 dragEnable;
@property (nonatomic, assign)                      BOOL                 wouldBurnt;
@property (nonatomic, weak)                        UIImageView          *cloudImageView;
@property (nonatomic, weak)                        id<CLFCloudDelegate> delegate;

@end
