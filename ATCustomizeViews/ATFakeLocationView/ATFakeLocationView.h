//
//  ATFakeLocationView.h
//  ATAssistiveTools
//
//  Created by liubo on 2017/7/14.
//  Copyright © 2017年 devliubo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ATCustomViewProtocol.h"

@interface ATFakeLocationView : UIView <ATCustomViewProtocol>

@end

@interface ATSimlulateCoordinate : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, assign) BOOL useCLLocationCoordiante;
@property (nonatomic, assign) BOOL useCLLocationManager;

@property (nonatomic, assign) CLLocationCoordinate2D externalWGS84Coordinate;
@property (nonatomic, assign) CLLocationCoordinate2D externalGCJ02Coordinate;

@end
