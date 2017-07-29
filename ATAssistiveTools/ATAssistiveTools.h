//
//  ATAssistiveTools.h
//  ATAssistiveTools
//
//  Created by liubo on 2017/5/26.
//  Copyright © 2017年 devliubo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATCustomViewProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATAssistiveTools : NSObject

+ (instancetype)sharedInstance;

/**
 *  Call ths method to show the assistive tool window.
 */
- (void)show;

/**
 *  The window that used for assistive tool. Can be used for present view controller or anyother operations that must via a window.
 */
@property (nonatomic, readonly) UIWindow *mainWindow;

@end

@interface ATAssistiveTools ()

/**
 *  Get all titles had been added.
 */
@property (nonatomic, readonly) NSArray<NSString *> *currentTitles;

/**
 *  add a custom view and corresponding title to assistive tool.
 *
 *  @param aView the view to be added. This view must be adopt the ATCustomViewProtocol protocol.
 *  @param aTitle the title for the view to be added
 */
- (void)addCustomView:(UIView <ATCustomViewProtocol>*)aView forTitle:(NSString *)aTitle;

/**
 *  remove a custom view via it's corresponding title.
 *
 *  @param aTitle the title for the view to be moved
 */
- (void)removeCustiomViewForTitle:(NSString *)aTitle;

/**
 *  remove all custom views from assistive tool.
 */
- (void)removeAllCustomViews;

@end

NS_ASSUME_NONNULL_END
