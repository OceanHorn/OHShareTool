//
//  OHShareTool.m
//  OHShareTool
//
//  Created by 郭玉富 on 16/3/29.
//  Copyright © 2016年 郭玉富. All rights reserved.
//

#import "OHShareTool.h"
#import "UMSocial.h"
#import "OHSNSCollectionViewCell.h"

#define kContentViewHeight 90.0

#define kSCREEN_BOUNDS [UIScreen mainScreen].bounds
#define kSCREEN_WIDTH   kSCREEN_BOUNDS.size.width
#define kSCREEN_HEIGHT  kSCREEN_BOUNDS.size.height

#define kMIN_LINE_SPACING 0.5
//#define kMIN_INNER_SPACING 12.0
#define kCELL_WIDTH 47.0
#define kCELL_HEIGHT 67.0

#define kLEFT_MARGIN 20.0
#define kRIGHT_MARGIN  kLEFT_MARGIN
#define kTOP_MARGIN  kLEFT_MARGIN
#define kBOTTOM_MARGIN  kLEFT_MARGIN

#define kCOLLECTIONVIEW_HEIGHT  kCELL_HEIGHT
#define kBOTTOMCANCELBUTTON_HEIGHT  45

#define kBOTTOMCONTENTVIEW_HEIGHT (kLEFT_MARGIN * 2 + kCELL_HEIGHT + kBOTTOMCANCELBUTTON_HEIGHT)

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface OHShareTool () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIButton *coverButton;
@property (strong, nonatomic) UIButton *bottomCancelButton;
@property (strong, nonatomic) UIView *bottomContentView;

@property (strong, nonatomic) UICollectionView *socialCollectionView;
@property (strong, nonatomic) NSMutableArray<OHShareChannel *> *dataSource;

@property (nonatomic, assign) BOOL isShowing;

@property (nonatomic, copy) ShareBlock shareBlock;

@end

@implementation OHShareTool

+ (instancetype)sharedTool {
    
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

// 需要根据平台改变分享内容的分享方法
- (void)shareWithDelegate:(id)vc adjustContent:(AdjustableShareBlock)adjustableShareBlock {
    
    if (![self checkStatus]) {
        return;
    }
    
    [self showSelectionView];
    
    __weak typeof(self) weakSelf = self;
    __block OHShareContent *shareContent = [OHShareContent new];
    ShareBlock shareBlock = ^(OHShareType type) {
        if (adjustableShareBlock) {
            OHShareContent *newShareContent = adjustableShareBlock(type, shareContent);
            [weakSelf shareTitle:newShareContent.title text:newShareContent.text shareURL:newShareContent.shareURL imageURL:newShareContent.imageURL shareTo:type delegate:vc];
        }
    };
    self.shareBlock = shareBlock;
}

// 普通分享方法
- (void)shareTitle:(NSString *)title text:(NSString *)text shareURL:(NSString *)shareURL imageURL:(NSString *)imageURL delegate:(id)vc {
    
    if ([self checkStatus]) { return; }
    
    [self showSelectionView];
    
    __weak typeof(self) weakSelf = self;
    ShareBlock shareBlock = ^(OHShareType type) {
        [weakSelf shareTitle:title text:text shareURL:shareURL imageURL:imageURL shareTo:type delegate:vc];
    };
    self.shareBlock = shareBlock;
}

#pragma mark - Private
- (BOOL)checkStatus {
    BOOL check = YES;
    if (self.isShowing ) { check = NO; }
    if (0 == self.dataSource.count) {
        check = NO;
        NSString *message = @"没有可分享到的app哦~";
        if (!([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView setAlertViewStyle:UIAlertViewStyleDefault];
            [alertView show];
        } else {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *enter = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            
            [enter setValue:UIColorFromRGB(0xffa633) forKey:@"titleTextColor"];
            [alertController addAction:enter];
            
            UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
            UIViewController *topVC = rootVC;
            while (rootVC.presentedViewController) {
                topVC = rootVC.presentedViewController;
            }
            [topVC presentViewController:alertController animated:YES completion:nil];
        }
        
    }
    return check;
}
- (void)showSelectionView {
    
    self.isShowing = YES;
    
    [self.window addSubview:self.coverButton];
    [self.window addSubview:self.bottomContentView];
    
    self.bottomContentView.frame = CGRectMake(0, kSCREEN_HEIGHT, kSCREEN_WIDTH, kBOTTOMCONTENTVIEW_HEIGHT);
    
    [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:2.0 initialSpringVelocity:3.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.bottomContentView.frame = CGRectMake(0, kSCREEN_HEIGHT - kBOTTOMCONTENTVIEW_HEIGHT, kSCREEN_WIDTH, kBOTTOMCONTENTVIEW_HEIGHT);
    } completion:^(BOOL finished) {
    }];
    
}

- (void)shareTitle:(NSString *)title text:(NSString *)text shareURL:(NSString *)shareURL imageURL:(NSString *)imageURL shareTo:(OHShareType)type delegate:(id)vc {
    
    NSString *snsName;
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
    
    switch (type) {
        case OHShareTypeWechatSession:
            snsName = UMShareToWechatSession;
            [UMSocialData defaultData].extConfig.wechatSessionData.url = shareURL;
            [UMSocialData defaultData].extConfig.wechatSessionData.title = title;
            break;
        case OHShareTypeWechatTimeline:
            snsName = UMShareToWechatTimeline;
            [UMSocialData defaultData].extConfig.wechatTimelineData.url = shareURL;
            [UMSocialData defaultData].extConfig.wechatTimelineData.title = title;
            break;
        case OHShareTypeSinaWeiboNoApp:
            snsName = UMShareToSina;
            break;
        case OHShareTypeSinaWeiboApp:
            snsName = UMShareToSina;
            [UMSocialData defaultData].extConfig.sinaData.shareText = text;
            [UMSocialData defaultData].extConfig.sinaData.urlResource.url = shareURL;
            break;
        case OHShareTypeTencentQQ:
            snsName = UMShareToQQ;
            [UMSocialData defaultData].extConfig.qqData.url = shareURL;
            [UMSocialData defaultData].extConfig.qqData.title = title;
            [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
            break;
        case OHShareTypeTencentQzone:
            snsName = UMShareToQzone;
            [UMSocialData defaultData].extConfig.qzoneData.url = shareURL;
            [UMSocialData defaultData].extConfig.qzoneData.title = title;
            [UMSocialData defaultData].extConfig.qzoneData.shareText = text;
            [UMSocialData defaultData].extConfig.qzoneData.shareImage = [UIImage imageWithData:imageData];
            break;
        default:
            return;
            break;
    }
    
    [self shareTo:snsName text:text imageURL:imageURL delegate:vc];
}
- (void)shareTo:(NSString *)snsName text:(NSString *)text imageURL:(NSString *)imageURL delegate:(id)vc {
    UIImage *shareImage;
    if (imageURL == nil) {
        // 默认为应用图标
        shareImage = [UIImage imageNamed:@"about_us_logo"];
    }else{
        shareImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]]];
    }
    
    [[UMSocialControllerService defaultControllerService] setShareText:text shareImage:shareImage socialUIDelegate:vc];
    [UMSocialSnsPlatformManager getSocialPlatformWithName:snsName].snsClickHandler(vc,[UMSocialControllerService defaultControllerService], YES);
}

