//
//  GPSSimulatorEngine.m
//  Pods
//
//  Created by wang.fu on 2017/2/24.
//
//

#import "GPSSimulatorEngine.h"
#ifdef NMONLINEGPSSIMULATOR
#import <CoreLocation/CoreLocation.h>
#import "OnlineGPSSimulator.h"

#define GPSSIMULATOR_OFFLINE_DISTANCE_INVALID -1.f
#define GPSSIMULATOR_OFFLINE_DISTANCE_NAN -10.f
void GCJtoWGS(double chnlat, double chnlon, double *wgslat, double *wgslon)
{
    int nLat;
    int nLon;
    double lon;
    double lat;
    ANLonlatTo20Pixel(chnlat, chnlon, &nLat, &nLon);
    AN20PixelToLonlat(nLat, nLon, &lon, &lat);
    *wgslat = chnlat - (lat - chnlat);
    *wgslon = chnlon - (lon - chnlon);
}

void G20toWGS(int chnx, int chny, double *wgslat, double *wgslon)
{
    double lon;
    double lat;
    AN20PixelToLonlat(chnx,chny,&lon,&lat);
    GCJtoWGS(lat,lon,wgslat,wgslon);
}

@interface GPSSimulatorNode()

@property (nonatomic, strong) CLLocation *curLocation;

@property (nonatomic, assign) CGFloat distanceToNextNode;

@end

@implementation GPSSimulatorNode

- (instancetype)initWithPoint:(ANPoint)point nextNode:(GPSSimulatorNode *)nextNode preNode:(GPSSimulatorNode *)preNode
{
    if (self = [super init]) {
        _g20Location = point;
        _nextNode = nextNode;
        _preNode = preNode;
        _preNode.nextNode = self;
        _nextNode.preNode = self;
        _distanceToNextNode = GPSSIMULATOR_OFFLINE_DISTANCE_NAN;
    }
    return self;
}

- (void)dealloc
{
    _curLocation = nil;
}

- (void)reset
{
    _curLocation = nil;
    _distanceToNextNode = GPSSIMULATOR_OFFLINE_DISTANCE_NAN;
}

- (void)setNextNode:(GPSSimulatorNode *)nextNode
{
    if (_nextNode != nextNode) {
        _nextNode = nextNode;
        [self reset];
    }
}

- (void)setPreNode:(GPSSimulatorNode *)preNode
{
    if (_preNode != preNode) {
        _preNode = preNode;
        [self reset];
    }
}

- (CGFloat)distanceToNextNode
{
    if (_distanceToNextNode != GPSSIMULATOR_OFFLINE_DISTANCE_NAN) {
        return _distanceToNextNode;
    }
    
    if (!self.nextNode) {
        _distanceToNextNode = GPSSIMULATOR_OFFLINE_DISTANCE_INVALID;
    } else {
        _distanceToNextNode = [ANCoordConvert distanceFromPoint:self.g20Location toPoint:self.nextNode.g20Location];
    }
    
    return _distanceToNextNode;
}


- (CLLocation *)curLocation
{
    if (!_curLocation) {
        double lat;
        double lon;
        G20toWGS(self.g20Location.x, self.g20Location.y, &lat, &lon);
        CLLocationDirection heading = 0;
        if (self.nextNode) {
            heading = [GPSSimulatorNode headingFromANPoint1:self.g20Location toANPoint2:self.nextNode.g20Location];
        } else if (self.preNode) {
            heading = [GPSSimulatorNode headingFromANPoint1:self.preNode.g20Location toANPoint2:self.g20Location];
        }
        
        _curLocation = [[CLLocation alloc]initWithCoordinate:CLLocationCoordinate2DMake(lat, lon)
                                                               altitude:10.
                                                     horizontalAccuracy:5.
                                                       verticalAccuracy:5.
                                                                 course:heading
                                                                  speed:[[OnlineGPSSimulator shareManager] speed]
                                                              timestamp:[NSDate date]];
    }
    
    return _curLocation;
}

- (GPSSimulatorNode *)nextNodeWithDistance:(CGFloat)distance
{
    if (!self.nextNode) {
        return nil;
    }
    
    CGFloat totalDistance = distance;
    
    GPSSimulatorNode *curNode = self;
    
    while (totalDistance > 0) {
        if (!curNode) {
            return nil;
        }
        
        CGFloat distanceToNextNode = [curNode distanceToNextNode];
        if (distanceToNextNode == GPSSIMULATOR_OFFLINE_DISTANCE_INVALID) {
            return nil;
        }
        
        if (totalDistance >= distanceToNextNode) {
            totalDistance -= distanceToNextNode;
            curNode = curNode.nextNode;
        } else {
            curNode = [GPSSimulatorNode createNodeFromNode:curNode toNode:curNode.nextNode distance:totalDistance];
            totalDistance = 0;
        }
    }
    
    return curNode;
}

