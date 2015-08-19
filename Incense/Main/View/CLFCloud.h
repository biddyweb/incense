//
//  CLFCloud.h
//  Incense
//
//  Created by CaiGavin on 8/19/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CLFCloudDelegate <NSObject>

- (void)lightTheIncense;
- (void)cloudRebound;

@end

@interface CLFCloud : UIImageView

@property (nonatomic, assign, getter=isDragEnable) BOOL dragEnable;
@property (nonatomic, weak)                        id<CLFCloudDelegate> delegate;

@end
