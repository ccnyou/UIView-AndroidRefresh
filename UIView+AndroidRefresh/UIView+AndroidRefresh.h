//
//  UIView+AndroidRefresh.h
//  GameApp
//
//  Created by ervinchen on 16/8/4.
//  Copyright © 2016年 ccnyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARAndroidRefreshView.h"

@interface UIView (AndroidRefresh)
@property (nonatomic) ARAndroidRefreshView* ar_headerView;

- (void)ar_addAndroidRefreshWithDelegate:(id<AndroidRefreshDelegate>)delegate;

@end
