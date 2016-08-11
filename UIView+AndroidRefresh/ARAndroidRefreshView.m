//
//  ARRefreshHeaderView.m
//  GameApp
//
//  Created by ervinchen on 16/8/4.
//  Copyright © 2016年 ccnyou. All rights reserved.
//

#import "ARAndroidRefreshView.h"
#import "Masonry.h"

typedef NS_ENUM(NSInteger, ARRefreshStatus) {
    ARRefreshStatusReady,
    ARRefreshStatusDragging,
    ARRefreshStatusRefreshing
};

@interface ARAndroidRefreshView () <UIGestureRecognizerDelegate>

@property (nonatomic, assign) ARRefreshStatus status;
@property (nonatomic, assign) CGFloat offsetY;
@property (nonatomic, strong) UIImageView* roundArrowImageView;
@property (nonatomic, strong) NSTimer*  rotatingTimer;

@end

@implementation ARAndroidRefreshView

static CGFloat kRoundImageHeight        = 50.0f;       // 圆形图片大小
static CGFloat kPointPerDegree          = 1/5.0f;      // 多少像素转一度
static CGFloat kRefreshingOffsetY       = 20.0f;       // 至少要滚到这里才开始刷新
static CGFloat kRotatingTimeInterval    = 0.01f;       // 自转时间间隔
static CGFloat kBounceOffset            = 30.0f;       // 松手之后往下弹多少
static CGFloat kAotoRotating            = 0.04f;       // 自转参考系数

- (instancetype)init {
    self = [super init];
    if (self) {
        _refreshOffset = kRefreshingOffsetY;
    }
    
    return self;
}

- (void)setRefreshView:(UIView *)refreshView {
    if (_refreshView != refreshView) {
        _refreshView = refreshView;
        [self _addGestureRecognizer:refreshView];
    }
}

- (void)finishRefreshing {
    [self _endRefreshing];
}

- (UIImageView *)roundArrowImageView {
    if (!_roundArrowImageView) {
        _roundArrowImageView = [[UIImageView alloc] init];
        _roundArrowImageView.image = [UIImage imageNamed:@"refresh_round_arrow"];
        [self addSubview:_roundArrowImageView];
        [_roundArrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.centerX.mas_equalTo(self.mas_centerX);
            make.width.mas_equalTo(kRoundImageHeight);
            make.height.mas_equalTo(kRoundImageHeight);
        }];
    }
    
    return _roundArrowImageView;
}

#pragma mark - Private

- (void)_addGestureRecognizer:(UIView *)scrollView {
    UIPanGestureRecognizer* gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(_onGestureRecognizer:)];
    gestureRecognizer.delegate = self;
    [scrollView addGestureRecognizer:gestureRecognizer];
}

- (void)_beginDragging {
    [self.refreshView bringSubviewToFront:self]; // 避免被新加入的view挡住
    self.status = ARRefreshStatusDragging;
    [self _showDraggingStatus:0];
    
    if ([self.delegate respondsToSelector:@selector(androidRefreshViewDidBeginDragging:)]) {
        [self.delegate androidRefreshViewDidBeginDragging:self];
    }
}

- (void)_beginRefreshing {
    self.status = ARRefreshStatusRefreshing;
    self.refreshView.userInteractionEnabled = NO;
    [self _showBeginRefreshStatus:^{
        if ([self.delegate respondsToSelector:@selector(androidRefreshView:beginRefreshingView:)]) {
            [self.delegate androidRefreshView:self beginRefreshingView:self.refreshView];
        }
    }];
}

- (void)_cancelRefreshing {
    self.status = ARRefreshStatusReady;
    self.refreshView.userInteractionEnabled = YES;
    [self _hideRefreshingStatus];
    
    if ([self.delegate respondsToSelector:@selector(androidRefreshViewDidCancel:)]) {
        [self.delegate androidRefreshViewDidCancel:self];
    }
}

- (void)_endRefreshing {
    self.status = ARRefreshStatusReady;
    self.refreshView.userInteractionEnabled = YES;
    [self _hideRefreshingStatus];
    
    if ([self.delegate respondsToSelector:@selector(androidRefreshViewDidComplete:)]) {
        [self.delegate androidRefreshViewDidComplete:self];
    }
}

- (void)_hideRefreshingStatus {
    CGRect frame = self.frame;
    frame.origin.y = -CGRectGetHeight(frame);
    
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(frame.origin.y);
    }];
    
    [UIView animateWithDuration:0.5f animations:^{
        [self layoutIfNeeded];
    }];
}

- (void)_showDraggingStatus:(CGFloat)dy {
    CGRect frame = self.frame;
    frame.origin.y += dy;
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(frame.origin.y);
    }];
    [self layoutIfNeeded];
    
    CGFloat degree = dy / kPointPerDegree / 180.0f * M_PI;
    self.roundArrowImageView.transform = CGAffineTransformRotate(self.roundArrowImageView.transform, degree);
}

