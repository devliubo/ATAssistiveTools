//
//  ATShrinkInfoView.m
//  ATAssistiveTools
//
//  Created by liubo on 2017/5/26.
//  Copyright © 2017年 devliubo. All rights reserved.
//

#import "ATShrinkInfoView.h"

#define kATShrinkViewCornerRadius       (kATShrinkViewWidth/5.0)
#define kATShrinkViewAnimationDuration  0.2f

@interface ATShrinkInfoView ()

@property (nonatomic, strong) NSTimer *alphaTimer;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *mainTipLabel;

@end

@implementation ATShrinkInfoView

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self buildShrinkInfoView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self buildShrinkInfoView];
    }
    return self;
}

- (void)dealloc
{
    [self stopAlphaTimer];
}

- (void)buildShrinkInfoView
{
    self.layer.cornerRadius = kATShrinkViewCornerRadius;
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:kATShrinkViewDeactiveAlpha];
    
    [self initProperties];
    
    [self initContentView];
    
    [self initMainTipLabel];
    
    [self.mainTipLabel setText:@"ATAssistiveTools"];
}

- (void)initProperties
{
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizerAction:)];
    [_tapGestureRecognizer setNumberOfTapsRequired:1];
    [_tapGestureRecognizer setNumberOfTouchesRequired:1];
    
    [self addGestureRecognizer:_tapGestureRecognizer];
}

- (void)initContentView
{
    _contentView = [[UIView alloc] init];
    [_contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self addSubview:_contentView];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_contentView);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-left-[_contentView]-right-|" options:0 metrics:@{@"left":@(kATShrinkViewCornerRadius/2.0),@"right":@(kATShrinkViewCornerRadius/2.0)} views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-top-[_contentView]-bottom-|" options:0 metrics:@{@"top":@(kATShrinkViewCornerRadius/2.0),@"bottom":@(kATShrinkViewCornerRadius/2.0)} views:views]];
}

- (void)initMainTipLabel
{
    _mainTipLabel = [[UILabel alloc] init];
    _mainTipLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _mainTipLabel.numberOfLines = 4;
    _mainTipLabel.textColor = [UIColor whiteColor];
    _mainTipLabel.font = [UIFont systemFontOfSize:8];
    
    [self.contentView addSubview:_mainTipLabel];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_mainTipLabel);
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mainTipLabel]|" options:0 metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_mainTipLabel]|" options:0 metrics:nil views:views]];
}

#pragma mark - Timer Action

- (void)startAlphaTimer
{
    if (self.alphaTimer != nil)
    {
        return;
    }
    
    self.alphaTimer = [NSTimer timerWithTimeInterval:4.f target:self selector:@selector(timerAction:) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:self.alphaTimer forMode:NSRunLoopCommonModes];
}

- (void)stopAlphaTimer
{
    if (self.alphaTimer == nil)
    {
        return;
    }
    
    [self.alphaTimer invalidate];
    self.alphaTimer = nil;
}

- (void)timerAction:(NSTimer *)timer
{
    [UIView animateWithDuration:kATShrinkViewAnimationDuration animations:^{
        self.status = ATShrinkInfoViewStatusDeactive;
    }];
}

#pragma mark - Interface

- (void)setStatus:(ATShrinkInfoViewStatus)status
{
    [self stopAlphaTimer];
    
    _status = status;
    if (_status == ATShrinkInfoViewStatusActive)
    {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:kATShrinkViewActiveAlpha];
    }
    else if (_status == ATShrinkInfoViewStatusCountdown)
    {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:kATShrinkViewActiveAlpha];
        
        [self startAlphaTimer];
    }
    else if (_status == ATShrinkInfoViewStatusDeactive)
    {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:kATShrinkViewDeactiveAlpha];
    }
    else
    {
        // do nothing
    }
}

#pragma mark - Gesture Recognizer Action

- (void)tapGestureRecognizerAction:(UITapGestureRecognizer *)tapGesture
{
    if (self.delegate)
    {
        CGPoint touchPoint = [tapGesture locationInView:self];
        [self.delegate shrinkInfoViewTaped:self atPoint:touchPoint];
    }
}

@end
