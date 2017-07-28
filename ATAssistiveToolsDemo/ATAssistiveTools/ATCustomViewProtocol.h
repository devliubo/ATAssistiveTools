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

- (void)customViewWillAppear;
- (void)customViewDidAppear;
- (void)customViewWillDisappear;
- (void)customViewDidDisappear;

- (void)customViewWillShrink;
- (void)customViewDidShrink;
- (void)customViewWillExpand;
- (void)customViewDidExpand;

@end
