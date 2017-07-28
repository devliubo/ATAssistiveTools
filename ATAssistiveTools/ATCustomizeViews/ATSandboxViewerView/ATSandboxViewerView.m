//
//  ATSandboxViewerView.m
//  ATAssistiveTools
//
//  Created by liubo on 2017/7/16.
//  Copyright © 2017年 devliubo. All rights reserved.
//

#import "ATSandboxViewerView.h"
#import <GCDWebUploader.h>

NSString * const ATSandboxViewerViewSelecteFileNotification = @"ATSandboxViewerViewSelecteFileNotification";
NSString * const ATSandboxViewerViewFilePathKey = @"ATSandboxViewerViewFilePath";

#pragma mark - ATFileItem

typedef NS_ENUM(NSUInteger, ATFileItemType) {
    ATFileItemBack,
    ATFileItemFile,
    ATFileItemDirectory,
};

@interface ATFileItem : NSObject

@property (nonatomic, copy) NSString *itemName;
@property (nonatomic, copy) NSString *itemPath;
@property (nonatomic, assign) ATFileItemType itemType;

@end

@implementation ATFileItem
@end

#pragma mark - ATSandboxViewerView

@interface ATSandboxViewerView ()<UITableViewDelegate, UITableViewDataSource, GCDWebUploaderDelegate>

@property (nonatomic, strong) UIButton *webServerButton;
@property (nonatomic, strong) UITableView *mainTableView;

@property (nonatomic, strong) NSString *currentPath;
@property (nonatomic, strong) NSArray<ATFileItem *> *allItems;

@property (nonatomic, strong) GCDWebUploader *webUploader;

@end

@implementation ATSandboxViewerView

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self buildSandboxViewerView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self buildSandboxViewerView];
    }
    return self;
}

- (void)buildSandboxViewerView
{
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self initProperties];
    
    [self initSubviews];
}

- (void)initProperties
{
    _currentPath = NSHomeDirectory();
    _allItems = @[];
}

- (void)initSubviews
{
    self.webServerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.webServerButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.webServerButton.layer.borderColor = [UIColor blueColor].CGColor;
    self.webServerButton.layer.borderWidth = 0.5;
    self.webServerButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [self.webServerButton setTitle:@"Start" forState:UIControlStateNormal];
    [self.webServerButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.webServerButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [self.webServerButton addTarget:self action:@selector(webServerButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.webServerButton];
    
    self.mainTableView = [[UITableView alloc] init];
    self.mainTableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    self.mainTableView.backgroundColor = [UIColor whiteColor];
    self.mainTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    [self addSubview:self.mainTableView];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_webServerButton, _mainTableView);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_webServerButton(==width)]" options:0 metrics:@{@"width":@(80)} views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_webServerButton(==height)]" options:0 metrics:@{@"height":@(20)} views:views]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_mainTableView]-5-|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_webServerButton]-10-[_mainTableView]-10-|" options:0 metrics:nil views:views]];
}

#pragma mark - ATCustomViewProtocol

- (void)customViewDidAppear
{
    [self loadAllItemInPath:self.currentPath];
}

#pragma mark - Methods

- (void)loadAllItemInPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableArray<ATFileItem *> *resultItems = [[NSMutableArray alloc] init];
    
    if (path == nil || path.length <= 0 || [path isEqualToString:NSHomeDirectory()])
    {
        path = NSHomeDirectory();
    }
    else
    {
        // add parents item
        ATFileItem *parentsItem = [[ATFileItem alloc] init];
        parentsItem.itemName = @"< ../";
        parentsItem.itemPath = [path stringByDeletingLastPathComponent];
        parentsItem.itemType = ATFileItemBack;
        
        [resultItems addObject:parentsItem];
    }
    
    NSError *error = nil;
    NSArray<NSString *> *allFileNames = [fileManager contentsOfDirectoryAtPath:path error:&error];
    if (error != nil)
    {
        NSLog(@"Load Path Failed:{%@ - %@}", path, error.description);
        return;
    }
    
    for (NSString *aFileName in allFileNames)
    {
        // ignore hidden files (files that begin with a period character)
        if ([[aFileName lastPathComponent] hasPrefix:@"."])
        {
            continue;
        }
        
        BOOL isDirectory = false;
        NSString* fullPath = [path stringByAppendingPathComponent:aFileName];
        [fileManager fileExistsAtPath:fullPath isDirectory:&isDirectory];
        
        ATFileItem *aItem = [[ATFileItem alloc] init];
        aItem.itemPath = fullPath;
        if (isDirectory)
        {
            // @"U0001F4C1" -> 📁
            aItem.itemName = [NSString stringWithFormat:@"\U0001F4C1 %@", aFileName];
            aItem.itemType = ATFileItemDirectory;
        }
        else
        {
            // @"\U0001F4C4" -> 📄
            aItem.itemName = [NSString stringWithFormat:@"\U0001F4C4 %@", aFileName];
            aItem.itemType = ATFileItemFile;
        }
        
        [resultItems addObject:aItem];
    }
    
    self.allItems = resultItems;
    self.currentPath = path;
    
    [self.mainTableView reloadData];
}

