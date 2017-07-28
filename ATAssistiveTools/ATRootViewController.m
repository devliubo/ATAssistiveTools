//
//  ATRootViewController.m
//  ATAssistiveTools
//
//  Created by liubo on 2017/5/27.
//  Copyright © 2017年 devliubo. All rights reserved.
//

#import "ATRootViewController.h"
#import "ATShrinkInfoView.h"
#import "ATExpandInfoView.h"

#define kATAnimationDuration    0.2f

typedef NS_ENUM(NSUInteger, ATRootViewControllerStatus) {
    ATRootViewControllerStatusShrink = 1,
    ATRootViewControllerStatusExpand = 2,
};

#pragma mark - ATRootViewController

@interface ATRootViewController ()<UIGestureRecognizerDelegate,ATShrinkInfoViewDelegate,ATExpandInfoViewDelegate>

@property (nonatomic, strong) ATShrinkInfoView *shrinkInfoView;
@property (nonatomic, strong) ATExpandInfoView *expandInfoView;

@property (nonatomic, assign) CGRect curScreenBounds;
@property (nonatomic, assign) CGRect expandedWindowFrame;
@property (nonatomic, assign) CGRect shrinkedWindowFrame;

@property (nonatomic, assign) ATRootViewControllerStatus status;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

@end

@implementation ATRootViewController

#pragma mark - Private: Life Cycle

- (instancetype)init
{
    if (self = [super init])
    {
        [self initProperties];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self initProperties];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        [self initProperties];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.shrinkInfoView.status = ATShrinkInfoViewStatusNone;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self buildRootViewController];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - Private: Initilization

- (void)buildRootViewController
{
    [self initShrinkInfoView];
    
    [self initExpandInfoView];
}

- (void)initProperties
{
    _curScreenBounds = [[UIScreen mainScreen] bounds];
    _expandedWindowFrame = CGRectMake((CGRectGetWidth(_curScreenBounds)-kATExpandViewWidth)/2.0, (CGRectGetHeight(_curScreenBounds)-kATExpandViewHeight)/2.0, kATExpandViewWidth, kATExpandViewHeight);
    _shrinkedWindowFrame = [self normalizdFrameToScreenSide:CGRectMake(0, CGRectGetMidY(_curScreenBounds), kATShrinkViewWidth, kATShrinkViewWidth)];
    
    _status = ATRootViewControllerStatusShrink;
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizerAction:)];
    
    _autorotateEnabled = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChangeAction:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)initShrinkInfoView
{
    _shrinkInfoView = [[ATShrinkInfoView alloc] initWithFrame:CGRectMake(0, 0, kATShrinkViewWidth, kATShrinkViewWidth)];
    _shrinkInfoView.delegate = self;
    _shrinkInfoView.hidden = NO;
    
    [self.shrinkInfoView addGestureRecognizer:self.panGestureRecognizer];
    [self.view addSubview:self.shrinkInfoView];
}

- (void)initExpandInfoView
{
    _expandInfoView = [[ATExpandInfoView alloc] initWithFrame:CGRectMake(0, 0, kATExpandViewWidth, kATExpandViewHeight)];
    _expandInfoView.delegate = self;
    _expandInfoView.hidden = YES;
    
    [self.view addSubview:self.expandInfoView];
}

#pragma mark - Private: Interface Orientations

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return self.autorotateEnabled ? UIInterfaceOrientationMaskAll : UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    return self.autorotateEnabled;
}

- (void)orientationDidChangeAction:(NSNotification *)notification
{
    if (!self.autorotateEnabled)
    {
        return;
    }
    
    CGRect preScreenBounds = self.curScreenBounds;
    CGRect curScreenBounds = [[UIScreen mainScreen] bounds];
    
    double xRate = curScreenBounds.size.width / preScreenBounds.size.width;
    double yRate = curScreenBounds.size.height / preScreenBounds.size.height;
    self.curScreenBounds = curScreenBounds;
    
    // calculate shrinked window frame
    CGRect extendFrame = CGRectInset(self.shrinkedWindowFrame, -kATShrinkViewMargin, -kATShrinkViewMargin);
    
    CGPoint resOrigin = CGPointMake(extendFrame.origin.x * xRate, extendFrame.origin.y * yRate);
    extendFrame.origin.x = resOrigin.x;
    extendFrame.origin.y = resOrigin.y;
    
    CGRect resFrame = CGRectInset(extendFrame, kATShrinkViewMargin, kATShrinkViewMargin);
    self.shrinkedWindowFrame = [self normalizdFrameToScreenSide:resFrame];
    
    // calculate expended window frame
    CGPoint newExpandOrigin = CGPointMake(self.expandedWindowFrame.origin.x * xRate, self.expandedWindowFrame.origin.y * yRate);
    CGRect newExpandFrame = CGRectMake(newExpandOrigin.x, newExpandOrigin.y, self.expandedWindowFrame.size.width, self.expandedWindowFrame.size.height);
    self.expandedWindowFrame = newExpandFrame;
    
    if (self.status == ATRootViewControllerStatusShrink)
    {
        self.assistiveWindow.frame = self.shrinkedWindowFrame;
    }
    else if (self.status == ATRootViewControllerStatusExpand)
    {
        self.assistiveWindow.frame = self.expandedWindowFrame;
    }
    else
    {
        NSLog(@"ATRootViewControllerStatusShrink Error");
    }
}

