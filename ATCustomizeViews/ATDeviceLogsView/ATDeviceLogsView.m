//
//  ATDeviceLogsView.m
//  ATAssistiveTools
//
//  Created by liubo on 2017/7/11.
//  Copyright © 2017年 devliubo. All rights reserved.
//

#import "ATDeviceLogsView.h"

#import "asl.h"
#import <os/log.h>

@interface ATDeviceLogsView ()

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIButton *refreshButton;

@end

@implementation ATDeviceLogsView

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self buildDeviceLogsView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self buildDeviceLogsView];
    }
    return self;
}

- (void)buildDeviceLogsView
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
    self.refreshButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.refreshButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.refreshButton.layer.borderColor = [UIColor blueColor].CGColor;
    self.refreshButton.layer.borderWidth = 0.5;
    self.refreshButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [self.refreshButton setTitle:@"Refresh" forState:UIControlStateNormal];
    [self.refreshButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.refreshButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [self.refreshButton addTarget:self action:@selector(refreshButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.textView = [[UITextView alloc] init];
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
    self.textView.editable = NO;
    self.textView.selectable = NO;
    
    [self addSubview:self.refreshButton];
    [self addSubview:self.textView];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_textView, _refreshButton);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_textView]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_refreshButton(==width)]" options:0 metrics:@{@"width":@(80)} views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_refreshButton(==height)]-10-[_textView]|" options:0 metrics:@{@"height":@(20)} views:views]];
}

#pragma mark - Button Action

- (void)refreshButtonAction:(UIButton *)button
{
    self.textView.text = @"";
    
    [self updateDeviceLog];
}

#pragma mark - Methods

- (void)updateDeviceLog
{
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] < 10.0)
    {
        __weak typeof(self) weakSelf = self;
        [ATDeviceLogsView asyncReadDeviceLogsWithCompletionBlock:^(NSString *logs) {
            weakSelf.textView.text = logs;
            [weakSelf.textView scrollRangeToVisible:NSMakeRange(weakSelf.textView.text.length-10, 10)];
        }];
    }
    else
    {
        self.textView.text = @"Onle applicable to system version less than 10.0!";
    }
}

#pragma mark - ATCustomViewProtocol

- (void)customViewDidAppear
{
    [self updateDeviceLog];
}

#pragma mark - Read Device Log

+ (void)asyncReadDeviceLogsWithCompletionBlock:(void (^)(NSString *logs))completionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *logs = [self readDeviceLogs];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock)
            {
                completionBlock(logs);
            }
        });
    });
}

+ (NSString *)readDeviceLogs
{
    aslmsg q, m;
    int i;
    const char *key, *val;
    NSMutableString *logs = [NSMutableString stringWithString:@""];
    
    q = asl_new(ASL_TYPE_QUERY);
    
    aslresponse r = asl_search(NULL, q);
    while (NULL != (m = asl_next(r)))
    {
        NSMutableDictionary *tmpDict = [NSMutableDictionary dictionary];
        
        for (i = 0; (NULL != (key = asl_key(m, i))); i++)
        {
            NSString *keyString = [NSString stringWithUTF8String:(char *)key];
            
            val = asl_get(m, key);
            
            NSString *string = val != NULL ? [NSString stringWithUTF8String:val] : nil;
            [tmpDict setValue:string forKey:keyString];
        }
        
        NSString *line = [NSString stringWithFormat:@"%@ %@[%@] %@\n", [NSDate dateWithTimeIntervalSince1970:[tmpDict[@"Time"] intValue]], tmpDict[@"Sender"], tmpDict[@"PID"], tmpDict[@"Message"]];
        
        [logs appendString:line];
    }
    asl_release(r);
    
    return logs;
}

@end
