//
//  ATFakeLocationView.m
//  ATAssistiveTools
//
//  Created by liubo on 2017/7/14.
//  Copyright © 2017年 devliubo. All rights reserved.
//

#import "ATFakeLocationView.h"

#import <MapKit/MapKit.h>
#import <objc/runtime.h>
#import <objc/message.h>

#pragma mark - ATNoMenuTextField

@interface ATNoMenuTextField : UITextField
@end

@implementation ATNoMenuTextField

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(paste:) ||
        action == @selector(cut:) ||
        action == @selector(copy:) ||
        action == @selector(select:) ||
        action == @selector(selectAll:) ||
        action == @selector(delete:) ||
        action == @selector(makeTextWritingDirectionLeftToRight:) ||
        action == @selector(makeTextWritingDirectionRightToLeft:) ||
        action == @selector(toggleBoldface:) ||
        action == @selector(toggleItalics:) ||
        action == @selector(toggleUnderline:)
        )
    {
        return NO;
    }
    return [super canPerformAction:action withSender:sender];
}

@end

@interface ATFakeLocationView () <UITextFieldDelegate,MKMapViewDelegate>

@property (nonatomic, strong) UIButton *applyLocButton;
@property (nonatomic, strong) UIButton *recoverLocButton;

@property (nonatomic, strong) UILabel *appliedLocationLabel;

@property (nonatomic, strong) ATNoMenuTextField *latitudeText;
@property (nonatomic, strong) ATNoMenuTextField *longitudeText;

@property (nonatomic, strong) UIButton *useMapViewButton;
@property (nonatomic, strong) MKMapView *mapView;

@end

@implementation ATFakeLocationView

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self buildSimulateLocationView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self buildSimulateLocationView];
    }
    return self;
}

