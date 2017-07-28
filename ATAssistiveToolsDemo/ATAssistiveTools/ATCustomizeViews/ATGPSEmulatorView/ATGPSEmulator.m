//
//  ATGPSEmulator.m
//  ATAssistiveTools
//
//  Created by liubo on 2017/7/27.
//  Copyright © 2017年 devliubo. All rights reserved.
//

#import "ATGPSEmulator.h"

@interface ATGPSEmulator ()
{
    CLLocationCoordinate2D *coordinates;
    UInt64 count;
}

@property (nonatomic, assign) ATGPSEmulatorType type;
@property (nonatomic, assign) BOOL isSimulating;

@property (nonatomic, copy) NSString *filePath;

@end

@implementation ATGPSEmulator

#pragma mark - Life Cycle

- (instancetype)init
{
    if (self = [super init])
    {
        [self buildGpsEmulator];
    }
    return self;
}

- (void)dealloc
{
    [self stopEmulator];
}

- (void)buildGpsEmulator
{
    [self initProperties];
}

- (void)initProperties
{
    _type = 0;
    _isSimulating = NO;
}

#pragma mark - Interface

- (void)setCoordinates:(CLLocationCoordinate2D *)coordinates count:(UInt64)count
{
    
}

- (void)setLogFilePath:(NSString *)filePath
{
    
}

- (void)startEmulatorWithType:(ATGPSEmulatorType)type
{
    
}

- (void)stopEmulator
{
    
}

@end
