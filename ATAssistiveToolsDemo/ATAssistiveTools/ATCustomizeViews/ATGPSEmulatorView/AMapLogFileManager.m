//
//  AMapLogFileManager.m
//  SensorRecoder
//
//  Created by liubo on 11/15/16.
//  Copyright © 2016 AutoNavi. All rights reserved.
//

#import "AMapLogFileManager.h"
#include <stdio.h>

#define kAMapLogFileManagerDir  @"AMapLogFiles"

#define kAMapLogFileLocation    @"logFile_Location.txt"
#define kAMapLogFileMotion      @"logFile_Motion.txt"
#define kAMapLogFileInfo        @"logFile_Info.txt"

@interface AMapLogFileManager ()
{
    NSString *_basePath;
    NSString *_fileName;
    NSString *_fullFilePath;
    NSString *_startTime;
    
    NSString *_filePathLocation;
    NSString *_filePathMotion;
    NSString *_filePathInfo;
}

@end

@implementation AMapLogFileManager

#pragma mark - Life Cycle

- (instancetype)initWithLogFileName:(NSString *)logFileName
{
    if (self = [super init])
    {
        _fileName = logFileName;
        
        [self buildLogFileManager];
    }
    return self;
}

- (void)dealloc
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    formatter.dateFormat = @"yyyy_MM_dd_HH_mm_ss";
    
    [self addLogString:_startTime forFile:_filePathInfo];
    [self addLogString:[formatter stringFromDate:[NSDate date]] forFile:_filePathInfo];
}

- (void)buildLogFileManager
{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    _basePath = [documentPath stringByAppendingPathComponent:kAMapLogFileManagerDir];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    formatter.dateFormat = @"yyyy_MM_dd_HH_mm_ss";
    _startTime = [formatter stringFromDate:[NSDate date]];
    
    NSString *currentLogDirectory = _startTime;
    if (_fileName != nil || _fileName.length > 0)
    {
        currentLogDirectory = [NSString stringWithFormat:@"%@_%@", _startTime, _fileName];
    }
    _fullFilePath = [_basePath stringByAppendingPathComponent:currentLogDirectory];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:_fullFilePath] == NO)
    {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:_fullFilePath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
        
        if (error)
        {
            NSLog(@"createDirectoryError:%@", error);
        }
    }
    
    NSLog(@"filePath:%@", _fullFilePath);
    
    _filePathLocation = [_fullFilePath stringByAppendingPathComponent:kAMapLogFileLocation];
    _filePathMotion = [_fullFilePath stringByAppendingPathComponent:kAMapLogFileMotion];
    _filePathInfo = [_fullFilePath stringByAppendingPathComponent:kAMapLogFileInfo];
}

#pragma mark - Interface

+ (AMapLogFileManager *)logFileManagerWithFileName:(NSString *)logFileName;
{
    AMapLogFileManager *logFileManager = [[AMapLogFileManager alloc] initWithLogFileName:logFileName];
    return logFileManager;
}

- (BOOL)addLocationLogString:(NSString *)logString
{
    return [self addLogString:logString forFile:_filePathLocation];
}

- (BOOL)addMotionLogString:(NSString *)logString
{
    return [self addLogString:logString forFile:_filePathMotion];
}

- (BOOL)addLogString:(NSString *)logString forFile:(NSString *)filePath
{
    FILE *file = fopen([filePath UTF8String], "at+");
    
    if (file == NULL)
    {
        NSLog(@"open file failed: %@", filePath);
        return NO;
    }
    
    fprintf(file, "%s\n", logString.UTF8String);
    
    fclose(file);
    file = NULL;
    
//    NSLog(@"log:%@", logString);
    
    return YES;
}

@end

@implementation AMapLogFileManagerUtility

+ (NSString *)logStringFormCLLocation:(CLLocation *)aLocation
{
    if (aLocation == nil)
    {
        return nil;
    }
    
    NSMutableString *logString = [[NSMutableString alloc] init];
    
    [logString appendFormat:@"%f,%f,%f,%f,%f,%f,%f,%f", aLocation.coordinate.latitude, aLocation.coordinate.longitude, aLocation.altitude, aLocation.horizontalAccuracy, aLocation.verticalAccuracy, aLocation.course, aLocation.speed, [aLocation.timestamp timeIntervalSince1970]];
    
    return logString;
}

