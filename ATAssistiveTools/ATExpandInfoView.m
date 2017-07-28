//
//  ATExpandInfoView.m
//  ATAssistiveTools
//
//  Created by liubo on 2017/5/27.
//  Copyright © 2017年 devliubo. All rights reserved.
//

#import "ATExpandInfoView.h"
#import "ATExpandInfoViewCell.h"

#define kATExpandViewAlpha              0.95f
#define kATExpandVIewBorderWidth        0.4f
#define kATExpandViewDefaultPadding     10.f
#define kATExpandViewIndicatorHeight    4.f

#define kATExpandViewDuration           0.25f

@interface ATExpandInfoView ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UIView *topContentView;
@property (nonatomic, strong) UIView *detailContentView;

// top
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *indicatorView;
@property (nonatomic, readonly) NSDictionary *titleAttributes;

// detail
@property (nonatomic, readwrite) NSInteger selectedItemIndex;
@property (nonatomic, strong) NSMutableArray <NSString *> *allTitles;
@property (nonatomic, strong) NSMapTable <NSString *, UIView <ATCustomViewProtocol>*> *allContents;

@end

@implementation ATExpandInfoView

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self buildExpandInfoView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self buildExpandInfoView];
    }
    return self;
}

- (void)buildExpandInfoView
{
    self.layer.borderColor = [UIColor blackColor].CGColor;
    self.layer.borderWidth = 0.5f;
    self.layer.cornerRadius = 4.f;
    self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:kATExpandViewAlpha];
    self.clipsToBounds = YES;
    
    [self initProperties];
    
    [self createContentView];
    
    [self buildTopContentView];
}

- (void)initProperties
{
    _titleFont = [UIFont systemFontOfSize:15];
    _titleNormalColor = [UIColor blackColor];
    _titleSelectColor = kATExpandViewThemeCloor;
    
    _selectedItemIndex = -1;
    _allTitles = [[NSMutableArray alloc] init];
    _allContents = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsCopyIn valueOptions:NSPointerFunctionsStrongMemory capacity:0];
}

- (void)createContentView
{
    //top content view
    _topContentView = [[UIView alloc] initWithFrame:self.bounds];
    _topContentView.translatesAutoresizingMaskIntoConstraints = NO;
    _topContentView.backgroundColor = [UIColor clearColor];
    _topContentView.layer.borderColor = kATExpandViewThemeCloor.CGColor;
    _topContentView.layer.borderWidth = kATExpandVIewBorderWidth;
    
    //detail content view
    _detailContentView = [[UIView alloc] initWithFrame:self.bounds];
    _detailContentView.translatesAutoresizingMaskIntoConstraints = NO;
    _detailContentView.backgroundColor = [UIColor clearColor];
    
    [self addSubview:_topContentView];
    [self addSubview:_detailContentView];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_topContentView,_detailContentView);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_topContentView]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_detailContentView]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_topContentView(==height)][_detailContentView]|" options:0 metrics:@{@"height":@(kATExpandViewTopHeight)} views:views]];
}

- (void)buildTopContentView
{
    // close button
    _closeButton = [[UIButton alloc] init];
    _closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    _closeButton.backgroundColor = [UIColor clearColor];
    _closeButton.layer.borderColor = [UIColor blackColor].CGColor;
    _closeButton.layer.borderWidth = kATExpandVIewBorderWidth;
    
    [_closeButton addTarget:self action:@selector(closeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_closeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_closeButton setTitle:@"X" forState:UIControlStateNormal];
    
    // collection view
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _collectionView = [[UICollectionView alloc] initWithFrame:self.topContentView.bounds collectionViewLayout:layout];
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    _collectionView.backgroundColor = [UIColor clearColor];
    
    [_collectionView registerClass:[ATExpandInfoViewCell class] forCellWithReuseIdentifier:NSStringFromClass([ATExpandInfoViewCell class])];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.scrollEnabled = YES;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.contentInset = UIEdgeInsetsZero;
    
    // indicator view
    _indicatorView = [[UIView alloc] init];
    _indicatorView.userInteractionEnabled = NO;
    _indicatorView.backgroundColor = kATExpandViewThemeCloor;
    [_collectionView addSubview:_indicatorView];
    
    [self.topContentView addSubview:_closeButton];
    [self.topContentView addSubview:_collectionView];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_closeButton,_collectionView);
    [self.topContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_closeButton]|" options:0 metrics:nil views:views]];
    [self.topContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_collectionView]|" options:0 metrics:nil views:views]];
    [self.topContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_closeButton(==width)][_collectionView]|" options:0 metrics:@{@"width":@(kATExpandViewTopHeight)} views:views]];
}

