//
//  UIView+AndroidRefresh.m
//  GameApp
//
//  Created by ervinchen on 16/8/4.
//  Copyright © 2016年 ccnyou. All rights reserved.
//

#import <objc/runtime.h>
#import "UIView+AndroidRefresh.h"
#import "Masonry.h"

static const CGFloat kHeaderViewHeight = 55.0f;

@implementation UIView (AndroidRefresh)

- (void)ar_addAndroidRefreshWithDelegate:(id<AndroidRefreshDelegate>)delegate {
    ARAndroidRefreshView* header = [[ARAndroidRefreshView alloc] init];
    header.refreshView = self;
    header.delegate = delegate;
    header.backgroundColor = [UIColor clearColor];
    [self addSubview:header];
    [header mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.height.mas_equalTo(kHeaderViewHeight);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(-kHeaderViewHeight);
    }];
    
    self.ar_headerView = header;
}

#pragma mark - header

static char ARRefreshHeaderKey;
- (void)setAr_headerView:(ARAndroidRefreshView *)ar_headerView {
    if (ar_headerView != self.ar_headerView) {
        [self.ar_headerView removeFromSuperview];
        
        [self willChangeValueForKey:@"header"];
        objc_setAssociatedObject(self, &ARRefreshHeaderKey,
                                 ar_headerView,
                                 OBJC_ASSOCIATION_ASSIGN);
        [self didChangeValueForKey:@"header"];
    }
}

- (ARAndroidRefreshView *)ar_headerView {
    return objc_getAssociatedObject(self, &ARRefreshHeaderKey);
}

@end
