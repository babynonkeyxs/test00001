//
//  SliderButton.h
//  video
//
//  Created by kouqingwei on 2019/8/18.
//  Copyright © 2019 xs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SliderButton : UIView

@property(nonatomic,copy) void(^sliderButtonMove)(UITouch *);

@property(nonatomic,copy) void(^sliderButtonMoveEnded)(UITouch *);

@property(nonatomic,assign)CGSize minHitTestSize;

@end

NS_ASSUME_NONNULL_END