- (void)buildSimulateLocationView
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
    self.appliedLocationLabel = [[UILabel alloc] init];
    self.appliedLocationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.appliedLocationLabel.font = [UIFont systemFontOfSize:14];
    self.appliedLocationLabel.textAlignment = NSTextAlignmentCenter;
    self.appliedLocationLabel.adjustsFontSizeToFitWidth = YES;
    self.appliedLocationLabel.text = @"Not Applied";
    
    [self addSubview:self.appliedLocationLabel];
    
    self.applyLocButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.applyLocButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.applyLocButton.layer.borderColor = [UIColor blueColor].CGColor;
    self.applyLocButton.layer.borderWidth = 0.5;
    self.applyLocButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [self.applyLocButton setTitle:@"Apply" forState:UIControlStateNormal];
    [self.applyLocButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.applyLocButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [self.applyLocButton addTarget:self action:@selector(applyButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.recoverLocButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.recoverLocButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.recoverLocButton.layer.borderColor = [UIColor blueColor].CGColor;
    self.recoverLocButton.layer.borderWidth = 0.5;
    self.recoverLocButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [self.recoverLocButton setTitle:@"Recover" forState:UIControlStateNormal];
    [self.recoverLocButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.recoverLocButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [self.recoverLocButton addTarget:self action:@selector(recoverButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.useMapViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.useMapViewButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.useMapViewButton.layer.borderColor = [UIColor blueColor].CGColor;
    self.useMapViewButton.layer.borderWidth = 0.5;
    self.useMapViewButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [self.useMapViewButton setTitle:@"ShowMap" forState:UIControlStateNormal];
    [self.useMapViewButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.useMapViewButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [self.useMapViewButton addTarget:self action:@selector(useMapViewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.applyLocButton];
    [self addSubview:self.recoverLocButton];
    [self addSubview:self.useMapViewButton];
    
    self.latitudeText = [[ATNoMenuTextField alloc] init];
    self.latitudeText.translatesAutoresizingMaskIntoConstraints = NO;
    self.latitudeText.delegate = self;
    self.latitudeText.borderStyle = UITextBorderStyleRoundedRect;
    self.latitudeText.placeholder = @"Latitude";
    self.latitudeText.font = [UIFont systemFontOfSize:14];
    self.latitudeText.text = [NSString stringWithFormat:@"%f", [[ATSimlulateCoordinate sharedInstance] externalGCJ02Coordinate].latitude];
    self.latitudeText.textAlignment = NSTextAlignmentCenter;
    self.latitudeText.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    self.latitudeText.returnKeyType = UIReturnKeyDone;
    
    self.longitudeText = [[ATNoMenuTextField alloc] init];
    self.longitudeText.translatesAutoresizingMaskIntoConstraints = NO;
    self.longitudeText.delegate = self;
    self.longitudeText.borderStyle = UITextBorderStyleRoundedRect;
    self.longitudeText.placeholder = @"Longitude";
    self.longitudeText.font = [UIFont systemFontOfSize:14];
    self.longitudeText.text = [NSString stringWithFormat:@"%f", [[ATSimlulateCoordinate sharedInstance] externalGCJ02Coordinate].longitude];
    self.longitudeText.textAlignment = NSTextAlignmentCenter;
    self.longitudeText.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    self.longitudeText.returnKeyType = UIReturnKeyDone;
    
    [self addSubview:self.latitudeText];
    [self addSubview:self.longitudeText];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_appliedLocationLabel, _applyLocButton, _recoverLocButton, _latitudeText, _longitudeText, _useMapViewButton);
    
    // label
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_appliedLocationLabel]-10-|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_appliedLocationLabel(==height)]" options:0 metrics:@{@"height":@(20)} views:views]];
    
    // buttons
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_applyLocButton(>=width)]-10-[_recoverLocButton(==_applyLocButton)]-[_useMapViewButton(==width)]-20-|" options:0 metrics:@{@"width":@(80)} views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_appliedLocationLabel]-10-[_applyLocButton(==height)]" options:0 metrics:@{@"height":@(20)} views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_appliedLocationLabel]-10-[_recoverLocButton(==height)]" options:0 metrics:@{@"height":@(20)} views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_appliedLocationLabel]-10-[_useMapViewButton(==height)]" options:0 metrics:@{@"height":@(20)} views:views]];
    
    // text fields
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_latitudeText(>=width)]-10-[_longitudeText(==_latitudeText)]-10-|" options:0 metrics:@{@"width":@(110)} views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_applyLocButton]-10-[_latitudeText(==height)]" options:0 metrics:@{@"height":@(20)} views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_applyLocButton]-10-[_longitudeText(==height)]" options:0 metrics:@{@"height":@(20)} views:views]];
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
    
    [self hideKeyboardIfNeed];
}

- (void)customViewDidDisappear
{
    NSLog(@"customViewDidDisappear");
}

- (void)customViewWillShrink
{
    NSLog(@"customViewWillShrink");
    
    [self hideKeyboardIfNeed];
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

- (void)applyButtonAction:(UIButton *)button
{
    [self hideKeyboardIfNeed];
    
    [self useFakeCoordinate];
    
    [self applyInputTextToFakeLocation];
}

- (void)recoverButtonAction:(UIButton *)button
{
    [self hideKeyboardIfNeed];
    
    [self unuseFakeCoordinate];
    
    [self recoverInputTextToFakeLocation];
}

- (void)useMapViewButtonAction:(UIButton *)button
{
    if (self.mapView == nil)
    {
        MKMapCamera *mapCamera = [MKMapCamera cameraLookingAtCenterCoordinate:[[ATSimlulateCoordinate sharedInstance] externalGCJ02Coordinate]
                                                            fromEyeCoordinate:[[ATSimlulateCoordinate sharedInstance] externalGCJ02Coordinate]
                                                                  eyeAltitude:1000];
        
        self.mapView = [[MKMapView alloc] init];
        self.mapView.translatesAutoresizingMaskIntoConstraints = NO;
        self.mapView.delegate = self;
        [self.mapView setCamera:mapCamera animated:NO];
        
        [self addSubview:self.mapView];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_latitudeText, _longitudeText, _mapView);
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_mapView]-10-|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_latitudeText]-10-[_mapView]-10-|" options:0 metrics:nil views:views]];
        
        [self.useMapViewButton setTitle:@"HideMap" forState:UIControlStateNormal];
    }
    else
    {
        [self.mapView removeFromSuperview];
        self.mapView.delegate = nil;
        self.mapView = nil;
        
        [self.useMapViewButton setTitle:@"ShowMap" forState:UIControlStateNormal];
    }
}

