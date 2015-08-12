//
//  CLFSmokeEmitterView.m
//  Incense
//
//  Created by CaiGavin on 8/12/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#import "CLFSmokeEmitterView.h"

@implementation CLFSmokeEmitterView {
    CAEmitterLayer *smokeEmitter;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        smokeEmitter = (CAEmitterLayer *)self.layer;
        smokeEmitter.emitterPosition = CGPointMake(3, -30);  //坐标
        smokeEmitter.emitterSize = CGSizeMake(1, 1);       //粒子大小
        smokeEmitter.renderMode = kCAEmitterLayerAdditive; //递增渲染模式
        smokeEmitter.emitterShape = kCAEmitterLayerLine;
        smokeEmitter.emitterMode	= kCAEmitterLayerOutline;
        
        CAEmitterCell *fire = [CAEmitterCell emitterCell];
        fire.birthRate = 120;     //粒子出生率
        fire.lifetime = 2;    //粒子生命时间
        fire.lifetimeRange = 20;   //生命时间变化范围
        
        fire.color = [[UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:0.6] CGColor];  //粒子颜色
        fire.contents = (id)[[UIImage imageNamed:@"DazFire.png"] CGImage];
        fire.velocity = 1;     //速度
        fire.velocityRange = 2; //速度范围
        fire.emissionRange = 1.0; //发射角度
        fire.scaleSpeed = 0.05;  //变大速度
        [fire setName:@"smoke"];  //cell名字，方便根据名字以后查找修改
        fire.yAcceleration		= -8;
        fire.emissionLongitude  = M_PI;
        
        smokeEmitter.emitterCells = [NSArray arrayWithObject:fire];
    }
    return self;
}

+ (Class)layerClass  {
    return [CAEmitterLayer class];
}


@end
