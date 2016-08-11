//
//  ARRefreshHeaderView.h
//  GameApp
//
//  Created by ervinchen on 16/8/4.
//  Copyright © 2016年 ccnyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ARAndroidRefreshView;
@protocol AndroidRefreshDelegate <NSObject>

@required
- (void)androidRefreshView:(ARAndroidRefreshView *)refreshView beginRefreshingView:(UIView *)targetView;


@optional
- (BOOL)androidRefreshView:(ARAndroidRefreshView *)refreshView shouldRefreshView:(UIView *)targetView;
- (void)androidRefreshViewDidBeginDragging:(ARAndroidRefreshView *)refreshView;
- (void)androidRefreshViewDidCancel:(ARAndroidRefreshView *)refreshView;
- (void)androidRefreshViewDidComplete:(ARAndroidRefreshView *)refreshView;

@end

@interface ARAndroidRefreshView : UIView

@property (nonatomic,   weak) UIView* refreshView;
@property (nonatomic,   weak) id<AndroidRefreshDelegate> delegate;
@property (nonatomic, assign) CGFloat refreshOffset;

- (void)finishRefreshing;

@end
