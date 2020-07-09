# AdMobバナーを表示する「DCAdMobBanner」クラス（改訂版）

iPhoneアプリに[AdMob](https://admob.google.com/intl/ja/home/ "AdMob")のモバイルバナーを表示する「DCAdMobBanner」クラスを改訂しました。

[公式リファレンス](https://developers.google.com/admob/ios/banner?hl=ja "公式リファレンス")を参考にさせていただきました。ご使用の際はアプリIDと広告枠IDを指定してください。

## 今回の変更点

1. バナーのフェードイン秒数を指定できるようにしました
2. アダプティブバナーを使用するか指定できるようにしました
3. 広告のパーソナライズ設定を使用するか指定できるようにしました

## 導入準備

### 1. Info.plistの編集

[AdMob](https://admob.google.com/intl/ja/home/ "AdMob")のサイトからアプリIDを取得し、*Info.plist*に *GADApplicationIdentifier*の項目を追加し指定してください。

### 2. 広告枠IDの保持

```objective-c
NSString *const GAD_UNIT_ID = @"広告枠ID";
```

### 3. アプリ起動時に初期化

#### AppDelegate.h

```objective-c
@import GoogleMobileAds;
```

#### AppDelegate.m

```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // AdMobアプリID初期化
    [[GADMobileAds sharedInstance] startWithCompletionHandler:nil];
    
    return YES;
}
```

## クラスの使用方法

### 1. バナーの表示

```objective-c
[[DCAdMobBanner sharedManager] showAdBanner:self yPos:0.0 fadeInDuration:0.0
                              useAdaptiveBanner:YES useSmartBanner:NO usePersonalizedAds:YES];
```

### 2. バナーの削除

```objective-c
[[DCAdMobBanner sharedManager] removeAdBanner];
```

### 3. バナーの非表示

```objective-c
[[DCAdMobBanner sharedManager] hideAdBanner:YES];
```

### 4. バナーを最前面に配置

```objective-c
[[DCAdMobBanner sharedManager] insertAdBanner];
```

### 5. バナーの再読み込み

```objective-c
[[DCAdMobBanner sharedManager] reloadAdBanner:self usePersonalizedAds:YES];
```

### 6. ロード状況の取得

```objective-c
BOOL isLoadedAdBanner = [[DCAdMobBanner sharedManager] loaded];
```

## ソースコード

### DCAdMobBanner.h

```objective-c
#import <Foundation/Foundation.h>

@import GoogleMobileAds;

@interface DCAdMobBanner : NSObject <GADBannerViewDelegate> {
    CGFloat bannerX;
    CGFloat bannerY;
    BOOL    isFailed;
}

#pragma mark - property
@property (nonatomic, strong) GADBannerView    *gadView;
@property (nonatomic, strong) UIViewController *currentRootViewController;
@property (nonatomic, assign) BOOL             loaded;
@property (nonatomic, assign) CGFloat          fadeInDuration;
@property (nonatomic, assign) BOOL             useAdaptiveBanner;
@property (nonatomic, assign) BOOL             useSmartBanner;
@property (nonatomic, assign) BOOL             usePersonalizedAds;

#pragma mark - public method
+ (id)sharedManager;
- (void)showAdBanner:(UIViewController *)viewController yPos:(CGFloat)yPos fadeInDuration:(CGFloat)fadeInDuration
   useAdaptiveBanner:(BOOL)useAdaptiveBanner useSmartBanner:(BOOL)useSmartBanner usePersonalizedAds:(BOOL)usePersonalizedAds;
- (void)reloadAdBanner:(UIViewController *)viewController usePersonalizedAds:(BOOL)usePersonalizedAds;
- (void)removeAdBanner;
- (void)hideAdBanner:(BOOL)hidden;
- (void)insertAdBanner;

@end
```

### DCAdMobBanner.m

```objective-c
#import "DCAdMobBanner.h"

@implementation DCAdMobBanner

@synthesize gadView                   = _gadView;
@synthesize currentRootViewController = _currentRootViewController;
@synthesize loaded                    = _loaded;

#pragma mark - Shared Manager

static id sharedInstance = nil;

+ (id)sharedManager
{
    @synchronized(self) {
        if (!sharedInstance) {
            sharedInstance = [[self alloc] init];
        }
    }
    
    return sharedInstance;
}

#pragma mark - public method

// バナー表示
- (void)showAdBanner:(UIViewController *)viewController yPos:(CGFloat)yPos fadeInDuration:(CGFloat)fadeInDuration
   useAdaptiveBanner:(BOOL)useAdaptiveBanner useSmartBanner:(BOOL)useSmartBanner usePersonalizedAds:(BOOL)usePersonalizedAds
{
    self.currentRootViewController = viewController;
    self.fadeInDuration = fadeInDuration;
    self.useAdaptiveBanner = useAdaptiveBanner;
    self.useSmartBanner = useSmartBanner;
    self.usePersonalizedAds = usePersonalizedAds;
    
    if (!self.useAdaptiveBanner && !self.useSmartBanner) {
        CGFloat const screenWidth = [[UIScreen mainScreen] bounds].size.width;
        bannerX = roundf((screenWidth / 2) - (kGADAdSizeBanner.size.width / 2));
    }
    bannerY = yPos;
    
    [self showAdMobBanner:viewController.view];
}

// バナーの再読み込み
- (void)reloadAdBanner:(UIViewController *)viewController usePersonalizedAds:(BOOL)usePersonalizedAds
{
    self.currentRootViewController = viewController;
    self.usePersonalizedAds = usePersonalizedAds;
    
    if (self.gadView.superview) {
        [self loadAdMobBanner:self.currentRootViewController.view];
    }
}

// バナー削除
- (void)removeAdBanner
{
    if (self.gadView.superview) {
        [self.gadView removeFromSuperview];
    }
}

// バナー非表示
- (void)hideAdBanner:(BOOL)hidden
{
    if (self.gadView.superview) {
        self.gadView.hidden = hidden;
    }
}

// バナーを最前面に配置
- (void)insertAdBanner
{
    if (self.gadView.superview) {
        NSUInteger subviewsCount = [[self.currentRootViewController.view subviews] count];
        [self.currentRootViewController.view insertSubview:self.gadView atIndex:subviewsCount + 1];
    }
}

#pragma mark - AdMob Banner

- (void)showAdMobBanner:(UIView *)targetView
{
    if (!self.gadView) {
        if (self.useAdaptiveBanner) {
            self.gadView = [[GADBannerView alloc] initWithAdSize:GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(targetView.frame.size.width)];
        } else if (self.useSmartBanner) {
            self.gadView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
        } else {
            self.gadView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
        }
        self.gadView.adUnitID = GAD_TEST_MODE ? GAD_TEST_UNIT_ID : GAD_UNIT_ID;
        self.gadView.delegate = self;
        [self loadAdMobBanner:targetView];
    }
    
    if (![self.gadView.superview isEqual:targetView]) {
        [self.gadView removeFromSuperview];
        [self loadAdMobBanner:targetView];
    }
}

- (void)loadAdMobBanner:(UIView *)view
{
    self.gadView.rootViewController = self.currentRootViewController;
    
    CGRect gadViewFrame = self.gadView.frame;
    gadViewFrame.origin = CGPointMake(bannerX, bannerY);
    self.gadView.frame = gadViewFrame;
    [view addSubview:self.gadView];
    
    GADRequest *request = [GADRequest request];
    if (GAD_TEST_MODE) {
        [[GADMobileAds sharedInstance] requestConfiguration].testDeviceIdentifiers = @[kGADSimulatorID,
                                                                                       @"Test Device ID"];
    }
    
    if (!self.usePersonalizedAds) {
        GADExtras *extras = [[GADExtras alloc] init];
        extras.additionalParameters = @{@"npa": @"1"};
        [request registerAdNetworkExtras:extras];
    }
    //NSLog(@"DCAdMobBanner -> usePersonalizedAds: %d", self.usePersonalizedAds);
    
    [self.gadView loadRequest:request];
}

#pragma mark - delegate method

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
    BOOL const useFadeInAnimation = self.fadeInDuration > 0.0;
    if (useFadeInAnimation) {
        bannerView.alpha = 0.0;
        [UIView animateWithDuration:self.fadeInDuration animations:^{
            bannerView.alpha = 1.0;
        }];
    }
    
    _loaded = YES;
    
    isFailed = !_loaded;
}
- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error
{
    _loaded = NO;
    
    isFailed = !_loaded;
    
    // バナー再読み込み
    [self showAdBanner:self.currentRootViewController yPos:bannerY fadeInDuration:self.fadeInDuration
     useAdaptiveBanner:self.useAdaptiveBanner useSmartBanner:self.useSmartBanner usePersonalizedAds:self.usePersonalizedAds];
}

- (void)adViewWillPresentScreen:(GADBannerView *)bannerView
{
}

- (void)adViewDidDismissScreen:(GADBannerView *)bannerView
{
}

- (void)adViewWillDismissScreen:(GADBannerView *)bannerView
{
}

- (void)adViewWillLeaveApplication:(GADBannerView *)bannerView
{
}

@end
```