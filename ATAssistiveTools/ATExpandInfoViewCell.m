//
//  ATExpandInfoViewCell.m
//  ATAssistiveTools
//
//  Created by liubo on 2017/5/31.
//  Copyright © 2017年 devliubo. All rights reserved.
//

#import "ATExpandInfoViewCell.h"

@interface ATExpandInfoViewCell ()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation ATExpandInfoViewCell

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self buildExpandInfoViewCell];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self buildExpandInfoViewCell];
    }
    return self;
}

- (void)buildExpandInfoViewCell
{
    self.backgroundColor = [UIColor clearColor];
    
    [self initProperties];
    
    [self initSubviews];
}

- (void)initProperties
{
    _titleNormalColor = [UIColor blackColor];
    _titleFont = [UIFont systemFontOfSize:15];
}

- (void)initSubviews
{
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.numberOfLines = 1;
    _titleLabel.textColor = _titleNormalColor;
    _titleLabel.font = _titleFont;
    
    [self addSubview:_titleLabel];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_titleLabel);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_titleLabel]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_titleLabel]|" options:0 metrics:nil views:views]];
}

#pragma mark - Override

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.title = @"";
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    self.titleLabel.textColor = selected ? _titleSelectColor : _titleNormalColor;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLabel.text = _title;
}

- (void)setTitleFont:(UIFont *)titleFont
{
    _titleFont = titleFont;
    self.titleLabel.font = _titleFont;
}

- (void)setTitleNormalColor:(UIColor *)titleNormalColor
{
    _titleNormalColor = titleNormalColor;
    if (!self.selected)
    {
        self.titleLabel.textColor = _titleNormalColor;
    }
}

- (void)setTitleSelectColor:(UIColor *)titleSelectColor
{
    _titleSelectColor = titleSelectColor;
    if (self.selected)
    {
        self.titleLabel.textColor = _titleSelectColor;
    }
}

@end
