//
//  ATExpandInfoViewCell.h
//  ATAssistiveTools
//
//  Created by liubo on 2017/5/31.
//  Copyright © 2017年 devliubo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATExpandInfoViewCell : UICollectionViewCell

@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIColor *titleNormalColor;
@property (nonatomic, strong) UIColor *titleSelectColor;

@end

NS_ASSUME_NONNULL_END