+ (CLLocation *)CLLocationFromLogString:(NSString *)logString
{
    if (logString == nil)
    {
        return nil;
    }
    
    NSArray *components = [logString componentsSeparatedByString:@","];
    
    double lat = [[components objectAtIndex:0] doubleValue];
    double lon = [[components objectAtIndex:1] doubleValue];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(lat, lon);
    
    double altitude = [[components objectAtIndex:2] doubleValue];
    double horAccuracy = [[components objectAtIndex:3] doubleValue];
    double verAccuracy = [[components objectAtIndex:4] doubleValue];
    double course = [[components objectAtIndex:5] doubleValue];
    double speed = [[components objectAtIndex:6] doubleValue];
    NSDate *timestamp = [NSDate dateWithTimeIntervalSince1970:[[components objectAtIndex:7] doubleValue]];
    
    CLLocation *location = [[CLLocation alloc] initWithCoordinate:coordinate altitude:altitude horizontalAccuracy:horAccuracy verticalAccuracy:verAccuracy course:course speed:speed timestamp:timestamp];
    
    return location;
}

+ (NSString *)logStringFromCMDeviceMotion:(CMDeviceMotion *)deviceMotion
{
    NSMutableString *logString = [[NSMutableString alloc] init];
    
    //attitude
    CMAttitude *aAttitude = deviceMotion.attitude;
    [logString appendFormat:@"%f,%f,%f,", aAttitude.roll, aAttitude.pitch, aAttitude.yaw];
    [logString appendFormat:@"%f,%f,%f,%f,%f,%f,%f,%f,%f,", aAttitude.rotationMatrix.m11, aAttitude.rotationMatrix.m12, aAttitude.rotationMatrix.m13, aAttitude.rotationMatrix.m21, aAttitude.rotationMatrix.m22, aAttitude.rotationMatrix.m23, aAttitude.rotationMatrix.m31, aAttitude.rotationMatrix.m32, aAttitude.rotationMatrix.m33];
    [logString appendFormat:@"%f,%f,%f,%f,", aAttitude.quaternion.x, aAttitude.quaternion.y, aAttitude.quaternion.z, aAttitude.quaternion.w];
    
    //rotationRate
    [logString appendFormat:@"%f,%f,%f,", deviceMotion.rotationRate.x, deviceMotion.rotationRate.y, deviceMotion.rotationRate.z];
    
    //gravity
    [logString appendFormat:@"%f,%f,%f,", deviceMotion.gravity.x, deviceMotion.gravity.y, deviceMotion.gravity.z];
    
    //userAcceleration
    [logString appendFormat:@"%f,%f,%f,", deviceMotion.userAcceleration.x, deviceMotion.userAcceleration.y, deviceMotion.userAcceleration.z];
    
    //magneticField
    [logString appendFormat:@"%f,%f,%f,%d,", deviceMotion.magneticField.field.x, deviceMotion.magneticField.field.y, deviceMotion.magneticField.field.z, deviceMotion.magneticField.accuracy];
    
    //timestamp
    [logString appendFormat:@"%f,%f", deviceMotion.timestamp, [[NSDate date] timeIntervalSince1970]];
    
    return logString;
}

+ (void)attitudeValueFromLogString:(NSString *)logString
                              roll:(double *)roll
                             pitch:(double *)pitch
                               yaw:(double *)yaw
                    rotationMatrix:(CMRotationMatrix *)martix
                        quaternion:(CMQuaternion *)quaternion
{
    NSArray *components = [logString componentsSeparatedByString:@","];
    
    if (roll != NULL) *roll = [[components objectAtIndex:0] doubleValue];
    if (pitch != NULL) *pitch = [[components objectAtIndex:1] doubleValue];
    if (yaw != NULL) *yaw = [[components objectAtIndex:2] doubleValue];
    
    if (martix != NULL)
    {
        (*martix).m11 = [[components objectAtIndex:3] doubleValue];
        (*martix).m12 = [[components objectAtIndex:4] doubleValue];
        (*martix).m13 = [[components objectAtIndex:5] doubleValue];
        (*martix).m21 = [[components objectAtIndex:6] doubleValue];
        (*martix).m22 = [[components objectAtIndex:7] doubleValue];
        (*martix).m23 = [[components objectAtIndex:8] doubleValue];
        (*martix).m31 = [[components objectAtIndex:9] doubleValue];
        (*martix).m32 = [[components objectAtIndex:10] doubleValue];
        (*martix).m33 = [[components objectAtIndex:11] doubleValue];
    }
    
    if (quaternion != NULL)
    {
        (*quaternion).x = [[components objectAtIndex:12] doubleValue];
        (*quaternion).y = [[components objectAtIndex:13] doubleValue];
        (*quaternion).z = [[components objectAtIndex:14] doubleValue];
        (*quaternion).w = [[components objectAtIndex:15] doubleValue];
    }
}

+ (CMRotationRate)rotationRateFromLogString:(NSString *)logString
{
    NSArray *components = [logString componentsSeparatedByString:@","];
    
    double x = [[components objectAtIndex:16] doubleValue];
    double y = [[components objectAtIndex:17] doubleValue];
    double z = [[components objectAtIndex:18] doubleValue];
    
    CMRotationRate reVal = {x, y, z};
    
    return reVal;
}