#pragma mark - private
// create a node between 'fromNode' and 'toNode' which has 'distance' distance from 'fromNode'
+ (GPSSimulatorNode *)createNodeFromNode:(GPSSimulatorNode  *)fromNode toNode:(GPSSimulatorNode *)toNode distance:(CGFloat)distance
{
    CGFloat totalDistance = [ANCoordConvert distanceFromPoint:fromNode.g20Location toPoint:toNode.g20Location];
    CGFloat percent = distance / totalDistance;
    int x = percent * (toNode.g20Location.x - fromNode.g20Location.x) + fromNode.g20Location.x;
    int y = percent * (toNode.g20Location.y - fromNode.g20Location.y) + fromNode.g20Location.y;
    return [[GPSSimulatorNode alloc] initWithPoint:ANPointMake(x, y) nextNode:toNode preNode:fromNode];
}

+ (CLLocationDirection)headingFromANPoint1:(ANPoint)point1 toANPoint2:(ANPoint)point2 {
    double dx = point2.x - point1.x;
    double dy = -(point2.y - point1.y);
    double angle = 0;
    if (fabs(dx) < 1 && fabs(dy) < 1) {
        angle = -1;
    } else {
        //坐标逆时针旋转90度 使atan2的初始值为y轴
        double f = atan2(dx,dy) * 180/M_PI;
        if (dx < 0) {
            angle = 360 + f;
        } else {
            angle = f;
        }
    }
    return angle;
}

@end



@interface GPSSimulatorEngine()

@property (nonatomic, weak) GPSSimulatorNode *firstNode;

@property (nonatomic, weak) GPSSimulatorNode *curNode;

@property (nonatomic, strong) NSMutableSet *nodesSet;

@property (nonatomic, strong) NSArray *g20Locations;

@end

@implementation GPSSimulatorEngine

+ (instancetype)engine
{
    static GPSSimulatorEngine *engine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        engine = [[GPSSimulatorEngine alloc] init];
    });
    return engine;
}

- (instancetype)init
{
    if (self = [super init]) {
        _nodesSet = [NSMutableSet set];
    }
    return self;
}

- (BOOL)fillG20Locations:(NSArray *)g20Locations
{
    self.g20Locations = g20Locations;
    [self.nodesSet removeAllObjects];
    self.firstNode = nil;
    
    GPSSimulatorNode *lastNode = nil;
    for (NSValue *value in g20Locations) {
        if (!lastNode) {
            lastNode = [[GPSSimulatorNode alloc] initWithPoint:[value ANPointValue] nextNode:nil preNode:nil];
            self.firstNode = lastNode;
        } else {
            lastNode = [[GPSSimulatorNode alloc] initWithPoint:[value ANPointValue] nextNode:nil preNode:lastNode];
        }
        [self.nodesSet addObject:lastNode];
    }
    
    return [self checkData];
}

- (GPSSimulatorNode *)nextNodeWithSpeed:(CGFloat)speed
{
    return [self.curNode nextNodeWithDistance:speed * GPSSIMULATOR_OFFLINE_TIMEINTERVAL];
}

- (GPSSimulatorNode *)fetchNextNodeWithSpeed:(CGFloat)speed
{
    if (!self.curNode) {
        self.curNode = self.firstNode;
    } else {
        GPSSimulatorNode *node = [self nextNodeWithSpeed:speed];
        // 有可能是createNew出来的，需要add到set中，由set管理其生命周期，否则会自己释放。
        if (node) {
            self.curNode = node;
            [self.nodesSet addObject:node];
            
            if (self.curNode.preNode) {// 清除走过的点
                if (!self.curNode.nextNode) {// 若为最后一个点，先根据prenode计算location后，再删除
                    [self.curNode curLocation];
                }
                [self.nodesSet removeObject:self.curNode.preNode];
            }
        } else {
            return nil;
        }
    }
    
    return self.curNode;
}

- (void)reset
{
    // 重新生成node，否则每次都要创建中间node，会越来越多。
    [self fillG20Locations:self.g20Locations];
}

- (BOOL)checkData
{
    if (!self.firstNode) {
        return NO;
    }
    
    return YES;
}
@end
#endif
