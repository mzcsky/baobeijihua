//
//  LessonViewController.h
//  baby
//
//  Created by zhang da on 14-3-3.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "BBViewController.h"
#import "PullTableView.h"
#import "SchoolCell.h"

@interface SchoolViewController : BBViewController
<UITableViewDataSource, UITableViewDelegate, PullTableViewDelegate,
UIScrollViewDelegate, SchoolCellDelegate> {

    PullTableView *schoolTable;
    NSMutableArray *schools;

}

@end
