//
//  OnlineGPSSimulator.m
//  AMapiPhone
//
//  Created by wang.fu on 14-7-29.
//
//

#import "OnlineGPSSimulator.h"
#ifdef NMONLINEGPSSIMULATOR

#import <CoreLocation/CoreLocation.h>

#import <objc/runtime.h>

#define ONLINETESTREQUEST @"OnlineGPSSimulatorServer"

#define SIMULATE_DISTANCE   (5)

@interface NSURLConnection (Additon)
+ (void)sendAsynchronousRequestStr:(NSString *)urlString
                             queue:(NSOperationQueue*) queue
                 completionHandler:(void (^)(NSURLResponse* nmResponse, NSData* nmData, NSError* nmError)) handler NS_AVAILABLE(10_7, 5_0);

@end

@implementation NSURLConnection (Additon)
+ (void)sendAsynchronousRequestStr:(NSString *)urlString
                             queue:(NSOperationQueue*) queue
                 completionHandler:(void (^)(NSURLResponse* nmResponse, NSData* nmData, NSError* nmError)) handler
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:handler];
}
@end

@interface OnlineGPSSimulator ()
{
    NSTimer             *_onlineTestTimer;
    NSMutableArray		*_delegatesArray;
}

@property (nonatomic, copy) OnlineGPSBlock onlineGPSBlock;
@property (nonatomic, strong) NSTimer *simulatorTimer;

@end

@implementation AMLocationService (AMLocationServiceExtention)

- (void)startSim
{
    if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        if ([AMLocationService isUserLocationNotDetermined]) {
            [_locationManager requestAlwaysAuthorization];
        }
    }
    
    _locationManager.delegate = (id<CLLocationManagerDelegate>)[OnlineGPSSimulator shareManager];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9) {
        _locationManager.allowsBackgroundLocationUpdates = YES;
    }
    
    _running = YES;
    
    [_locationManager startUpdatingLocation];
    [_locationManager startUpdatingHeading];
    
    NMLogGPS(@"OnlineGPSSimulator startSim");
}

- (void)startWithCallbackSim
{
    if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        if ([AMLocationService isUserLocationNotDetermined]) {
            [_locationManager requestAlwaysAuthorization];
        }
    }
    
    _running = YES;
    _locationManager.delegate = (id<CLLocationManagerDelegate>)[OnlineGPSSimulator shareManager];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9) {
        _locationManager.allowsBackgroundLocationUpdates = YES;
    }
    [_locationManager startUpdatingLocation];
    [_locationManager startUpdatingHeading];
    NMLogGPS(@"OnlineGPSSimulator startWithCallbackSim");
}

@end

@implementation OnlineGPSSimulator {
    NSMutableArray *_locationPointsArr;
}
static OnlineGPSSimulator *s_OnlineGPSSimulator = nil;
static dispatch_once_t GPSOnceToken;

+ (OnlineGPSSimulator *)shareManager
{
    dispatch_once(&GPSOnceToken, ^{
        if (s_OnlineGPSSimulator == nil) {
            s_OnlineGPSSimulator = (OnlineGPSSimulator *) [[super allocWithZone:NULL] init];
        }
    });
    return s_OnlineGPSSimulator;
}


+ (instancetype) allocWithZone:(struct _NSZone *)zone
{
    @synchronized(self) {
        if (nil == s_OnlineGPSSimulator) {
            s_OnlineGPSSimulator = (OnlineGPSSimulator *) [super allocWithZone:zone];
        }
        return s_OnlineGPSSimulator;
    }
}


-(instancetype)init
{
    if (self = [super init]) {
        self.UID = nil;
        self.timeInterval = 1.0f;
        _delegatesArray = [[NSMutableArray alloc] initWithCapacity:0];
        _currentMode = GPSSimulatorModeNone;
        _speed = 30.f;
    }
    return self;
}


- (instancetype) copyWithZone:(NSZone*)zone
{
    return self;
}

