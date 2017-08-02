//
//  ATGPSEmulator.h
//  ATAssistiveTools
//
//  Created by liubo on 2017/7/27.
//  Copyright © 2017年 devliubo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol ATGPSEmulatorDelegate <NSObject>
@required

/**
 *  Called when GPS emulator produce new location.
 *
 *  @param location a new location
 */
- (void)gpsEmulatorUpdateLocation:(CLLocation *)location;

@end

@interface ATGPSEmulator : NSObject

/**
 *  A object adopt the ATGPSEmulatorDelegate protocol
 */
@property (nonatomic, weak) id<ATGPSEmulatorDelegate> delegate;

/**
 *  Indicate whether the GPS emulator isSimulating.
 */
@property (atomic, readonly) BOOL isSimulating;

/**
 *  Simulate Speed(Unit: km/h; Default: 60km/h;)
 */
@property (nonatomic, assign) double simulateSpeed;

/**
 *  Assign coordiantes that used for simulate. Invoke this method after start emulator has no effect.
 *
 *  @param coordinates coordinate list
 *  @param count coordiantes count
 */
- (void)setCoordinates:(CLLocationCoordinate2D *)coordinates count:(unsigned long)count;

/**
 *  Start Emulator
 */
- (void)startEmulator;

/**
 *  Stop Emulator
 */
- (void)stopEmulator;

@end
