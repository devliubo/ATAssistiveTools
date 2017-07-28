//
//  ATAssistiveTools.h
//  ATAssistiveTools
//
//  Created by liubo on 2017/5/26.
//  Copyright © 2017年 devliubo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATCustomViewProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATAssistiveTools : NSObject

+ (instancetype)sharedInstance;

- (void)show;

@property (nonatomic, readonly) UIWindow *mainWindow;

@end

@interface ATAssistiveTools (CustomView)



@end

NS_ASSUME_NONNULL_END