//- (id) retain
//{
//    if (!self) {
//        [OnlineGPSSimulator shareManager];
//    }
//    return self;
//}
//- (oneway void) release
//{
//    
//}
//- (instancetype) autorelease
//{
//    return self;
//}

//- (unsigned) retainCount
//{
//    return UINT_MAX;
//}

- (void)releaseSelf
{
}

+ (void)releaseManager
{
    if (s_OnlineGPSSimulator) {
        [s_OnlineGPSSimulator releaseSelf];
        s_OnlineGPSSimulator = nil;
        GPSOnceToken = 0;
    }
}


- (void)dealloc
{
    if (_onlineTestTimer) {
        [_onlineTestTimer invalidate];
        _onlineTestTimer = nil;
    }
    
    if (_simulatorTimer) {
        [_simulatorTimer invalidate];
        _simulatorTimer = nil;
    }
    
    _onlineGPSBlock = nil;
    
    _delegatesArray = nil;
    _currentMode = GPSSimulatorModeNone;
}

- (void)addDelegate:(id<OnlineGPSSimulatorDelegate>)delegate {
	if(![_delegatesArray containsObject:delegate])
		[_delegatesArray addObject:delegate];
}

- (void)removeDelegate:(id<OnlineGPSSimulatorDelegate>)delegate {
	if([_delegatesArray containsObject:delegate])
		[_delegatesArray removeObject:delegate];
}

- (void)removeAllDelegate {
	[_delegatesArray removeAllObjects];
}

- (void)fireWithMode:(GPSSimulatorMode)mode completionHandle:(void (^)(BOOL success, NSString *errorInfo))completionHandle
{
    if (_currentMode == mode) {
        if (completionHandle) {
            completionHandle(YES, nil);
        }
        return;
    }
    
    GPSSimulatorMode oriMode = _currentMode;
    // stop ori
    if (_currentMode != GPSSimulatorModeNone) { // 已经开启过
        if (_currentMode == GPSSimulatorModeOffline) {
            if (self.simulatorTimer) {
                [self.simulatorTimer invalidate];
                self.simulatorTimer = nil;
            }
        } else if (_currentMode == GPSSimulatorModeOnline) {
            if (_onlineTestTimer) {
                [_onlineTestTimer invalidate];
                _onlineTestTimer = nil;
            }
        }
    }
    
    
    __weak typeof(self) weakSelf = self;
    void (^tmpCompletionHandler)(BOOL success, NSString *errorInfo) = ^(BOOL success, NSString *errorInfo) {
        // 根据最终状态，判断是否需要换方法
        if ((oriMode == GPSSimulatorModeNone) ^ (weakSelf.currentMode == GPSSimulatorModeNone)) {// 一个是none，一个不是none，则需要替换
            [weakSelf swizzleLocationMethods];
        }
        
        if (weakSelf.currentMode == GPSSimulatorModeNone) {
            weakSelf.isPause = YES;
        } else {
            weakSelf.isPause = NO;
        }
        
        if (completionHandle) {
            completionHandle(success, errorInfo);
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NM_NOTIFICATION_GPSSIMULATORMODE_DID_CHANGE object:nil];
    };
    
    _currentMode = GPSSimulatorModeNone;
    if (mode == GPSSimulatorModeOnline) {
        [self fireOnlineWithCompletionHandle:tmpCompletionHandler];
    } else if (mode == GPSSimulatorModeOffline) {
        [self fireOfflineWithCompletionHandle:tmpCompletionHandler];
    } else { // 停止
        tmpCompletionHandler(YES, nil);
    }
}

- (void)fireOnlineWithCompletionHandle:(void (^)(BOOL success, NSString *errorInfo))completionHandle
{
    if (![self checkUID]) {
        if (completionHandle) {
            completionHandle(NO, @"请随意设置UID!");
        }
        return;
    }
    
    _currentMode = GPSSimulatorModeOnline;
    
    _onlineTestTimer = [NSTimer scheduledTimerWithTimeInterval:_timeInterval target:self selector:@selector(onlineTestRequest) userInfo:nil repeats:YES];
    if (completionHandle) {
        completionHandle(YES, nil);
    }
}

