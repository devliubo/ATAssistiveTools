//
//  ATRootViewController.h
//  ATAssistiveTools
//
//  Created by liubo on 2017/5/27.
//  Copyright © 2017年 devliubo. All rights reserved.
//

#import "ATContainerWindow.h"
#import "ATCustomViewProtocol.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - ATRootViewController

@protocol ATRootViewControllerDelegate <NSObject>

@end

@interface ATRootViewController : UIViewController

@property (nonatomic, weak) id<ATRootViewControllerDelegate> delegate;

// default YES
@property (nonatomic, assign) BOOL autorotateEnabled;

@property (nonatomic, readonly) NSArray<NSString *> *currentTitles;
- (void)addCustomView:(UIView <ATCustomViewProtocol>*)aView forTitle:(NSString *)aTitle;
- (void)removeCustiomViewForTitle:(NSString *)aTitle;
- (void)removeAllCustomViews;

// used for ATAssistiveTools
@property (nonatomic, weak) ATContainerWindow *assistiveWindow;
@property (nonatomic, readonly) CGRect shrinkedWindowFrame;

@end

NS_ASSUME_NONNULL_END
