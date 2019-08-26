//
//  SliderButton.m
//  video
//
//  Created by kouqingwei on 2019/8/18.
//  Copyright © 2019 xs. All rights reserved.
//

#import "SliderButton.h"

@implementation SliderButton

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if (self.sliderButtonMove) {
        UITouch *touch = [touches anyObject];
        self.sliderButtonMove(touch);
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    if (self.sliderButtonMoveEnded) {
        UITouch *touch = [touches anyObject];
        self.sliderButtonMoveEnded(touch);
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

- (BOOL)pointInside:(CGPoint)point withEvent:(nullable UIEvent *)event {
    
    CGRect bounds = self.bounds;
    bounds = CGRectInset(bounds, -0.5 * self.minHitTestSize.width, -0.5 * self.minHitTestSize.height);
    
    return CGRectContainsPoint(bounds, point);
}

@end
