//
//  ATDeviceLogsView.h
//  ATAssistiveTools
//
//  Created by liubo on 2017/7/11.
//  Copyright © 2017年 devliubo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATCustomViewProtocol.h"

@interface ATDeviceLogsView : UIView <ATCustomViewProtocol>

+ (void)asyncReadDeviceLogsWithCompletionBlock:(void (^)(NSString *logs))completionBlock;

@end
