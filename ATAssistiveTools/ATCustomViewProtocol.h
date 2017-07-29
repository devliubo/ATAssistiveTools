//
//  ATCustomViewProtocol.h
//  ATAssistiveTools
//
//  Created by liubo on 2017/5/27.
//  Copyright © 2017年 devliubo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ATCustomViewProtocol <NSObject>
@optional

/**
 *  Called when the custom view will appear.
 */
- (void)customViewWillAppear;

/**
 *  Called when the custom view did appear.
 */
- (void)customViewDidAppear;

/**
 *  Called when the custom view will disappear.
 */
- (void)customViewWillDisappear;

/**
 *  Called when the custom view did disappear.
 */
- (void)customViewDidDisappear;


/**
 *  Called when the assistive tool will shrink.
 */
- (void)customViewWillShrink;

/**
 *  Called when the assistive tool did shrink.
 */
- (void)customViewDidShrink;

/**
 *  Called when the assistive tool will expand.
 */
- (void)customViewWillExpand;

/**
 *  Called when the assistive tool did expand.
 */
- (void)customViewDidExpand;

@end
