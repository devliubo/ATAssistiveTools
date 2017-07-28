//
//  ATContainerWindow.h
//  ATAssistiveTools
//
//  Created by liubo on 2017/5/26.
//  Copyright © 2017年 devliubo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ATContainerWindowDelegate <NSObject>

//- (BOOL)customPointInside:(CGPoint)point withEvent:(nullable UIEvent *)event;

@end

@interface ATContainerWindow : UIWindow

@property (nonatomic, weak) id<ATContainerWindowDelegate> containerDelegate;

@end

NS_ASSUME_NONNULL_END
