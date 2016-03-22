//
//  PullToRefreshView.h
//  baby
//
//  Created by 宝贝计画 on 15/11/10.
//  Copyright (c) 2015年 zhang da. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    RefreshPulling,
    RefreshNormal,
    RefreshLoading
} RefreshState;

@interface PullToRefreshView : UIView {
    
    RefreshState state;
    UIColor *titleColor;
    
    UIActivityIndicatorView *activityView;
}

@property (nonatomic, retain) NSDate *lastUpdatedDate;
@property (nonatomic, retain) UIColor *titleColor;
@property (nonatomic) RefreshState state;

@end