//
//  AMapLogFileManager.h
//  SensorRecoder
//
//  Created by liubo on 11/15/16.
//  Copyright © 2016 AutoNavi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>

#pragma mark - CMAcceleration

@interface AMapLogFileManager : NSObject

+ (AMapLogFileManager *)logFileManagerWithFileName:(NSString *)logFileName;

- (BOOL)addLocationLogString:(NSString *)logString;
- (BOOL)addMotionLogString:(NSString *)logString;

@end

#pragma mark - CMAcceleration

@interface AMapLogFileManagerUtility : NSObject

//Location
+ (NSString *)logStringFormCLLocation:(CLLocation *)aLocation;
+ (CLLocation *)CLLocationFromLogString:(NSString *)logString;

//Motion
+ (NSString *)logStringFromCMDeviceMotion:(CMDeviceMotion *)deviceMotion;
+ (void)attitudeValueFromLogString:(NSString *)logString
                              roll:(double *)roll
                             pitch:(double *)pitch
                               yaw:(double *)yaw
                    rotationMatrix:(CMRotationMatrix *)martix
                        quaternion:(CMQuaternion *)quaternion;
+ (CMRotationRate)rotationRateFromLogString:(NSString *)logString;
+ (CMAcceleration)accelerationFromLogString:(NSString *)logString;
+ (CMAcceleration)userAccelerationFromLogString:(NSString *)logString;
+ (CMCalibratedMagneticField)magneticFieldFromLogString:(NSString *)logString;

@end

#pragma mark - AMapLocationLogPlayback

typedef void(^AMapLocationLogPlaybackBlock)(CLLocation *location, NSUInteger index, BOOL *stop);

@interface AMapLocationLogPlayback : NSObject

@property (nonatomic, readonly) BOOL isPlaying;

+ (AMapLocationLogPlayback *)playbackWithFilePath:(NSString *)filePath;

- (void)startPlaybackUsingLocationBlock:(AMapLocationLogPlaybackBlock)locationBlock;
- (void)stopPlayback;

@end
