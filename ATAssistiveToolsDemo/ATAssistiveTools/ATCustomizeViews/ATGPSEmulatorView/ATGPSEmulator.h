//
//  ATGPSEmulator.h
//  ATAssistiveTools
//
//  Created by liubo on 2017/7/27.
//  Copyright © 2017年 devliubo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef NS_ENUM(NSUInteger, ATGPSEmulatorType) {
    ATGPSEmulatorCoordinate = 1,
    ATGPSEmulatorLofFile = 2,
};

@class ATGPSEmulator;

@protocol ATGPSEmulatorDelegate <NSObject>

- (void)gpsEmulator:(ATGPSEmulator *)emulator updateLocation:(CLLocation *)location;

@end

@interface ATGPSEmulator : NSObject

@property (nonatomic, readonly) ATGPSEmulatorType type;

@property (nonatomic, readonly) BOOL isSimulating;

- (void)setCoordinates:(CLLocationCoordinate2D *)coordinates count:(UInt64)count;

- (void)setLogFilePath:(NSString *)filePath;

- (void)startEmulatorWithType:(ATGPSEmulatorType)type;
- (void)stopEmulator;

@end
