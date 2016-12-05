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
@property (nonatomic, assign) CGFloat refreshOffset;        // 至少拉倒这里才开始刷新
@property (nonatomic, assign) CGFloat maxRefreshOffset;     // 最低可以拉到这里
@property (nonatomic, assign) CGFloat refreshPosition;      // 弹到这里进行刷新
@property (nonatomic, assign) NSTimeInterval refreshTimeout; // 刷新超时时间，默认10s

- (void)finishRefreshing;
- (CGFloat)height;

@end
