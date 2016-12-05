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
// 通知刷新页面
- (void)androidRefreshView:(ARAndroidRefreshView *)refreshView beginRefreshingView:(UIView *)targetView;

@optional
// 是否需要刷新，默认YES
- (BOOL)androidRefreshView:(ARAndroidRefreshView *)refreshView shouldRefreshView:(UIView *)targetView;
// 开始被拖拽
- (void)androidRefreshViewDidBeginDragging:(ARAndroidRefreshView *)refreshView;
// 刷新动作被取消，用户没有拉到 refreshOffset 会触发取消刷新逻辑
- (void)androidRefreshViewDidCancel:(ARAndroidRefreshView *)refreshView;
// 刷新完成
- (void)androidRefreshViewDidComplete:(ARAndroidRefreshView *)refreshView;
@end

@interface ARAndroidRefreshView : UIView
@property (nonatomic,   weak) UIView* refreshView;
@property (nonatomic,   weak) id<AndroidRefreshDelegate> delegate;
@property (nonatomic, assign) CGFloat refreshOffset;         // 至少拉倒这里才开始刷新
@property (nonatomic, assign) CGFloat maxRefreshOffset;      // 最低可以拉到这里
@property (nonatomic, assign) CGFloat refreshPosition;       // 弹到这里进行刷新
@property (nonatomic, assign) NSTimeInterval refreshTimeout; // 刷新超时时间，默认10s

// 页面完成刷新动作
- (void)finishRefreshing;
// 实际占用高度，方便计算一些offset
- (CGFloat)height;

@end
