//
//  PlayerProgressView.h
//  video
//
//  Created by kouqingwei on 2019/8/18.
//  Copyright © 2019 xs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PlayerProgressView : UIView

@property(nonatomic,assign)float cacheValue;

@property(nonatomic,assign)float playValue;

@property(nonatomic,strong)UIColor *cacheProgressTintColor;

@property(nonatomic,strong)UIColor *playProgressTintColor;


@property(nonatomic,assign) BOOL sliderIsMoveing;

@property(nonatomic,copy) void(^sliderBtnMoving)(float);

@property(nonatomic,copy) void(^sliderBtnMoveEnded)(float);

@property(nonatomic,copy) void(^tapProgressView)(float);


@property(nonatomic,assign)CGSize minHitTestSize;


@end

NS_ASSUME_NONNULL_END
