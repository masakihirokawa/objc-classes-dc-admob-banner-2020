//
//  ViewController.m
//  DCAdMobBannerSample
//
//  Created by Dolice on 2020/07/09.
//  Copyright © 2020 Dolice. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // AdMobバナーのY座標指定
    CGFloat const screenHeight = [[UIScreen mainScreen] bounds].size.height;
    CGFloat const homeIndicatorHeight = 34;
    CGFloat const bannerHeight = 50;
    CGFloat const bannerY = screenHeight - bannerHeight - homeIndicatorHeight;
    
    // AdMobバナーの表示
    [[DCAdMobBanner sharedManager] showAdBanner:self yPos:bannerY fadeInDuration:0.0
                              useAdaptiveBanner:YES useSmartBanner:NO usePersonalizedAds:YES];
}


@end