- (NSDictionary *)titleAttributes
{
    return @{NSFontAttributeName:[self.titleFont copy],
             NSForegroundColorAttributeName:[self.titleNormalColor copy],
             NSBackgroundColorAttributeName:[self.titleSelectColor copy]};
}

#pragma mark - Private: Close Action

- (void)closeButtonAction:(UIButton *)button
{
    if (self.delegate)
    {
        [self.delegate expandInfoViewCloseAction:self];
    }
}

#pragma mark - Model

- (void)addTitle:(NSString *)title relateView:(UIView <ATCustomViewProtocol>*)view
{
    @synchronized (self.allTitles) {
        if ([self.allContents objectForKey:title])
        {
            [self.allTitles removeObject:title];
            [self.allContents removeObjectForKey:title];
        }
        
        if (view != nil)
        {
            [self.allTitles addObject:title];
            [self.allContents setObject:view forKey:title];
        }
        
        [self reloadExpandInfoViewData];
    }
}

- (void)deleteTitle:(NSString *)title
{
    @synchronized (self.allTitles) {
        if ([self.allContents objectForKey:title])
        {
            [self.allTitles removeObject:title];
            [self.allContents removeObjectForKey:title];
        }
        
        [self reloadExpandInfoViewData];
    }
}

- (void)deleteAllTitles
{
    @synchronized (self.allTitles) {
        [self.allTitles removeAllObjects];
        [self.allContents removeAllObjects];
        
        [self reloadExpandInfoViewData];
    }
}

- (void)reloadExpandInfoViewData
{
    [self.collectionView reloadData];
}

#pragma mark - Public: Interface

- (NSArray<NSString *> *)currentTitles
{
    @synchronized (self.allTitles) {
        return [self.allTitles copy];
    }
}

- (void)addCustomView:(UIView <ATCustomViewProtocol>*)aView forTitle:(NSString *)aTitle
{
    if (aTitle == nil || aTitle.length <= 0)
    {
        return;
    }
    
    [self addTitle:aTitle relateView:aView];
}

- (void)removeCustiomViewForTitle:(NSString *)aTitle
{
    if (aTitle == nil || aTitle.length <= 0)
    {
        return;
    }
    
    [self deleteTitle:aTitle];
}

- (void)removeAllCustomViews
{
    [self deleteAllTitles];
}

#pragma mark - Private: Methods