- (void)fireOfflineWithCompletionHandle:(void (^)(BOOL success, NSString *errorInfo))completionHandle
{
    if (![[GPSSimulatorEngine engine] checkData]) {
        if (completionHandle) {
            completionHandle(NO, @"请先载入路线数据！");
        }
        return;
    }
    
    _currentMode = GPSSimulatorModeOffline;
    
    self.simulatorTimer = [NSTimer scheduledTimerWithTimeInterval:GPSSIMULATOR_OFFLINE_TIMEINTERVAL target:self selector:@selector(runSimulatePoints) userInfo:nil repeats:YES];
    if (completionHandle) {
        completionHandle(YES, nil);
    }
}

- (void)setIsPause:(BOOL)isPause
{
    if (_currentMode == GPSSimulatorModeNone) {
        return;
    }
    
    if (_isPause != isPause) {
        _isPause = isPause;
    }
}

#pragma mark - MethodSwizzle
- (void)swizzleLocationMethods
{
    Method m1 = class_getInstanceMethod([AMLocationService class], @selector(start));
    Method m2 = class_getInstanceMethod([AMLocationService class], @selector(startSim));
    method_exchangeImplementations(m1, m2);
    
    Method m3 = class_getInstanceMethod([AMLocationService class], @selector(startWithCallback));
    Method m4 = class_getInstanceMethod([AMLocationService class], @selector(startWithCallbackSim));
    method_exchangeImplementations(m3, m4);
    
    [[AMLocationService service] stop];
    [[AMLocationService service] start];
    NMLogGPS(@"OnlineGPSSimulator swizzle StopAndReStart");
}

- (void)sendLocation:(CLLocation *)location {
    //直接替换APP坐标
    NSArray *locationsArr = @[location];
    [[AMLocationService service] locationManager:[AMLocationService service].posLocationManager didUpdateLocations:locationsArr];
    //代理方式回调
    NSArray *delegateArray = [[NSArray alloc] initWithArray:_delegatesArray];
    for(id delegate in delegateArray) {
        if (delegate && [delegate respondsToSelector:@selector(onlineGPSUpdateToLocation:)]) {
            [delegate onlineGPSUpdateToLocation:location];
        }
    }
    
    //block方式回调
    if (_onlineGPSBlock) {
        _onlineGPSBlock(location);
    }
}

#pragma mark - online
- (void)setUID:(NSString *)UID timeInterval:(double )interval
{
    if (UID.length) {
        self.UID = UID;
        self.timeInterval = interval;
    }
}

- (BOOL)checkUID
{
    if (self.UID.length < 1) {
        [AMCommonFunctions errorAlert:@"提醒" message:@"请随意设置UID！"];
        
        return NO;
    }
    return YES;
}

- (CLLocation *)getLocationFromRequestResult:(NSDictionary *)resultDic {
    //            NSTimeInterval timeInterval = [[resultDic objectForKey:@"timestamp"] doubleValue];
    NSDate *time = [NSDate date];
    NSDictionary *locationDic = resultDic[@"coords"];
    double x;
    double y;
    
    double latitude = [locationDic[@"latitude"] doubleValue];
    double longitude = [locationDic[@"longitude"] doubleValue];
    NSString *adCode = [NMCodeTransformUtility getAdcodeFromLongitude:longitude Latitude:latitude];
    NSInteger nAdCode = [adCode integerValue];
    if (nAdCode != 710000) {//ADCODE_TAIWAN       (710000)
        GCJtoWGS(latitude, longitude, &x, &y);
    }
    else {
        x = latitude;
        y = longitude;
    }

    CLLocationCoordinate2D loc = CLLocationCoordinate2DMake(x, y);
    
    //            CLLocationCoordinate2D loc = CLLocationCoordinate2DMake([[locationDic objectForKey:@"latitude"] doubleValue], [[locationDic objectForKey:@"longitude"] doubleValue]);
    double heading = [locationDic[@"heading"] doubleValue];
    if (heading < 0) {
        heading = 360 + heading;
    }
    CLLocation *newLocation = [[CLLocation alloc]initWithCoordinate:loc
                                                           altitude:kCLDistanceFilterNone
                                                 horizontalAccuracy:[locationDic[@"accuracy"] doubleValue]
                                                   verticalAccuracy:kCLLocationAccuracyBest
                                                             course:heading
                                                              speed:[locationDic[@"speed"] doubleValue]
                                                          timestamp:time];
    return newLocation;
}