- (void)coverButtonClicked:(id)sender {
    
    [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:4.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.bottomContentView.frame = CGRectMake(0, kSCREEN_HEIGHT, kSCREEN_WIDTH, kBOTTOMCONTENTVIEW_HEIGHT);
    } completion:^(BOOL finished) {
        if (finished) {
            [self.window.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            self.isShowing = NO;
            _window.hidden = YES;
            _coverButton = nil;
            _window = nil;
        }
    }];

}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    OHSNSCollectionViewCell *cell = [OHSNSCollectionViewCell cellWithCollectionView:collectionView andIndexPath:indexPath];
    cell.channel = self.dataSource[indexPath.row];
    return cell;
}
#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.shareBlock) {
        OHShareChannel *channel = self.dataSource[indexPath.row];
        self.shareBlock(channel.type);
        self.shareBlock = nil;
        [self coverButtonClicked:nil];
    }
}


#pragma mark - getter
- (UIWindow *)window {
    if (_window == nil) {
        _window = [UIWindow new];
        _window.frame = [UIScreen mainScreen].bounds;
        _window.backgroundColor = [UIColor clearColor];
        _window.windowLevel = UIWindowLevelAlert;
        _window.hidden = NO;
    }
    return _window;
}
- (UIButton *)coverButton {
    if (_coverButton == nil) {
        _coverButton = [UIButton new];
        _coverButton.frame = [UIScreen mainScreen].bounds;
        _coverButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
        [_coverButton addTarget:self action:@selector(coverButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        _coverButton.frame = [UIScreen mainScreen].bounds;
    }
    return _coverButton;
}
- (UICollectionView *)socialCollectionView {
    if (_socialCollectionView == nil) {
        
        UICollectionViewFlowLayout *flowLayout =[[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = kMIN_LINE_SPACING;
        flowLayout.minimumInteritemSpacing = (CGRectGetWidth([[UIScreen mainScreen] bounds]) - kLEFT_MARGIN * 2 - kCELL_WIDTH * 5) / 4;
        flowLayout.itemSize = CGSizeMake(kCELL_WIDTH, kCELL_HEIGHT);
        
        _socialCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        [_socialCollectionView registerClass:[OHSNSCollectionViewCell class] forCellWithReuseIdentifier:@"OHSNSCollectionViewCell"];
        _socialCollectionView.backgroundColor = [UIColor whiteColor];
        _socialCollectionView.dataSource = self;
        _socialCollectionView.delegate = self;
    }
    return _socialCollectionView;
}
- (UIButton *)bottomCancelButton {
    if (_bottomCancelButton == nil) {
        _bottomCancelButton = [UIButton new];
        [_bottomCancelButton setTitle:@"取消" forState:UIControlStateNormal];
        _bottomCancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_bottomCancelButton setTitleColor:[UIColor colorWithRed:0x80/255.0 green:0x80/255.0 blue:0x80/255.0 alpha:1.0] forState:UIControlStateNormal];
        [_bottomCancelButton setBackgroundColor:[UIColor colorWithRed:0xf2/255.0 green:0xf2/255.0 blue:0xf2/255.0 alpha:1.0]];
        [_bottomCancelButton addTarget:self action:@selector(coverButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bottomCancelButton;
}
- (UIView *)bottomContentView {
    if (_bottomContentView == nil) {
        _bottomContentView = [UIView new];
        _bottomContentView.backgroundColor = [UIColor whiteColor];
        
        [_bottomContentView addSubview:self.socialCollectionView];
        self.socialCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
        [_bottomContentView addConstraint:[NSLayoutConstraint constraintWithItem:self.socialCollectionView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_bottomContentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:kLEFT_MARGIN]];
        [_bottomContentView addConstraint:[NSLayoutConstraint constraintWithItem:self.socialCollectionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_bottomContentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:kTOP_MARGIN]];
        [_bottomContentView addConstraint:[NSLayoutConstraint constraintWithItem:self.socialCollectionView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_bottomContentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-kLEFT_MARGIN]];
        [_bottomContentView addConstraint:[NSLayoutConstraint constraintWithItem:self.socialCollectionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:kCOLLECTIONVIEW_HEIGHT + kBOTTOM_MARGIN]];
        
        [_bottomContentView addSubview:self.bottomCancelButton];
        self.bottomCancelButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_bottomContentView addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomCancelButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_bottomContentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
        [_bottomContentView addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomCancelButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.socialCollectionView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
        [_bottomContentView addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomCancelButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_bottomContentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
        [_bottomContentView addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomCancelButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_bottomContentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
        
        UIView *line = [UIView new];
        line.backgroundColor = [UIColor colorWithRed:0xe3/255.0 green:0xe3/255.0 blue:0xe6/255.0 alpha:1.0];
        [_bottomContentView addSubview:line];
        line.translatesAutoresizingMaskIntoConstraints = NO;
        [_bottomContentView addConstraint:[NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_bottomContentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
        [_bottomContentView addConstraint:[NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_bottomContentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
        [_bottomContentView addConstraint:[NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.socialCollectionView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
        [_bottomContentView addConstraint:[NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0.45]];
    }
    return _bottomContentView;
}

- (NSMutableArray<OHShareChannel *> *)dataSource {
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray array];
        
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSURL *url = [bundle URLForResource:@"OHShareTool" withExtension:@"bundle"];
        NSBundle *imageBundle = [NSBundle bundleWithURL:url];
        
        if ([self APPCheckIfAppInstalled:@"weixin://"]) {
            
            UIImage* share_WechatSession = [UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"share_weixin" ofType:@"png"]];
            [_dataSource addObject:[OHShareChannel shareChannelWithImage:share_WechatSession type:OHShareTypeWechatSession]];
            
            UIImage* share_WechatTimeline = [UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"share_friend" ofType:@"png"]];
            [_dataSource addObject:[OHShareChannel shareChannelWithImage:share_WechatTimeline type:OHShareTypeWechatTimeline]];
        }
        
//        if ([self APCheckIfAppInstalled:@"sinaweibosso://"]) {
//        UIImage* share_SinaWeiboNoApp = [UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"share_weibo" ofType:@"png"]];
//        [_dataSource addObject:[OHShareChannel shareChannelWithImage:share_SinaWeiboNoApp type:OHShareTypeSinaWeiboNoApp]];
//        }
        if ([self APPCheckIfAppInstalled:@"sinaweibo://"] || [self APPCheckIfAppInstalled:@"sinaweibohd://"]) { // ]
//            [_dataSource removeLastObject];
            UIImage* share_SinaWeibo = [UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"share_weibo" ofType:@"png"]];
            [_dataSource addObject:[OHShareChannel shareChannelWithImage:share_SinaWeibo type:OHShareTypeSinaWeiboApp]];
        }
        
        if ([self APPCheckIfAppInstalled:@"mqq://"]) {
            
            UIImage* share_TencentQQ = [UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"share_qq" ofType:@"png"]];
            [_dataSource addObject:[OHShareChannel shareChannelWithImage:share_TencentQQ type:OHShareTypeTencentQQ]];
            
            UIImage* share_TencentQzone = [UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"share_qq_space" ofType:@"png"]];
            [_dataSource addObject:[OHShareChannel shareChannelWithImage:share_TencentQzone type:OHShareTypeTencentQzone]];
        }
    }
    return _dataSource;
}

-(BOOL)APPCheckIfAppInstalled:(NSString *)urlScheme {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlScheme]]) {
        NSLog(@"%@ installed", urlScheme);
        return YES;
    } else {
        return NO;
    }
}

@end

@implementation OHShareContent

@end
