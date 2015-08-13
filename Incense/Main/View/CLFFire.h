//
//  CLFFire.h
//  Incense
//
//  Created by CaiGavin on 8/11/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CLFFireDelegate <NSObject>

- (void)lightTheIncense;

@end

@interface CLFFire : UIImageView

@property (nonatomic, assign, getter=isDragEnable) BOOL dragEnable;
@property (nonatomic, weak) id<CLFFireDelegate> delegate;

@end