- (void)onlineTestRequest
{
    if (_currentMode != GPSSimulatorModeOnline) {
        return;
    }
    
    if (self.isPause) {
        return;
    }
    
    NSString *requestStr = ONLINEGPSSIMULATORSERVER;
    if (requestStr.length) {
        requestStr = [requestStr stringByAppendingString:_UID];
        [NSURLConnection sendAsynchronousRequestStr:requestStr queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *nmResponse, NSData *nmData, NSError *nmError) {
            if (nmError) {
                NSLog(@"wangfu:HTTP ERROR:%@ %d",nmError.localizedDescription ,(int)nmError.code);
            } else {
                NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:nmData options:NSJSONReadingMutableContainers error:nil];
                
                CLLocation *newLocation = [self getLocationFromRequestResult:resultDic];
                
                [self sendLocation:newLocation];
            }
        }];
    }
}

#pragma mark - offline
- (void)loadPath
{
    if ([[GPSSimulatorEngine engine] fillG20Locations:[self getLocationPoints]]) {
        __weak typeof(self) weakSelf = self;
        // 阻止连续加载
        if (OS_VERSION_8_LATER) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"载入成功，是否开启离线模拟GPS！" message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf fireWithMode:GPSSimulatorModeNone completionHandle:nil];
            }]];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"开始" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf fireWithMode:GPSSimulatorModeOffline completionHandle:nil];
            }]];
            
            [[[AMViewsNavigation shareViewsNavigation] topViewController] presentViewController:alert animated:YES completion:nil];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"载入成功，是否开启离线模拟GPS！" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"开始", nil];
            [alertView show];
        }
        
        
        
//        [LTMCommonAlertView showWithTitle:@"载入成功，是否开启离线模拟GPS！" message:nil btnTitles:@[@"取消", @"开始"] btnTypes:@[@(NMCABtnPositive), @(NMCABtnPositive)] onButtonClick:^(LTMCommonAlertView *alertView, NSInteger buttonIndex) {
//            if (buttonIndex == 1) {// start
//                [weakSelf fireWithMode:GPSSimulatorModeOffline completionHandle:nil];
//            } else {// cancel
//                if (self.currentMode == GPSSimulatorModeOffline) {
//                    [weakSelf fireWithMode:GPSSimulatorModeNone completionHandle:nil];
//                }
//            }
//        }];
    } else {
        [AMCommonFunctions errorAlert:@"加载失败，请规划路线或开始导航！"];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {// start
        [self fireWithMode:GPSSimulatorModeOffline completionHandle:nil];
    } else {// cancel
        if (self.currentMode == GPSSimulatorModeOffline) {
            [self fireWithMode:GPSSimulatorModeNone completionHandle:nil];
        }
    }
}


- (void)reset
{
    if (self.currentMode != GPSSimulatorModeOffline) {
        [AMCommonFunctions errorAlert:@"提醒" message:@"未开启离线模拟GPS，无法重置！"];
        return ;
    }
    
    [[GPSSimulatorEngine engine] reset];
    
    if (self.simulatorTimer) {
        [self.simulatorTimer invalidate];
        self.simulatorTimer = nil;
    }
    
    self.simulatorTimer = [NSTimer scheduledTimerWithTimeInterval:GPSSIMULATOR_OFFLINE_TIMEINTERVAL target:self selector:@selector(runSimulatePoints) userInfo:nil repeats:YES];
}

