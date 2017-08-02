//
//  ATGPSEmulator.m
//  ATAssistiveTools
//
//  Created by liubo on 2017/7/27.
//  Copyright © 2017年 devliubo. All rights reserved.
//

#import "ATGPSEmulator.h"

#pragma mark - basic

bool coordinateEqualToCoordiante(CLLocationCoordinate2D coordiante1, CLLocationCoordinate2D coordinate2)
{
#define kATGPSNodePointEquallyValue (0.000001)
    
    if (fabs(coordiante1.latitude - coordinate2.latitude) < kATGPSNodePointEquallyValue
        && fabs(coordiante1.longitude - coordinate2.longitude) < kATGPSNodePointEquallyValue)
    {
        return true;
    }
    else
    {
        return false;
    }
}

double distanceBetweenCoordinates(CLLocationCoordinate2D pointA, CLLocationCoordinate2D pointB)
{
#define AMAPLOC_DEG_TO_RAD      0.0174532925199432958f
#define AMAPLOC_EARTH_RADIUS    6378137.0f
    
    double latitudeArc  = (pointA.latitude - pointB.latitude) * AMAPLOC_DEG_TO_RAD;
    double longitudeArc = (pointA.longitude - pointB.longitude) * AMAPLOC_DEG_TO_RAD;
    
    double latitudeH = sin(latitudeArc * 0.5);
    latitudeH *= latitudeH;
    double lontitudeH = sin(longitudeArc * 0.5);
    lontitudeH *= lontitudeH;
    
    double tmp = cos(pointA.latitude * AMAPLOC_DEG_TO_RAD) * cos(pointB.latitude*AMAPLOC_DEG_TO_RAD);
    return AMAPLOC_EARTH_RADIUS * 2.0 * asin(sqrt(latitudeH + tmp*lontitudeH));
}

CLLocationCoordinate2D coordinateAtRateOfCoordinates(CLLocationCoordinate2D from, CLLocationCoordinate2D to, double rate)
{
    if (rate >= 1.f) return to;
    if (rate <= 0.f) return from;
    
    double latitudeDelta = (to.latitude - from.latitude) * rate;
    double longitudeDelta = (to.longitude - from.longitude) * rate;
    
    return CLLocationCoordinate2DMake(from.latitude + latitudeDelta, from.longitude + longitudeDelta);
}

double normalizeDegree(double degree)
{
    double normalizationDegree = fmod(degree, 360.f);
    return (normalizationDegree < 0) ? normalizationDegree += 360.f : normalizationDegree;
}

double angleBetweenCoordinates(CLLocationCoordinate2D pointA, CLLocationCoordinate2D pointB)
{
    double longitudeDelta = pointB.longitude - pointA.longitude;
    double latitudeDelta = pointB.latitude - pointA.latitude;
    double azimuth = (M_PI * .5f) - atan2(latitudeDelta, longitudeDelta);
    
    return normalizeDegree(azimuth * 180 / M_PI);
}

#pragma mark - ATGPSEmulator

@interface ATGPSEmulator ()
{
    CLLocationCoordinate2D *_oriCoordinates;
    unsigned long _count;
}

@property (nonatomic, strong) NSThread *locationsThread;
@property (atomic, assign) BOOL isSimulating;
@property (nonatomic, assign) double timeInverval;

@property (nonatomic, strong) NSRecursiveLock *lock;
@property (nonatomic, assign) double speed;
@property (nonatomic, assign) double distancePerStep;

@end

@implementation ATGPSEmulator

#pragma mark - Life Cycle

- (instancetype)init
{
    if (self = [super init])
    {
        [self buildGPSEmulator];
    }
    return self;
}

- (void)dealloc
{
    [self stopEmulator];
    
    [self deleteCoordinates];
}

- (void)buildGPSEmulator
{
    [self initProperties];
}

- (void)initProperties
{
    _isSimulating = NO;
    _timeInverval = 1.f;
    
    self.lock = [[NSRecursiveLock alloc] init];
    self.simulateSpeed = 60.0;
}

#pragma mark - Interface

- (void)setSimulateSpeed:(double)simulateSpeed
{
    _simulateSpeed = MAX(0, MIN(200, simulateSpeed));
    
    [self.lock lock];
    self.speed = _simulateSpeed / 3.6f;
    self.distancePerStep = self.timeInverval * self.speed;
    [self.lock unlock];
}

- (void)setCoordinates:(CLLocationCoordinate2D *)coordinates count:(unsigned long)count
{
    if (self.isSimulating)
    {
        return;
    }
    
    if (coordinates == NULL || count <= 0)
    {
        return;
    }
    
    [self deleteCoordinates];
    
    _count = count;
    _oriCoordinates = (CLLocationCoordinate2D *)malloc(sizeof(CLLocationCoordinate2D) * _count);
    for (int i = 0; i < _count; i++)
    {
        _oriCoordinates[i].latitude = (*(coordinates+i)).latitude;
        _oriCoordinates[i].longitude = (*(coordinates+i)).longitude;
    }
}