#pragma mark - Button Action

- (void)webServerButtonAction:(UIButton *)sender
{
    if (self.webUploader == nil)
    {
        NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        self.webUploader = [[GCDWebUploader alloc] initWithUploadDirectory:documentsPath];
        self.webUploader.delegate = self;
        [self.webUploader start];
        
        NSLog(@"Visit %@ in your web browser", self.webUploader.serverURL);
        
        [self.webServerButton setTitle:@"Stop" forState:UIControlStateNormal];
    }
    else
    {
        [self.webUploader stop];
        self.webUploader.delegate = nil;
        self.webUploader = nil;
        
        [self.webServerButton setTitle:@"Start" forState:UIControlStateNormal];
    }
}

- (void)refreshItemsIfNeedForPath:(NSString *)path
{
    
}

#pragma mark - GCDWebUploaderDelegate

- (void)webUploader:(GCDWebUploader*)uploader didUploadFileAtPath:(NSString*)path
{
    [self refreshItemsIfNeedForPath:path];
}

- (void)webUploader:(GCDWebUploader*)uploader didMoveItemFromPath:(NSString*)fromPath toPath:(NSString*)toPath
{
    [self refreshItemsIfNeedForPath:fromPath];
    [self refreshItemsIfNeedForPath:toPath];
}

- (void)webUploader:(GCDWebUploader*)uploader didDeleteItemAtPath:(NSString*)path
{
    [self refreshItemsIfNeedForPath:path];
}

- (void)webUploader:(GCDWebUploader*)uploader didCreateDirectoryAtPath:(NSString*)path
{
    [self refreshItemsIfNeedForPath:[path stringByDeletingLastPathComponent]];
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.allItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= self.allItems.count)
    {
        return nil;
    }
    
    static NSString *cellIdentifier = @"ATSandboxViewerCellIdentifier";
    UITableViewCell *aCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (aCell == nil)
    {
        aCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        aCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    ATFileItem *aItem = [self.allItems objectAtIndex:indexPath.row];
    
    aCell.textLabel.text = aItem.itemName;
    if (aItem.itemType == ATFileItemBack)
    {
        aCell.accessoryType = UITableViewCellAccessoryNone;
    }
    else if (aItem.itemType == ATFileItemFile)
    {
        aCell.accessoryType = UITableViewCellAccessoryDetailButton;
    }
    else if (aItem.itemType == ATFileItemDirectory)
    {
        aCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else
    {
        aCell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return aCell;
}

#pragma mark - UITableViewDataSource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.row >= self.allItems.count)
    {
        return;
    }
    
    ATFileItem *aItem = [self.allItems objectAtIndex:indexPath.row];
    if (aItem.itemType == ATFileItemBack)
    {
        [self loadAllItemInPath:[self.currentPath stringByDeletingLastPathComponent]];
    }
    else if (aItem.itemType == ATFileItemFile)
    {
        [self handleFileAtPath:aItem.itemPath];
    }
    else if (aItem.itemType == ATFileItemDirectory)
    {
        [self loadAllItemInPath:aItem.itemPath];
    }
    else
    {
        NSLog(@"Item Type Error!");
    }
}

#pragma mark - Handle File

- (void)handleFileAtPath:(NSString*)path
{
    // send notification
    [[NSNotificationCenter defaultCenter] postNotificationName:ATSandboxViewerViewSelecteFileNotification object:nil userInfo:@{ATSandboxViewerViewFilePathKey:path}];
    
    // present shared menu
    NSArray *objectsToShare = @[[NSURL fileURLWithPath:path]];
    
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    NSArray *excludedActivities = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
                                    UIActivityTypePostToWeibo,
                                    UIActivityTypeMessage, UIActivityTypeMail,
                                    UIActivityTypePrint, UIActivityTypeCopyToPasteboard,
                                    UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,
                                    UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
                                    UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
    controller.excludedActivityTypes = excludedActivities;
    
    if ([(NSString *)[UIDevice currentDevice].model hasPrefix:@"iPad"])
    {
        controller.popoverPresentationController.sourceView = self;
        controller.popoverPresentationController.sourceRect = CGRectMake([UIScreen mainScreen].bounds.size.width * 0.5, [UIScreen mainScreen].bounds.size.height, 10, 10);
    }
    
    [[[[ATAssistiveTools sharedInstance] mainWindow] rootViewController] presentViewController:controller animated:YES completion:nil];
}

@end
