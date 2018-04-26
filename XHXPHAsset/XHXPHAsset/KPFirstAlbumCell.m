//
//  KPFirstAlbumCell.m
//  XHXPHAsset
//
//  Created by KAOPU on 2018/4/25.
//  Copyright © 2018年 KAOPU. All rights reserved.
//

#import "KPFirstAlbumCell.h"
#import <SDCycleScrollView.h>

@interface KPFirstAlbumCell()<SDCycleScrollViewDelegate>

@property (weak, nonatomic) IBOutlet SDCycleScrollView *bannerView;


@end

@implementation KPFirstAlbumCell


- (void)setPicArray:(NSMutableArray *)picArray{
    _picArray = picArray;
    self.bannerView.localizationImageNamesGroup = picArray;
    self.bannerView.delegate = self;
    self.bannerView.bannerImageViewContentMode = UIViewContentModeScaleAspectFill;
    self.bannerView.placeholderImage = [UIImage imageNamed:@"placeholder"];
}
#pragma mark - SDCycleScrollViewDelegate

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    NSLog(@"########%lu",index);
}

@end