- (void)startEmulator
{
    if (self.isSimulating)
    {
        return;
    }
    
    if (_locationsThread)
    {
        [_locationsThread cancel];
        _locationsThread = nil;
    }
    
    self.isSimulating = YES;
    
    _locationsThread = [[NSThread alloc] initWithTarget:self selector:@selector(locationThreadEntryMethod) object:nil];
    [_locationsThread setName:@"com.devliubo.ATGPSEmulatorThread.coordinate"];
    [_locationsThread start];
}

- (void)stopEmulator
{
    if (_locationsThread)
    {
        [_locationsThread cancel];
        _locationsThread = nil;
    }
    
    self.isSimulating = NO;
}

#pragma mark - Mehtods

- (void)deleteCoordinates
{
    if (_oriCoordinates != NULL)
    {
        free(_oriCoordinates);
        _oriCoordinates = NULL;
        _count = 0;
    }
}

#pragma mark - Thread Entry Method

- (void)locationThreadEntryMethod
{
    double currentIndex = 0;
    double redundantDistance = 0;
    
    while (currentIndex < _count-1 && _locationsThread && ![_locationsThread isCancelled])
    {
        // save a copy of 'distancePerStep' and 'speed'
        [self.lock lock];
        double tempDistancePerStep = self.distancePerStep;
        double tempSpeed = self.speed;
        [self.lock unlock];
        
        // generate properties for CLLocation
        unsigned long nextIndex = currentIndex;
        CLLocationCoordinate2D resultCoordinate = [self findCoordinateFromIndex:currentIndex
                                                                  afterDistance:(tempDistancePerStep + redundantDistance)
                                                              resultLocateIndex:&nextIndex
                                                        resultRedundantDistance:&redundantDistance];
        
        double course = angleBetweenCoordinates(*(_oriCoordinates + nextIndex), resultCoordinate);
        double speed = tempSpeed;
        
        // save 'nextIndex'
        currentIndex = nextIndex;
        
        // sleep for 'self.timeInverval'
        [NSThread sleepForTimeInterval:self.timeInverval];
        
        // notify delegate location update
        if (self.delegate)
        {
            CLLocation *newLocation = [[CLLocation alloc] initWithCoordinate:resultCoordinate
                                                                    altitude:30.f
                                                          horizontalAccuracy:10.f
                                                            verticalAccuracy:10.f
                                                                      course:course
                                                                       speed:speed
                                                                   timestamp:[NSDate date]];
            
            [self.delegate gpsEmulatorUpdateLocation:newLocation];
        }
    }
    
    self.isSimulating = NO;
}

- (CLLocationCoordinate2D)findCoordinateFromIndex:(unsigned long)startIndex
                                    afterDistance:(double)distance
                                resultLocateIndex:(unsigned long *)locateIndex
                          resultRedundantDistance:(double *)redundantDistance
{
    startIndex = MAX(0, startIndex);
    double totalDistance = distance;
    
    // if 'totalDistance <= 0', return coordinate at 'startIndex' directly
    if (totalDistance <= 0)
    {
        *locateIndex = startIndex;
        *redundantDistance = 0.f;
        
        CLLocationCoordinate2D reVal = *(_oriCoordinates + startIndex);
        return CLLocationCoordinate2DMake(reVal.latitude, reVal.longitude);
    }
    
    CLLocationCoordinate2D resultCoordiante = *(_oriCoordinates + startIndex);
    double resultDistance = 0;
    
    unsigned long i = startIndex;
    for (; i < _count-1; i++)
    {
        double dis = distanceBetweenCoordinates(*(_oriCoordinates + i), *(_oriCoordinates + i + 1));
        if (totalDistance <= dis)
        {
            resultDistance = totalDistance;
            resultCoordiante = coordinateAtRateOfCoordinates(*(_oriCoordinates + i), *(_oriCoordinates + i + 1), (totalDistance / dis));
            break;
        }
        else
        {
            totalDistance -= dis;
        }
    }
    
    if (i >= _count-1)
    {
        // reach the end of coordiante list, return the last coordiante
        *locateIndex = _count-1;
        *redundantDistance = 0.f;
        
        CLLocationCoordinate2D reVal = *(_oriCoordinates + _count - 1);
        return CLLocationCoordinate2DMake(reVal.latitude, reVal.longitude);
    }
    else
    {
        // destination coordiante locate between 'i' and 'i+1', return the new coordiante named 'resultCoordiante'
        *locateIndex = i;
        *redundantDistance = resultDistance;
        
        return resultCoordiante;
    }
}

@end
