//
//  CLFFireEmitterView.m
//  Incense
//
//  Created by CaiGavin on 8/12/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "CLFFireEmitterView.h"

@implementation CLFFireEmitterView {
    CAEmitterLayer *fireEmitter;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        fireEmitter = (CAEmitterLayer *)self.layer;
        fireEmitter.emitterPosition = CGPointMake(20, 20);  //坐标
        fireEmitter.emitterSize = CGSizeMake(2, 2);       //粒子大小
        fireEmitter.renderMode = kCAEmitterLayerAdditive; //递增渲染模式
        fireEmitter.emitterShape = kCAEmitterLayerLine;
        fireEmitter.emitterMode	= kCAEmitterLayerOutline;
        
        CAEmitterCell *fire = [CAEmitterCell emitterCell];
        fire.birthRate = 10;     //粒子出生率
        fire.lifetime = 0.2;    //粒子生命时间
        fire.lifetimeRange = 0;   //生命时间变化范围
        
        fire.color = [[UIColor colorWithRed:1.0 green:0.5 blue:0.0 alpha:0.8] CGColor];  //粒子颜色
        fire.contents = (id)[[UIImage imageNamed:@"DazFire.png"] CGImage];
        fire.velocity = 30;     //速度
        fire.velocityRange = 20; //速度范围
        fire.emissionRange = 1.2; //发射角度
        fire.scaleSpeed = 0.3;  //变大速度
        [fire setName:@"fire"];  //cell名字，方便根据名字以后查找修改
        fire.yAcceleration		= -20;
        fire.emissionLongitude  = M_PI;
        
        fireEmitter.emitterCells = [NSArray arrayWithObject:fire];
    }
    return self;
}

+ (Class)layerClass  {
    return [CAEmitterLayer class];
}

@end
