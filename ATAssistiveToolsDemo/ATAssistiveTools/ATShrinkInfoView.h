//
//  ATShrinkInfoView.h
//  ATAssistiveTools
//
//  Created by liubo on 2017/5/26.
//  Copyright © 2017年 devliubo. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kATShrinkViewActiveAlpha    0.75f
#define kATShrinkViewDeactiveAlpha  0.25f
#define kATShrinkViewWidth          60.f
#define kATShrinkViewMargin         2.f

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ATShrinkInfoViewStatus) {
    ATShrinkInfoViewStatusNone = 0,//just stop timer
    ATShrinkInfoViewStatusActive = 1,
    ATShrinkInfoViewStatusCountdown = 2,
    ATShrinkInfoViewStatusDeactive = 3,
};

@class ATShrinkInfoView;

@protocol ATShrinkInfoViewDelegate <NSObject>

- (void)shrinkInfoViewTaped:(ATShrinkInfoView *)shrinkView atPoint:(CGPoint)tapPoint;

@end

@interface ATShrinkInfoView : UIView

@property (nonatomic, weak) id<ATShrinkInfoViewDelegate> delegate;

@property (nonatomic, assign) ATShrinkInfoViewStatus status;

@end

NS_ASSUME_NONNULL_END