- (void)runSimulatePoints {
    if (_currentMode != GPSSimulatorModeOffline) {
        return;
    }
    
    if (self.isPause) {
        return;
    }
    
    GPSSimulatorNode *nextNode = [[GPSSimulatorEngine engine] fetchNextNodeWithSpeed:self.speed];
    if (nextNode) {
        if ([[AMLocationService service] running]) {
            
        }
        //生成坐标
        [self sendLocation:[nextNode curLocation]];
    } else {
        if (self.simulatorTimer) {
            [self.simulatorTimer invalidate];
            self.simulatorTimer = nil;
        }
        
        __weak typeof(self) weakSelf = self;
        [LTMCommonAlertView showWithTitle:@"离线模拟GPS完成，是否停止模拟" message:nil btnTitles:@[@"取消", @"停止"] btnTypes:@[@(NMCABtnPositive), @(NMCABtnPositive)] onButtonClick:^(LTMCommonAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [weakSelf fireWithMode:GPSSimulatorModeNone completionHandle:nil];
            }
        }];
    }
}

- (NSArray *)getLocationPoints {
    AMBasicViewController *naviVC = [[AMViewsNavigation shareViewsNavigation] getViewControllerByID:VIEW_NAVI_MAIN];
    if ([naviVC isKindOfClass:NSClassFromString(@"NMNaviViewController")]) {
        return [self getLocationPointsFromNavi];
    } else {// 获取pathManager数据
        return [self getLocationPointsFromPath];
    }
    return nil;
}

- (NSArray *)getLocationPointsFromNavi
{
    id<NMNaviService> naviService = [[NMServiceCenter shareCenter] getProviderByService:@protocol(NMNaviService)];
    if (![naviService isNaviStarting]) {
        return nil;
    }
    
    NSArray *naviOverlayLineArr = [naviService getLocationCodeArray:YES singleColor:YES];
    naviOverlayLineArr = [self clearOverlayInfo:naviOverlayLineArr];
    //生成的点
    return naviOverlayLineArr;
}

- (NSArray *)getLocationPointsFromPath
{
    id<NMPathService> pathService = [[NMServiceCenter shareCenter] getProviderByService:@protocol(NMPathService)];
    if ([pathService getSearchPathType] == NMPATH_TYPE_CAR) {
        NMCarPathDataCenter *carPathDataCenter = (NMCarPathDataCenter *)[pathService curDataCenter];
        MPSCarRouteData *carRouteData = [carPathDataCenter getCurrentCarRouteData];
        return [self getPointsWithCarRouteData:carRouteData];
    }
    return nil;
}

//- (NSMutableArray *)separateLocationPoints:(NSArray *)locationPoints minDistance:(CGFloat)minDistance
//{
//    //生成的点
//    NSMutableArray *pointArr = [NSMutableArray array];
//    typeof(self) __weak weakSelf = self;
//    [locationPoints enumerateObjectsUsingBlock:^(NSValue *obj, NSUInteger idx, BOOL *stop) {
//        if (idx + 1 == locationPoints.count) {
//            *stop = YES;
//        } else {
//            ANPoint point1 = [obj ANPointValue];
//            ANPoint point2 = [(NSValue *)locationPoints[idx+1] ANPointValue];
//            [pointArr addObjectsFromArray:[weakSelf insertPointForPoint1:point1 point2:point2 dis:minDistance]];
//        }
//        
//    }];
//    return pointArr;
//}

- (NSArray *)getPointsWithCarRouteData:(MPSCarRouteData *)carRouteData
{
    NSMutableArray *result = [NSMutableArray array];
    for (MPSCarRouteSegmentData *segmentData in carRouteData.segmentList) {
        for (MPSPoint *point in segmentData.segmentLine.drawPoints) {
            [result addObject:[NSValue valueWithANPoint:point.G20Location]];
        }
    }
    return result;
}