#pragma mark - Methods

- (void)useFakeCoordinate
{
    // 替换CLLocation的coordiante方法实现
//    [ATSimlulateCoordinate sharedInstance].useCLLocationCoordiante = YES;
    
    // 替换CLLocationManager实现, 目前存在坐标转换导致的不准确问题, 以及判断坐标是否在国内的不准确问题
    [ATSimlulateCoordinate sharedInstance].useCLLocationManager = YES;
}

- (void)unuseFakeCoordinate
{
    // 替换CLLocation的coordiante方法实现
//    [ATSimlulateCoordinate sharedInstance].useCLLocationCoordiante = NO;
    
    // 替换CLLocationManager实现, 目前存在坐标转换导致的不准确问题, 以及判断坐标是否在国内的不准确问题
    [ATSimlulateCoordinate sharedInstance].useCLLocationManager = NO;
}

- (void)hideKeyboardIfNeed
{
    if (self.latitudeText.isFirstResponder)
    {
        [self.latitudeText resignFirstResponder];
    }
    
    if (self.longitudeText.isFirstResponder)
    {
        [self.longitudeText resignFirstResponder];
    }
}

- (void)applyInputTextToFakeLocation
{
    BOOL latitudeResult = [self checkInputForTextField:self.latitudeText];
    BOOL longitudeResult = [self checkInputForTextField:self.longitudeText];
    
    if (latitudeResult && longitudeResult)
    {
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(self.latitudeText.text.doubleValue, self.longitudeText.text.doubleValue);
        [[ATSimlulateCoordinate sharedInstance] setExternalGCJ02Coordinate:coordinate];
        
        self.appliedLocationLabel.text = [NSString stringWithFormat:@"Applied:{lat:%@-lon:%@}", self.latitudeText.text, self.longitudeText.text];
    }
    else
    {
        self.appliedLocationLabel.text = [NSString stringWithFormat:@"Input Error! Current Aplied:{lat:%f-lon:%f}", [[ATSimlulateCoordinate sharedInstance] externalGCJ02Coordinate].latitude, [[ATSimlulateCoordinate sharedInstance] externalGCJ02Coordinate].longitude];
    }
}

- (void)recoverInputTextToFakeLocation
{
    self.appliedLocationLabel.text = @"Recovered";
}

#pragma mark - UITextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.textColor = [UIColor blackColor];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    textField.textColor = [UIColor blackColor];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    BOOL result = [self checkInputForTextField:textField];
    
    if (!result)
    {
        textField.textColor = [UIColor redColor];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    BOOL result = [self checkInputForTextField:textField];
    
    if (result)
    {
        [self hideKeyboardIfNeed];
    }
    else
    {
        textField.textColor = [UIColor redColor];
    }
    
    return result;
}

- (BOOL)checkInputForTextField:(UITextField *)textField
{
    BOOL result = NO;
    if (textField == self.latitudeText)
    {
        result = [self checkInputLatitude:textField.text];
    }
    else if (textField == self.longitudeText)
    {
        result = [self checkInputLongitude:textField.text];
    }
    else
    {
        result = NO;
    }
    
    return result;
}

