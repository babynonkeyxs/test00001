//
//  Utilities.h
//  video
//
//  Created by kouqingwei on 2019/8/18.
//  Copyright © 2019 xs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Utilities : NSObject

+(UIImage *)imageWithColor:(UIColor *)color;

+(UIColor *)hexStringToColor:(NSString *)string;
+(UIColor *)hexStringToColor:(NSString *)stringToConvert andAlpha:(CGFloat)alpha;

@end

NS_ASSUME_NONNULL_END
