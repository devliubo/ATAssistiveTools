//
//  ATGPSEmulatorView.h
//  ATAssistiveTools
//
//  Created by liubo on 2017/7/27.
//  Copyright © 2017年 devliubo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AMapNaviKit/AMapNaviKit.h>
#import "ATCustomViewProtocol.h"

@class ATGPSEmulatorView;

@protocol ATGPSEmulatorViewDelegate <NSObject>



@end

@interface ATGPSEmulatorView : UIView <ATCustomViewProtocol>

@property (nonatomic, weak) id<ATGPSEmulatorViewDelegate> delegate;

- (void)setNaviManager:(AMapNaviBaseManager *)naviManager;

- (void)loadRouteData;

@end