//- (CLLocation *)translateG20toLocation:(ANPoint)point nextPoint:(ANPoint)nextPoint {
//    double lat;
//    double lon;
//    G20toWGS(point.x, point.y, &lat, &lon);
//
//    double heading = -1;
//    if (!ANPointEqualToPoint(nextPoint, ANPointZero)) {
//        heading = [self headingFromANPoint1:point toANPoint2:nextPoint];
//    }
//    double speed = SIMULATE_DISTANCE / SIMULATE_INTERVAL;
//    CLLocation *newLocation = [[CLLocation alloc]initWithCoordinate:CLLocationCoordinate2DMake(lat, lon)
//                                                           altitude:10.0
//                                                 horizontalAccuracy:5.
//                                                   verticalAccuracy:5.
//                                                             course:heading
//                                                              speed:speed
//                                                          timestamp:[NSDate date]];
//    return newLocation;
//}


- (NSMutableArray *)clearOverlayInfo:(NSArray *)overlayLineArr
{
    NSMutableArray *linePointArr = [NSMutableArray arrayWithCapacity:overlayLineArr.count];
    [overlayLineArr enumerateObjectsUsingBlock:^(NSArray *  _Nonnull itemArr, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableArray *pointArr = [NSMutableArray arrayWithArray:itemArr];
        if (pointArr.count) {
            [pointArr removeLastObject];
        }

        [linePointArr addObjectsFromArray:pointArr];
    }];
    return linePointArr;
}

//- (NSArray *)insertPointForPoint1:(ANPoint)point1 point2:(ANPoint)point2 dis:(CGFloat)dis
//{
//    CGFloat pointDis = [ANCoordConvert distanceFromPoint:point1 toPoint:point2];
//    if (pointDis == 0) {
//        return @[[NSValue valueWithANPoint:point1]];
//    }
//    if (pointDis < dis) {
//        NSMutableArray  *points = [NSMutableArray arrayWithCapacity:1];
//        [points addObject:[NSValue valueWithANPoint:point2]];
//        return points;
//    } else {
//        ANPoint pt = ANPointMake((point1.x + point2.x) / 2,(point1.y + point2.y) / 2);
//        NSArray *re1 = [self insertPointForPoint1:point1 point2:pt dis:dis];
//        NSArray *re2 = [self insertPointForPoint1:pt point2:point2 dis:dis];
//        return [[NSMutableArray arrayWithArray:re1] arrayByAddingObjectsFromArray:re2];
//    }
//}

//- (CLLocationDirection)headingFromANPoint1:(ANPoint)point1 toANPoint2:(ANPoint)point2 {
//    double dx = point2.x - point1.x;
//    double dy = -(point2.y - point1.y);
//    double angle = 0;
//    if (fabs(dx) < 1 && fabs(dy) < 1) {
//        angle = -1;
//    } else {
//        //坐标逆时针旋转90度 使atan2的初始值为y轴
//        double f = atan2(dx,dy) * 180/M_PI;
//        if (dx < 0) {
//            angle = 360 + f;
//        } else {
//            angle = f;
//        }
//    }
//    return angle;
//}
//
//- (CLLocationDirection)headingFromPoint1:(CLLocationCoordinate2D)point1 toPoint2:(CLLocationCoordinate2D)point2 {
//    double dx = point2.longitude - point1.longitude;
//    double dy = point2.latitude - point1.latitude;
//    double angle = 0;
//    if (fabs(dx) < 0.000001 && fabs(dy) < 0.000001) {
//        angle = -1;
//    } else {
//        //坐标逆时针旋转90度 使atan2的初始值为y轴
//        double f = atan2(dx,dy) * 180/M_PI;
//        if (dx < 0) {
//            angle = 360 - f;
//        } else {
//            angle = f;
//        }
//    }
//    return angle;
//}

@end

#endif
