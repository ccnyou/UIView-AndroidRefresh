//
//  ViewController.m
//  Demo
//
//  Created by ervinchen on 16/8/12.
//  Copyright © 2016年 ccnyou. All rights reserved.
//

#import "ViewController.h"
#import "UIView+AndroidRefresh.h"

@interface ViewController () <AndroidRefreshDelegate>

@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor lightGrayColor];
    [self.view ar_addAndroidRefreshWithDelegate:self];
    self.view.ar_headerView.refreshOffset = 64.0f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - AndroidRefreshDelegate

- (void)androidRefreshViewDidCancel:(ARAndroidRefreshView *)refreshView {
    NSLog(@"%s %d Cancel", __FUNCTION__, __LINE__);
    self.label.text = @"Cancel";
}

- (void)androidRefreshViewDidComplete:(ARAndroidRefreshView *)refreshView {
    NSLog(@"%s %d Complete", __FUNCTION__, __LINE__);
    self.label.text = @"Complete";
}

- (void)androidRefreshView:(ARAndroidRefreshView *)refreshView beginRefreshingView:(UIView *)targetView {
    NSLog(@"%s %d Refresh View", __FUNCTION__, __LINE__);
    self.label.text = @"Refreshing";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5.0f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.view.ar_headerView finishRefreshing];
    });
}

@end