- (BOOL)checkInputLatitude:(NSString *)inputLatitude
{
    if (inputLatitude == nil || inputLatitude.length <= 0)
    {
        return NO;
    }
    
    // +90.0 ~ -90.0
    NSString *regexString = @"^[-+]?((0*[1-8]\\d|0*\\d)(\\.\\d+)?|0*90(\\.0+)?)$";
    NSRange result = [inputLatitude rangeOfString:regexString options:NSRegularExpressionSearch];
    
    if (result.location == NSNotFound)
    {
        return NO;
    }
    
    return YES;
}

- (BOOL)checkInputLongitude:(NSString *)inputLongitude
{
    if (inputLongitude == nil || inputLongitude.length <= 0)
    {
        return NO;
    }
    
    // +180.0 ~ -180.0
    NSString *regexString = @"^[-+]?((0*1[0-7]\\d|0*\\d{1,2})(\\.\\d+)?|0*180(\\.0+)?)$";
    NSRange result = [inputLongitude rangeOfString:regexString options:NSRegularExpressionSearch];
    
    if (result.location == NSNotFound)
    {
        return NO;
    }
    
    return YES;
}

#pragma mark - MKMapView Delegate

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    [mapView removeAnnotations:mapView.annotations];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    CLLocationCoordinate2D centerCoordinate = [mapView centerCoordinate];
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = centerCoordinate;
    [mapView addAnnotation:annotation];
    
    self.latitudeText.text = [NSString stringWithFormat:@"%f", centerCoordinate.latitude];
    self.longitudeText.text = [NSString stringWithFormat:@"%f", centerCoordinate.longitude];
    
    self.latitudeText.textColor = [UIColor greenColor];
    self.longitudeText.textColor = [UIColor greenColor];
    
    [self applyButtonAction:nil];
}

@end

#pragma mark - ATSimlulateCoordinate

@interface ATSimlulateCoordinate ()

@end

@implementation ATSimlulateCoordinate

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init
{
    if (self = [super init])
    {
        [self buildSimlulateCoordinate];
    }
    return self;
}

- (void)buildSimlulateCoordinate
{
    [self initPropreties];
    
    [self replaceCLLocationCoordianteMethod];
    
    [self replaceLocationUpdateCallbackMethod];
}

- (void)initPropreties
{
    self.useCLLocationCoordiante = NO;
    self.useCLLocationManager = NO;
    
    self.externalGCJ02Coordinate = CLLocationCoordinate2DMake(39.906477, 116.397614);
}

#pragma mark - Override

- (void)setExternalGCJ02Coordinate:(CLLocationCoordinate2D)externalGCJ02Coordinate
{
    _externalGCJ02Coordinate = externalGCJ02Coordinate;
    
    _externalWGS84Coordinate = [self gcj02Decrypt:_externalGCJ02Coordinate.latitude gjLon:_externalGCJ02Coordinate.longitude];
}

- (void)setExternalWGS84Coordinate:(CLLocationCoordinate2D)externalWGS84Coordinate
{
    _externalWGS84Coordinate = externalWGS84Coordinate;
    
    _externalGCJ02Coordinate = [self gcj02Encrypt:_externalWGS84Coordinate.latitude bdLon:_externalWGS84Coordinate.longitude];
}

#pragma mark - CLLocation coordinate

- (CLLocationCoordinate2D)modifyCoordinate
{
    if ([[ATSimlulateCoordinate sharedInstance] useCLLocationCoordiante])
    {
        return [[ATSimlulateCoordinate sharedInstance] externalWGS84Coordinate];
    }
    else
    {
        return [self modifyCoordinate];
    }
}

- (void)replaceCLLocationCoordianteMethod
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class cllocationClass = [CLLocation class];
        Class modifyClass = [ATSimlulateCoordinate class];
        
        // add new method 'modifyCoordinate' to CLLocation
        SEL modifyCoordinateSelector = @selector(modifyCoordinate);
        Method modifyCoordinateMethod = class_getInstanceMethod(modifyClass, modifyCoordinateSelector);
        class_addMethod(cllocationClass, modifyCoordinateSelector, method_getImplementation(modifyCoordinateMethod), method_getTypeEncoding(modifyCoordinateMethod));
        
        // exchange CLLocation method 'coordinate'
        SEL coordinateSelector = @selector(coordinate);
        Method coordinateMethod = class_getInstanceMethod(cllocationClass, coordinateSelector);
        Method swizzledCoordinateMethod = class_getInstanceMethod(cllocationClass, modifyCoordinateSelector);
        
        method_exchangeImplementations(coordinateMethod, swizzledCoordinateMethod);
    });
}

