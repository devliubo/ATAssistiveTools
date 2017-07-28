//
//  ATGPSEmulatorView.m
//  ATAssistiveTools
//
//  Created by liubo on 2017/7/27.
//  Copyright © 2017年 devliubo. All rights reserved.
//

#import "ATGPSEmulatorView.h"

#pragma mark - ATGPSEmulatorView

@interface ATGPSEmulatorView ()

@property (nonatomic, weak) AMapNaviBaseManager *naviManager;

@property (nonatomic, strong) NSThread *simlulatorThread;

@end

@implementation ATGPSEmulatorView

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self buildGPSSimulatorLocationView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self buildGPSSimulatorLocationView];
    }
    return self;
}

- (void)buildGPSSimulatorLocationView
{
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self initProperties];
    
    [self initSubviews];
}

- (void)initProperties
{
    
}

- (void)initSubviews
{
    
}

#pragma mark - ATCustomViewProtocol

- (void)customViewWillAppear
{
    NSLog(@"customViewWillAppear");
}

- (void)customViewDidAppear
{
    NSLog(@"customViewDidAppear");
}

- (void)customViewWillDisappear
{
    NSLog(@"customViewWillDisappear");
}

- (void)customViewDidDisappear
{
    NSLog(@"customViewDidDisappear");
}

- (void)customViewWillShrink
{
    NSLog(@"customViewWillShrink");
}

- (void)customViewDidShrink
{
    NSLog(@"customViewDidShrink");
}

- (void)customViewWillExpand
{
    NSLog(@"customViewWillExpand");
}

- (void)customViewDidExpand
{
    NSLog(@"customViewDidExpand");
}

#pragma mark - Button Action

#pragma mark - Interface

- (void)setNaviManager:(AMapNaviBaseManager *)naviManager
{
    if (naviManager)
    {
        self.naviManager = naviManager;
    }
    else
    {
        [self stopSimlulator];
    }
}

- (void)loadRouteData
{
    
}

- (void)startSimlulator
{
    
}

- (void)stopSimlulator
{
    
}

@end