+ (CMAcceleration)accelerationFromLogString:(NSString *)logString
{
    NSArray *components = [logString componentsSeparatedByString:@","];
    
    double x = [[components objectAtIndex:19] doubleValue];
    double y = [[components objectAtIndex:20] doubleValue];
    double z = [[components objectAtIndex:21] doubleValue];
    
    CMAcceleration reVal = {x, y, z};
    
    return reVal;
}

+ (CMAcceleration)userAccelerationFromLogString:(NSString *)logString
{
    NSArray *components = [logString componentsSeparatedByString:@","];
    
    double x = [[components objectAtIndex:22] doubleValue];
    double y = [[components objectAtIndex:23] doubleValue];
    double z = [[components objectAtIndex:24] doubleValue];
    
    CMAcceleration reVal = {x, y, z};
    
    return reVal;
}

+ (CMCalibratedMagneticField)magneticFieldFromLogString:(NSString *)logString
{
    NSArray *components = [logString componentsSeparatedByString:@","];
    
    double x = [[components objectAtIndex:25] doubleValue];
    double y = [[components objectAtIndex:26] doubleValue];
    double z = [[components objectAtIndex:27] doubleValue];
    int accuracy = [[components objectAtIndex:28] intValue];
    
    CMMagneticField field = {x, y, z};
    CMCalibratedMagneticField reVal = {field, accuracy};
    
    return reVal;
}

@end

@interface AMapLocationLogPlayback ()
{
    NSString *_filePath;
    
    NSMutableArray <CLLocation *> *_locations;
    NSThread *_locationsThread;
}

@property (nonatomic, readwrite) BOOL isPlaying;

@end

@implementation AMapLocationLogPlayback

#pragma mark - Life Cycle

- (instancetype)initWithFilePath:(NSString *)filePath
{
    if (self = [super init])
    {
        _filePath = filePath;
        _locations = [NSMutableArray array];
        _isPlaying = NO;
        
        [self parseLocationLogFile];
    }
    
    return self;
}

- (void)dealloc
{
    if (_locationsThread)
    {
        [_locationsThread cancel];
        _locationsThread = nil;
    }
}

- (void)parseLocationLogFile
{
    if (_filePath == nil)
    {
        return;
    }
    
    NSError *error = nil;
    NSString *logFileString = [NSString stringWithContentsOfFile:_filePath encoding:NSUTF8StringEncoding error:&error];
    if (error)
    {
        NSLog(@"load location log file failed!!!");
        return;
    }
    
    NSArray *allLogStrings = [logFileString componentsSeparatedByString:@";\n"];
    for (NSString *aLog in allLogStrings)
    {
        if (aLog.length > 0)
        {
            CLLocation *aLocation = [AMapLogFileManagerUtility CLLocationFromLogString:aLog];
            [_locations addObject:aLocation];
        }
    }
}

#pragma mark - Helper

- (void)locationsHandleBlock:(AMapLocationLogPlaybackBlock)block
{
    BOOL shouldStop = NO;
    NSUInteger index = 0;
    CLLocation *location = nil;
    NSDate *addedTime = nil;
    
    while (!shouldStop && index < _locations.count && ![_locationsThread isCancelled])
    {
        NSDate *currentTime = [_locations[index] timestamp];
        NSTimeInterval timeInterval = [currentTime timeIntervalSinceDate:addedTime];
        
        location = _locations[index];
        addedTime = currentTime;
        
        [NSThread sleepForTimeInterval:timeInterval];
        
        CLLocation *newLocation = [[CLLocation alloc] initWithCoordinate:location.coordinate
                                                                altitude:location.altitude
                                                      horizontalAccuracy:location.horizontalAccuracy
                                                        verticalAccuracy:location.verticalAccuracy
                                                                  course:location.course
                                                                   speed:location.speed
                                                               timestamp:[NSDate date]];
        
        block(newLocation, index, &shouldStop);
        
        ++index;
    }
}

#pragma mark - Interface

+ (AMapLocationLogPlayback *)playbackWithFilePath:(NSString *)filePath
{
    return [[AMapLocationLogPlayback alloc] initWithFilePath:filePath];
}

- (void)startPlaybackUsingLocationBlock:(AMapLocationLogPlaybackBlock)locationBlock
{
    if (!locationBlock || _isPlaying)
    {
        return;
    }
    
    if (_locationsThread)
    {
        [_locationsThread cancel];
        _locationsThread = nil;
    }
    
    _isPlaying = YES;
    
    if (locationBlock)
    {
        _locationsThread = [[NSThread alloc] initWithTarget:self selector:@selector(locationsHandleBlock:) object:locationBlock];
        [_locationsThread setName:@"AMapLocationLogPlaybackThread"];
        [_locationsThread start];
    }
}

- (void)stopPlayback
{
    if (_locationsThread)
    {
        [_locationsThread cancel];
    }
    
    _isPlaying = NO;
}

@end
