//
//  OnlineGPSSimulator.h
//  AMapiPhone
//
//  Created by wang.fu on 14-7-29.
//
//  和在线工具结合模拟GPS数据
//  打开ONLINEGPSSIMULATOR宏
//  调用-fire 即可实现模拟GPS替换真实GPS。
//  调用-fireGetGPS:或者 设置代理实现代理方法 都可以获得模拟GPS。
//  控制端网址：http://10.19.1.124/WalkDemo/html/busnavi.html
//  调用－pause暂停。
//  调用＋releaseManager释放。


#ifdef NMONLINEGPSSIMULATOR
#import <Foundation/Foundation.h>
//#import "AMLocationService.h"
#import "GPSSimulatorEngine.h"

#define NM_NOTIFICATION_GPSSIMULATORMODE_DID_CHANGE @"NM_NOTIFICATION_GPSSIMULATORMODE_DID_CHANGE"



@class CLLocation, NMGPSSimulatorIcon;

typedef void (^OnlineGPSBlock)(CLLocation *newLocation);
typedef void (^SGDowloadFinished)(NSData* fileData);
typedef void (^SGDownloadFailBlock)(NSError*error);
typedef NS_ENUM(NSInteger, GPSSimulatorMode) {
    GPSSimulatorModeNone = 1001,
    GPSSimulatorModeOnline,
    GPSSimulatorModeOffline,
};

@protocol OnlineGPSSimulatorDelegate <NSObject>
@optional
- (void)onlineGPSUpdateToLocation:(CLLocation *)newLocation;

@end
@interface OnlineGPSSimulator : NSObject
{
    NSString    *_UID;
    double      _timeInterval;
}
@property (nonatomic, strong) NMGPSSimulatorIcon *simulatorView;
@property (nonatomic, copy) NSString                            *UID;
@property (nonatomic, assign) double                            timeInterval;
@property (nonatomic, assign) GPSSimulatorMode                  currentMode;
@property (nonatomic, assign) BOOL isPause;


+ (OnlineGPSSimulator *)shareManager;
+ (void)releaseManager;

- (void)addDelegate:(id<OnlineGPSSimulatorDelegate>)delegate;
- (void)removeDelegate:(id<OnlineGPSSimulatorDelegate>)delegate;
- (void)removeAllDelegate;
- (void)setOnlineGPSBlock:(OnlineGPSBlock)onlineGPSBlock;

- (void)fireWithMode:(GPSSimulatorMode)mode completionHandle:(void (^)(BOOL success, NSString *errorInfo))completionHandle;

#pragma mark - online
- (void)setUID:(NSString *)UID timeInterval:(double )interval;

#pragma mark - offline
// 加载路线数据
- (void)loadPath;
// 回到路线起点
- (void)reset;

@property (nonatomic, assign) CGFloat speed;

@end

@interface AMLocationService (AMLocationServiceExtention)
- (void)startSim;
@end

#endif
