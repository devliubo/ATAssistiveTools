//
//  ATExpandInfoView.h
//  ATAssistiveTools
//
//  Created by liubo on 2017/5/27.
//  Copyright © 2017年 devliubo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATCustomViewProtocol.h"

#define kATExpandViewTopHeight      30.f
#define kATExpandViewDetailHeight   450.f

#define kATExpandViewWidth          320.f
#define kATExpandViewHeight         (kATExpandViewDetailHeight+kATExpandViewTopHeight)

#define kATExpandViewThemeCloor     [UIColor colorWithRed:53/255.0 green:117/255.0 blue:255/255.0 alpha:1]

NS_ASSUME_NONNULL_BEGIN

@class ATExpandInfoView;

@protocol ATExpandInfoViewDelegate <NSObject>
@required

- (void)expandInfoViewCloseAction:(ATExpandInfoView *)expandView;

@end

@interface ATExpandInfoView : UIView

@property (nonatomic, weak) id<ATExpandInfoViewDelegate> delegate;

@property (nonatomic, readonly) NSArray<NSString *> *currentTitles;
- (void)addCustomView:(UIView <ATCustomViewProtocol>*)aView forTitle:(NSString *)aTitle;
- (void)removeCustiomViewForTitle:(NSString *)aTitle;
- (void)removeAllCustomViews;

//default [UIFont systemFontOfSize:15]
@property (nonatomic, strong) UIFont *titleFont;
//default [UIColor blackColor]
@property (nonatomic, strong) UIColor *titleNormalColor;
//default kATExpandViewThemeCloor
@property (nonatomic, strong) UIColor *titleSelectColor;

@end

@interface ATExpandInfoView (Private)

- (void)expandInfoViewWillShrink;
- (void)expandInfoViewDidShrink;
- (void)expandInfoViewWillExpand;
- (void)expandInfoViewDidExpand;

@end

NS_ASSUME_NONNULL_END