#pragma mark - Private: Gesture Recognizer Action

- (void)panGestureRecognizerAction:(UIPanGestureRecognizer *)panGesture
{
    if (panGesture.state == UIGestureRecognizerStateBegan)
    {
        // expand assistive window so that shrink info view can move to everywhere
        self.assistiveWindow.frame = [[UIScreen mainScreen] bounds];
        
        // move shrinkInfoView to touchPoint
        CGPoint touchPoint = [panGesture locationInView:self.assistiveWindow];
        self.shrinkInfoView.center = touchPoint;
        
        // change shrinkInfoView status
        self.shrinkInfoView.status = ATShrinkInfoViewStatusActive;
    }
    else if (panGesture.state == UIGestureRecognizerStateChanged)
    {
        // move shrink info view
        CGPoint touchPoint = [panGesture locationInView:self.assistiveWindow];
        self.shrinkInfoView.center = touchPoint;
    }
    else if (panGesture.state == UIGestureRecognizerStateEnded
             || panGesture.state == UIGestureRecognizerStateFailed
             || panGesture.state == UIGestureRecognizerStateCancelled)
    {
        self.assistiveWindow.frame = CGRectMake(self.shrinkInfoView.frame.origin.x, self.shrinkInfoView.frame.origin.y, kATShrinkViewWidth, kATShrinkViewWidth);
        self.shrinkInfoView.frame = CGRectMake(0, 0, kATShrinkViewWidth, kATShrinkViewWidth);
        
        [UIView animateWithDuration:kATAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            // strict to screen side
            self.assistiveWindow.frame = [self normalizdFrameToScreenSide:self.assistiveWindow.frame];
            
        } completion:^(BOOL finished) {
            
            // save frame for shrink amination
            self.shrinkedWindowFrame = self.assistiveWindow.frame;
            
            // change shrinkInfoView status
            self.shrinkInfoView.status = ATShrinkInfoViewStatusCountdown;
        }];
    }
}

#pragma mark - Private: ATShrinkInfoViewDelegate

- (void)shrinkInfoViewTaped:(ATShrinkInfoView *)shrinkView atPoint:(CGPoint)tapPoint
{
    self.status = ATRootViewControllerStatusExpand;
    
    // change shrinkInfoView status
    self.shrinkInfoView.status = ATShrinkInfoViewStatusActive;
    
    [self.expandInfoView expandInfoViewWillExpand];
    
    [UIView animateWithDuration:kATAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.shrinkInfoView.hidden = YES;
        self.expandInfoView.hidden = NO;
        
        self.assistiveWindow.frame = self.expandedWindowFrame;
        self.expandInfoView.frame = CGRectMake(0, 0, kATExpandViewWidth, kATExpandViewHeight);
        
    } completion:^(BOOL finished) {
        
        [self.expandInfoView expandInfoViewDidExpand];
    }];
}

#pragma mark - Private: ATExpandInfoViewDelegate

- (void)expandInfoViewCloseAction:(ATExpandInfoView *)expandView
{
    self.status = ATRootViewControllerStatusShrink;
    
    [self.expandInfoView expandInfoViewWillShrink];
    
    [UIView animateWithDuration:kATAnimationDuration animations:^{
        
        self.assistiveWindow.frame = self.shrinkedWindowFrame;
        self.shrinkInfoView.frame = CGRectMake(0, 0, kATShrinkViewWidth, kATShrinkViewWidth);
        
    } completion:^(BOOL finished) {
        self.shrinkInfoView.hidden = NO;
        self.expandInfoView.hidden = YES;
        
        // change shrinkInfoView status
        self.shrinkInfoView.status = ATShrinkInfoViewStatusCountdown;
        
        [self.expandInfoView expandInfoViewDidShrink];
    }];
}

#pragma mark - Public: Interface

- (NSArray<NSString *> *)currentTitles
{
    return self.expandInfoView.currentTitles;
}

- (void)addCustomView:(UIView<ATCustomViewProtocol> *)aView forTitle:(NSString *)aTitle
{
    [self.expandInfoView addCustomView:aView forTitle:aTitle];
}

- (void)removeCustiomViewForTitle:(NSString *)aTitle
{
    [self.expandInfoView removeCustiomViewForTitle:aTitle];
}

- (void)removeAllCustomViews
{
    [self.expandInfoView removeAllCustomViews];
}

#pragma mark - Private: Handle Position

- (CGRect)normalizdFrameToScreenSide:(CGRect)curFrame
{
    CGRect result = curFrame;
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGPoint curCenter = CGPointMake(CGRectGetMidX(curFrame), CGRectGetMidY(curFrame));
    
    if (curCenter.y < screenSize.height * 0.15)
    {
        result.origin.x = MAX(0, MIN(screenSize.width - curFrame.size.width, result.origin.x));
        result.origin.y = kATShrinkViewMargin;
    }
    else if (curCenter.y > screenSize.height * 0.85)
    {
        result.origin.x = MAX(0, MIN(screenSize.width - curFrame.size.width, result.origin.x));
        result.origin.y = screenSize.height - curFrame.size.height - kATShrinkViewMargin;
    }
    else if (curCenter.x < screenSize.width/2.0)
    {
        result.origin.x = kATShrinkViewMargin;
    }
    else if (curCenter.x >= screenSize.width/2.0)
    {
        result.origin.x = screenSize.width - curFrame.size.width - kATShrinkViewMargin;
    }
    
    return result;
}

@end
