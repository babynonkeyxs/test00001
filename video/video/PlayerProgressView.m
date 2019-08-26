//
//  PlayerProgressView.m
//  video
//
//  Created by kouqingwei on 2019/8/18.
//  Copyright © 2019 xs. All rights reserved.
//

#import "PlayerProgressView.h"
#import "SliderButton.h"

@interface PlayerProgressView()

@property(nonatomic,strong) UIView *cacheProgressView;

@property(nonatomic,strong) UIView *playProgressView;

@property(nonatomic,strong) SliderButton *sliderBtn;

@end

@implementation PlayerProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]){
        //correct From Name
        self.cacheProgressView.frame = CGRectMake(0, 0, 0, frame.size.height);
        self.cacheProgressView.backgroundColor = [UIColor blueColor];
        [self addSubview:self.cacheProgressView];
        
        //
        self.playProgressView.frame = CGRectMake(0, 0, 0, frame.size.height);
        self.playProgressView.backgroundColor = [UIColor cyanColor];
        [self addSubview:self.playProgressView];
        
        self.sliderBtn.frame = CGRectMake(0, 0, 20, 20);
        self.sliderBtn.minHitTestSize = CGSizeMake(40, 40);
        self.sliderBtn.layer.cornerRadius = 10;
        self.sliderBtn.backgroundColor = [UIColor redColor];
        self.sliderBtn.center = CGPointMake(self.playProgressView.frame.size.width, self.playProgressView.frame.size.height/2);
        [self addSubview:self.sliderBtn];
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(UIView *)cacheProgressView{
    if (!_cacheProgressView) {
        _cacheProgressView = [[UIView alloc]init];
    }
    return _cacheProgressView;
}

-(UIView *)playProgressView{
    if (!_playProgressView) {
        _playProgressView = [[UIView alloc]init];
    }
    return _playProgressView;
}

-(SliderButton *)sliderBtn{
    if (!_sliderBtn) {
        _sliderBtn = [[SliderButton alloc]init];
        
        __weak __typeof(&*self)weakSelf = self;
        _sliderBtn.sliderButtonMove = ^(UITouch *touch){
            
            CGPoint movePoint = [touch locationInView:weakSelf];
            //NSLog(@"movePoint:%@",NSStringFromCGPoint(movePoint));
            float temp = weakSelf.sliderBtn.frame.size.width/2;
            
            if ((movePoint.x >= - temp) && (movePoint.x <= (weakSelf.frame.size.width - temp))) {
                
                weakSelf.sliderBtn.frame = CGRectMake(movePoint.x, weakSelf.sliderBtn.frame.origin.y, weakSelf.sliderBtn.frame.size.width, weakSelf.sliderBtn.frame.size.height);
                
                weakSelf.playProgressView.frame = CGRectMake(weakSelf.playProgressView.frame.origin.x, weakSelf.playProgressView.frame.origin.y, weakSelf.sliderBtn.center.x, weakSelf.playProgressView.frame.size.height);
                
                weakSelf.sliderBtnMoving(weakSelf.sliderBtn.center.x/weakSelf.frame.size.width);
            }
            
            weakSelf.sliderIsMoveing = YES;
        };
        
        _sliderBtn.sliderButtonMoveEnded = ^(UITouch *touch){
            
            weakSelf.sliderBtnMoveEnded(weakSelf.sliderBtn.center.x/weakSelf.frame.size.width);
        };
    }
    return _sliderBtn;
}

-(void)setCacheValue:(float)cacheValue
{
    if (cacheValue > 1) {
        _cacheValue = 1;
    }else if(cacheValue < 0){
        _cacheValue = 0;
    }else{
        _cacheValue = cacheValue;
    }
    
    self.cacheProgressView.frame = CGRectMake(self.cacheProgressView.frame.origin.x, self.cacheProgressView.frame.origin.y, self.frame.size.width *cacheValue, self.cacheProgressView.frame.size.height);
}

-(void)setPlayValue:(float)playValue
{
    if (_playValue > 1) {
        _playValue = 1;
    }else if(_playValue < 0){
        _playValue = 0;
    }else{
        _playValue = playValue;
    }
    
    self.playProgressView.frame = CGRectMake(self.playProgressView.frame.origin.x, self.playProgressView.frame.origin.y, self.frame.size.width *playValue, self.playProgressView.frame.size.height);
    self.sliderBtn.center = CGPointMake(self.playProgressView.frame.size.width, self.playProgressView.frame.size.height/2);
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    self.cacheProgressView.frame = CGRectMake(self.cacheProgressView.frame.origin.x, self.cacheProgressView.frame.origin.y, self.cacheProgressView.frame.size.width, frame.size.height);
    self.playProgressView.frame = CGRectMake(self.playProgressView.frame.origin.x, self.playProgressView.frame.origin.y, self.playProgressView.frame.size.width, frame.size.height);
}

-(void)setCacheProgressTintColor:(UIColor *)cacheProgressTintColor
{
    self.cacheProgressView.backgroundColor = cacheProgressTintColor;
}

#pragma mark-
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];

    //
    if (point.x < 0) {
        point.x = 0;
    }

    if(point.x > self.frame.size.width){
        point.x = self.frame.size.width;
    }

    self.sliderBtnMoveEnded(point.x/self.frame.size.width);
    self.sliderIsMoveing = YES;

    //
    self.playProgressView.frame = CGRectMake(self.playProgressView.frame.origin.x, self.playProgressView.frame.origin.y, point.x, self.playProgressView.frame.size.height);
    self.sliderBtn.center = CGPointMake(point.x,self.frame.size.height/2);
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

}


-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {

    if (!self.isUserInteractionEnabled || self.isHidden || self.alpha <= 0.01) {
        return nil;
    }

    //
    for (UIView *subview in [self.subviews reverseObjectEnumerator]) {
        CGPoint convertedPoint = [subview convertPoint:point fromView:self];
        UIView *hitTestView = [subview hitTest:convertedPoint withEvent:event];
        if (hitTestView) {
            return hitTestView;
        }
    }

    //
    if([self pointInside:point withEvent:event]){
        return self;
    }

    return nil;
}


- (BOOL)pointInside:(CGPoint)point withEvent:(nullable UIEvent *)event {

    CGRect bounds = self.bounds;
    bounds = CGRectInset(bounds, -0.5 * self.minHitTestSize.width, -0.5 * self.minHitTestSize.height);
    
    return CGRectContainsPoint(bounds, point);
}

@end