#pragma mark - CLLcationManger updateLocation

- (void)modifyStartUpdateLocation
{
    if ([self isKindOfClass:[CLLocationManager class]])
    {
        CLLocationManager *realSelf = (CLLocationManager *)self;
        if (realSelf.delegate != nil)
        {
            [[ATSimlulateCoordinate sharedInstance] replaceCallbackForObject:realSelf.delegate];
        }
    }
    
    [self modifyStartUpdateLocation];
}

- (void)modifySetDelegate:(id <CLLocationManagerDelegate>)delegate
{
    [self modifySetDelegate:delegate];
    
    if (delegate != nil)
    {
        [[ATSimlulateCoordinate sharedInstance] replaceCallbackForObject:delegate];
    }
}

- (void)modifyLocationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    if ([[ATSimlulateCoordinate sharedInstance] useCLLocationManager])
    {
        CLLocation *lastLocation = [locations lastObject];
        CLLocation *newLocation = [[CLLocation alloc] initWithCoordinate:[[ATSimlulateCoordinate sharedInstance] externalWGS84Coordinate]
                                                                altitude:lastLocation.altitude
                                                      horizontalAccuracy:lastLocation.horizontalAccuracy
                                                        verticalAccuracy:lastLocation.verticalAccuracy
                                                                  course:lastLocation.course
                                                                   speed:lastLocation.speed
                                                               timestamp:[NSDate date]];
        
        [self modifyLocationManager:manager didUpdateLocations:@[newLocation]];
    }
    else
    {
        [self modifyLocationManager:manager didUpdateLocations:locations];
    }
}

- (void)replaceLocationUpdateCallbackMethod
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class locationManagerClass = [CLLocationManager class];
        Class modifyClass = [ATSimlulateCoordinate class];
        
        // add new method 'modifyStartUpdateLocation' and 'modifySetDelegate:' to CLLocationManager
        SEL modifyStartUpdateSelector = @selector(modifyStartUpdateLocation);
        SEL modifySetDelegateSelector = @selector(modifySetDelegate:);
        Method modifyStartUpdateMethod = class_getInstanceMethod(modifyClass, modifyStartUpdateSelector);
        Method modifySetDelegateMethod = class_getInstanceMethod(modifyClass, modifySetDelegateSelector);
        class_addMethod(locationManagerClass, modifyStartUpdateSelector, method_getImplementation(modifyStartUpdateMethod), method_getTypeEncoding(modifyStartUpdateMethod));
        class_addMethod(locationManagerClass, modifySetDelegateSelector, method_getImplementation(modifySetDelegateMethod), method_getTypeEncoding(modifySetDelegateMethod));
        
        // exchange CLLocationManager method 'startUpdatingLocation' and 'setDelegate:'
        SEL startUpdateSelector = @selector(startUpdatingLocation);
        SEL setDelegateSelector = @selector(setDelegate:);
        Method startUpdateMethod = class_getInstanceMethod(locationManagerClass, startUpdateSelector);
        Method swizzledStartUpdateMethod = class_getInstanceMethod(locationManagerClass, modifyStartUpdateSelector);
        Method setDelegateMethod = class_getInstanceMethod(locationManagerClass, setDelegateSelector);
        Method swizzledSetDelegateMethod = class_getInstanceMethod(locationManagerClass, modifySetDelegateSelector);
        
        method_exchangeImplementations(startUpdateMethod, swizzledStartUpdateMethod);
        method_exchangeImplementations(setDelegateMethod, swizzledSetDelegateMethod);
    });
}

