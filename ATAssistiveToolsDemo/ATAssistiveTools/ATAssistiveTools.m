//
//  ATAssistiveTools.m
//  ATAssistiveTools
//
//  Created by liubo on 2017/5/26.
//  Copyright © 2017年 devliubo. All rights reserved.
//

#import "ATAssistiveTools.h"
#import "ATContainerWindow.h"
#import "ATRootViewController.h"

// Custom Views
#import "ATDeviceLogsView.h"
#import "ATFakeLocationView.h"
#import "ATSandboxViewerView.h"
#import "ATGPSEmulatorView.h"

@interface ATAssistiveTools ()<ATContainerWindowDelegate,ATRootViewControllerDelegate>

@property (nonatomic, strong) ATContainerWindow *assistiveWindow;
@property (nonatomic, strong) ATRootViewController *rootViewController;

@end

@implementation ATAssistiveTools

#pragma mark - Private: Life Cycle

+ (instancetype)sharedInstance
{
    static ATAssistiveTools *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ATAssistiveTools alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    if (self = [super init])
    {
        [self createAssistiveTools];
    }
    return self;
}

- (void)createAssistiveTools
{
    [self initProperties];
    
    [self initAssisticeWindowAndController];
}

#pragma mark - Private: Initialization

- (void)initProperties
{
    
}

- (void)initAssisticeWindowAndController
{
    // ATRootViewController
    _rootViewController = [[ATRootViewController alloc] init];
    _rootViewController.delegate = self;
    _rootViewController.autorotateEnabled = YES;
    
    // ATContainerWindow
    _assistiveWindow = [[ATContainerWindow alloc] initWithFrame:_rootViewController.shrinkedWindowFrame];
    _assistiveWindow.containerDelegate = self;
    _assistiveWindow.windowLevel = CGFLOAT_MAX;
    _assistiveWindow.layer.masksToBounds = YES;
    _assistiveWindow.backgroundColor = [UIColor clearColor];
    
    self.rootViewController.assistiveWindow = self.assistiveWindow;
    self.assistiveWindow.rootViewController = self.rootViewController;
}

#pragma mark - Private: Load Custom View

- (void)loadCustomViews
{
    ATFakeLocationView *simLocView = [[ATFakeLocationView alloc] init];
    [self addCustomView:simLocView forTitle:@"FakeLocation"];
    
    ATSandboxViewerView *sandboxView = [[ATSandboxViewerView alloc] init];
    [self addCustomView:sandboxView forTitle:@"SandboxViewer"];
    
    ATGPSEmulatorView *gpsSimView = [[ATGPSEmulatorView alloc] init];
    [self addCustomView:gpsSimView forTitle:@"GPSSimlulator"];
    
    ATDeviceLogsView *logsView = [[ATDeviceLogsView alloc] init];
    [self addCustomView:logsView forTitle:@"DeviceLog"];
}

#pragma mark - Public: Interface

- (void)show
{
    [self makeWindowVisible:self.assistiveWindow];
    
    [self loadCustomViews];
}

- (void)makeWindowVisible:(UIWindow *)window
{
    UIWindow *currentKeyWindow = [[UIApplication sharedApplication] keyWindow];
    if (currentKeyWindow == window)
    {
        [currentKeyWindow makeKeyAndVisible];
    }
    else
    {
        [window makeKeyAndVisible];
        [currentKeyWindow makeKeyWindow];
    }
}

- (UIWindow *)mainWindow
{
    return self.assistiveWindow;
}

- (NSArray<NSString *> *)currentTitles
{
    return self.rootViewController.currentTitles;
}

- (void)addCustomView:(UIView<ATCustomViewProtocol> *)aView forTitle:(NSString *)aTitle
{
    [self.rootViewController addCustomView:aView forTitle:aTitle];
}

- (void)removeCustiomViewForTitle:(NSString *)aTitle
{
    [self.rootViewController removeCustiomViewForTitle:aTitle];
}

- (void)removeAllCustomViews
{
    [self.rootViewController removeAllCustomViews];
}

#pragma mark - Private: ATContainerWindowDelegate

//- (BOOL)customPointInside:(CGPoint)point withEvent:(UIEvent *)event
//{
//    BOOL inShrink = [self.shrinkInfoView pointInside:[self.assistiveWindow convertPoint:point toView:self.shrinkInfoView] withEvent:event];
//    BOOL inExpand = [self.expandInfoView pointInside:[self.assistiveWindow convertPoint:point toView:self.expandInfoView] withEvent:event];
//    
//    BOOL inside = inShrink || inExpand;
//    return inside;
//}

@end