- (void)manualSelectedItemWithIndex:(NSInteger)index
{
    if (index >= self.allTitles.count || index < 0 || index == self.selectedItemIndex)
    {
        return;
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    [self.collectionView selectItemAtIndexPath:indexPath
                                      animated:YES
                                scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    
    [self collectionView:self.collectionView didSelectItemAtIndexPath:indexPath];
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.selectedItemIndex)
    {
        return;
    }
    
    self.selectedItemIndex = indexPath.row;
    
    ATExpandInfoViewCell *aCell = (ATExpandInfoViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    // indicator view frame && collection view scroll to item
    CGRect newFrame = CGRectMake(aCell.frame.origin.x, aCell.frame.size.height - kATExpandViewIndicatorHeight, aCell.frame.size.width, kATExpandViewIndicatorHeight);
    [UIView animateWithDuration:kATExpandViewDuration animations:^{
        self.indicatorView.frame = newFrame;
        [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    }];
    
    // update detail content view
    UIView<ATCustomViewProtocol> *viewForCell = [self.allContents objectForKey:aCell.title];
    
    // remove old views
    NSArray *allSubviews = self.detailContentView.subviews;
    for (UIView<ATCustomViewProtocol> *aView in allSubviews)
    {
        // will disappear
        if ([aView respondsToSelector:@selector(customViewWillDisappear)])
        {
            [aView customViewWillDisappear];
        }
        
        [aView removeFromSuperview];
        
        // did disappear
        if ([aView respondsToSelector:@selector(customViewDidDisappear)])
        {
            [aView customViewDidDisappear];
        }
    }
    
    // add new view
    if (viewForCell != nil)
    {
        viewForCell.frame = self.detailContentView.bounds;
        viewForCell.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        // will appear
        if ([viewForCell respondsToSelector:@selector(customViewWillAppear)])
        {
            [viewForCell customViewWillAppear];
        }
        
        [self.detailContentView addSubview:viewForCell];
        
        // did appear
        if ([viewForCell respondsToSelector:@selector(customViewDidAppear)])
        {
            [viewForCell customViewDidAppear];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // do nothing
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.allTitles count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ATExpandInfoViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ATExpandInfoViewCell class]) forIndexPath:indexPath];
    
    //set cell properties
    cell.title = self.allTitles[indexPath.row];
    cell.titleFont = self.titleFont;
    cell.titleNormalColor = self.titleNormalColor;
    cell.titleSelectColor = self.titleSelectColor;
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // size of cell
    CGSize size = [[self.allTitles objectAtIndex:indexPath.row] sizeWithAttributes:self.titleAttributes];
    CGSize resultSize = CGSizeMake(size.width + kATExpandViewDefaultPadding, collectionView.bounds.size.height);
    
    // if it's the first time to show indicator view, calculate view's frame from the first cell's size
    if (CGRectIsEmpty(self.indicatorView.frame) && indexPath.row == 0)
    {
        CGRect newFrame = CGRectMake(0, collectionView.bounds.size.height - kATExpandViewIndicatorHeight, 0, kATExpandViewIndicatorHeight);
        self.indicatorView.frame = newFrame;
    }
    
    return resultSize;
}

//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
//{
//    return UIEdgeInsetsZero;
//}
//
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
//{
//    return kATExpandViewDefaultPadding;
//}
//
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
//{
//    return kATExpandViewDefaultPadding;
//}

#pragma mark - Shrink && Expand

- (void)expandInfoViewWillShrink
{
    NSArray *allSubviews = self.detailContentView.subviews;
    for (UIView<ATCustomViewProtocol> *aView in allSubviews)
    {
        if ([aView respondsToSelector:@selector(customViewWillShrink)])
        {
            [aView customViewWillShrink];
        }
    }
}

- (void)expandInfoViewDidShrink
{
    NSArray *allSubviews = self.detailContentView.subviews;
    for (UIView<ATCustomViewProtocol> *aView in allSubviews)
    {
        if ([aView respondsToSelector:@selector(customViewDidShrink)])
        {
            [aView customViewDidShrink];
        }
    }
}

- (void)expandInfoViewWillExpand
{
    NSArray *allSubviews = self.detailContentView.subviews;
    for (UIView<ATCustomViewProtocol> *aView in allSubviews)
    {
        if ([aView respondsToSelector:@selector(customViewWillExpand)])
        {
            [aView customViewWillExpand];
        }
    }
}

- (void)expandInfoViewDidExpand
{
    NSArray *allSubviews = self.detailContentView.subviews;
    for (UIView<ATCustomViewProtocol> *aView in allSubviews)
    {
        if ([aView respondsToSelector:@selector(customViewDidExpand)])
        {
            [aView customViewDidExpand];
        }
    }
    
    // default select the first item
    if (self.selectedItemIndex < 0)
    {
        [self manualSelectedItemWithIndex:0];
    }
}

@end