- (void)replaceCallbackForObject:(id<CLLocationManagerDelegate>)object
{
    if ([object respondsToSelector:@selector(locationManager:didUpdateLocations:)] == NO)
    {
        return;
    }
    
    NSNumber *flag = (NSNumber *)objc_getAssociatedObject(object, "ATModified");
    if (flag && [flag boolValue] == YES)
    {
        return;
    }
    
    Class objectClass = [object class];
    Class modifyClass = [ATSimlulateCoordinate class];
    
    SEL modifyCallbackSelector = @selector(modifyLocationManager:didUpdateLocations:);
    Method modifyCallbackMethod = class_getInstanceMethod(modifyClass, modifyCallbackSelector);
    class_addMethod(objectClass, modifyCallbackSelector, method_getImplementation(modifyCallbackMethod), method_getTypeEncoding(modifyCallbackMethod));
    
    SEL callbackSelector = @selector(locationManager:didUpdateLocations:);
    Method callbackMethod = class_getInstanceMethod(objectClass, callbackSelector);
    Method swizzledCallbackMethod = class_getInstanceMethod(objectClass, modifyCallbackSelector);
    
    method_exchangeImplementations(callbackMethod, swizzledCallbackMethod);
    
    objc_setAssociatedObject(object, "ATModified", [NSNumber numberWithBool:YES], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Coordinate Convert

- (CLLocationDegrees)transformLat:(CLLocationDegrees)x bdLon:(CLLocationDegrees)y
{
    CLLocationDegrees ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * M_PI) + 40.0 * sin(y / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * M_PI) + 320 * sin(y * M_PI / 30.0)) * 2.0 / 3.0;
    return ret;
}

- (CLLocationDegrees)transformLon:(CLLocationDegrees)x bdLon:(CLLocationDegrees)y
{
    CLLocationDegrees ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * M_PI) + 40.0 * sin(x / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 * M_PI) + 300.0 * sin(x / 30.0 * M_PI)) * 2.0 / 3.0;
    return ret;
}

- (BOOL)outOfChina:(CLLocationDegrees)lat bdLon:(CLLocationDegrees)lon
{
    return (lon < 72.004 || lon > 137.8347) || (lat < 0.8293 || lat > 55.8271);
}

- (CLLocationCoordinate2D)gcj02Encrypt:(CLLocationDegrees)ggLat bdLon:(CLLocationDegrees)ggLon
{
    if ([self outOfChina:ggLat bdLon:ggLon]) {
        return CLLocationCoordinate2DMake(ggLat, ggLon);
    }
    
    static double jzA = 6378245.0;
    static double jzEE = 0.00669342162296594323;
    
    CLLocationDegrees dLat = [self transformLat:(ggLon - 105.0)bdLon:(ggLat - 35.0)];
    CLLocationDegrees dLon = [self transformLon:(ggLon - 105.0) bdLon:(ggLat - 35.0)];
    CLLocationDegrees radLat = ggLat / 180.0 * M_PI;
    CLLocationDegrees magic = sin(radLat);
    magic = 1 - jzEE * magic * magic;
    CLLocationDegrees sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0) / ((jzA * (1 - jzEE)) / (magic * sqrtMagic) * M_PI);
    dLon = (dLon * 180.0) / (jzA / sqrtMagic * cos(radLat) * M_PI);
    
    return CLLocationCoordinate2DMake(ggLat + dLat, ggLon + dLon);
}

- (CLLocationCoordinate2D)gcj02Decrypt:(CLLocationDegrees)gjLat gjLon:(CLLocationDegrees)gjLon
{
    CLLocationCoordinate2D  gPt = [self gcj02Encrypt:gjLat bdLon:gjLon];
    CLLocationDegrees dLon = gPt.longitude - gjLon;
    CLLocationDegrees dLat = gPt.latitude - gjLat;
    return CLLocationCoordinate2DMake(gjLat - dLat, gjLon - dLon);
}

@end