- (void)_showBeginRefreshStatus:(void (^)(void))complete {
    id bounceBlock = ^{
        if (self.status == ARRefreshStatusReady) {
            return;
        }
        
        CGRect frame = self.frame;
        frame.origin.y += kBounceOffset;
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(frame.origin.y);
        }];
        [self layoutIfNeeded];
    };
    
    id moveUpBlock = ^{
        if (self.status == ARRefreshStatusReady) {
            return;
        }
        
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.refreshOffset);
        }];
        [self layoutIfNeeded];
    };
    
    [UIView animateWithDuration:0.05f
                     animations:bounceBlock
                     completion:^(BOOL finished)
     {
         if (finished) {
             [UIView animateWithDuration:0.5f animations:moveUpBlock completion:^(BOOL finished) {
                 if (finished && complete) {
                     complete();
                 }
             }];
         }
     }];
    
    [self _showRefreshingStatus];
}

- (void)_showRefreshingStatus {
    self.rotatingTimer = [NSTimer scheduledTimerWithTimeInterval:kRotatingTimeInterval
                                                          target:self
                                                        selector:@selector(_onRotatingTimer:)
                                                        userInfo:nil
                                                         repeats:YES];
}

#pragma mark - Gesture

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint p = [gestureRecognizer translationInView:gestureRecognizer.view];
    CGFloat dx = fabs(p.x);
    CGFloat dy = fabs(p.y);
    if (dx > dy) {
        // 手势是横着滑动的
        return NO;
    }
    
    return YES;
}

- (void)_onGestureRecognizer:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateChanged) {
        [self _onPanChanged:sender];
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        [self _onPanEnded:sender];
    } else if (sender.state == UIGestureRecognizerStateBegan) {
        [self _onPanBegan:sender];
    }
}

- (void)_onPanChanged:(UIPanGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateChanged) {
        return;
    }
    
    CGPoint p = [sender translationInView:sender.view];
    if (p.y < 0) {
        [self _onPanUpChanged:sender];
    } else if (p.y > 0) {
        [self _onPanDownChanged:sender];
    }
    
    [sender setTranslation:CGPointZero inView:sender.view];
}

- (void)_onPanUpChanged:(UIPanGestureRecognizer *)sender {
    if (self.status == ARRefreshStatusDragging) {
        CGPoint p = [sender translationInView:sender.view];
        CGFloat dy = -fabs(p.y);
        self.offsetY += dy;
        [self _showDraggingStatus:dy];
    }
}

- (void)_onPanDownChanged:(UIPanGestureRecognizer *)sender {
    if (self.status == ARRefreshStatusReady) {
        CGPoint p = [sender translationInView:sender.view];
        CGFloat dx = fabs(p.x);
        CGFloat dy = fabs(p.y);
        if (dx > dy) {
            return;
        }
        
        BOOL shouldBegin = YES;
        if ([self.delegate respondsToSelector:@selector(androidRefreshView:shouldRefreshView:)]) {
            shouldBegin = [self.delegate androidRefreshView:self shouldRefreshView:self.refreshView];
        }
        
        if (!shouldBegin) {
            return;
        }
        
        [self _beginDragging];
    } else if (self.status == ARRefreshStatusDragging) {
        CGPoint p = [sender translationInView:sender.view];
        CGFloat dy = fabs(p.y);
        self.offsetY += dy;
        [self _showDraggingStatus:dy];
    } else {
        // 正在刷新，忽略其他动作
    }
}

- (void)_onPanBegan:(UIPanGestureRecognizer *)sender {
}

- (void)_onPanEnded:(UIPanGestureRecognizer *)sender {
    if (self.status == ARRefreshStatusDragging) {
        CGFloat offsetY = CGRectGetMinY(self.frame);
        if (offsetY >= self.refreshOffset) {
            [self _beginRefreshing];
        } else {
            [self _cancelRefreshing];
        }
    } else {
        self.status = ARRefreshStatusReady;
    }
}

- (void)_onPan:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateChanged) {
        [self _onPanChanged:sender];
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        [self _onPanEnded:sender];
    } else if (sender.state == UIGestureRecognizerStateBegan) {
        [self _onPanBegan:sender];
    }
}

#pragma mark - Event

- (void)_onRotatingTimer:(NSTimer *)timer {
    if (timer != self.rotatingTimer) {
        return;
    }
    
    if (self.status != ARRefreshStatusRefreshing) {
        [self.rotatingTimer invalidate];
        self.rotatingTimer = nil;
        return;
    }
    
    CGFloat degree = kAotoRotating * M_PI;
    self.roundArrowImageView.transform = CGAffineTransformRotate(self.roundArrowImageView.transform, degree);
}


@end
