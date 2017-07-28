//
//  GPSSimulatorEngine.h
//  Pods
//
//  Created by wang.fu on 2017/2/24.
//
//

#ifdef NMONLINEGPSSIMULATOR
#import <Foundation/Foundation.h>

// 获取模拟GPS的时间间隔。用于计算location的速度
#define GPSSIMULATOR_OFFLINE_TIMEINTERVAL 0.25f

FOUNDATION_EXTERN void GCJtoWGS(double chnlat, double chnlon, double *wgslat, double *wgslon);
FOUNDATION_EXTERN void G20toWGS(int chnx, int chny, double *wgslat, double *wgslon);

@class CLLocation;
@interface GPSSimulatorNode : NSObject

@property (nonatomic, assign) ANPoint g20Location;

@property (nonatomic, weak) GPSSimulatorNode *preNode;

@property (nonatomic, weak) GPSSimulatorNode *nextNode;

- (instancetype)initWithPoint:(ANPoint)point nextNode:(GPSSimulatorNode *)nextNode preNode:(GPSSimulatorNode *)preNode;

- (CGFloat)distanceToNextNode;

- (CLLocation *)curLocation;

- (GPSSimulatorNode *)nextNodeWithDistance:(CGFloat)distance;

@end


@interface GPSSimulatorEngine : NSObject

+ (instancetype)engine;

- (BOOL)fillG20Locations:(NSArray *)g20Locations;

- (GPSSimulatorNode *)nextNodeWithSpeed:(CGFloat)speed;

- (GPSSimulatorNode *)fetchNextNodeWithSpeed:(CGFloat)speed;

- (void)reset;

- (BOOL)checkData;

@end
#endif
