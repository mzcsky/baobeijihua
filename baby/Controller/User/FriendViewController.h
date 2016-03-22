//
//  LessonViewController.h
//  baby
//
//  Created by zhang da on 14-3-3.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "BBViewController.h"
#import "PullTableView.h"
#import "UserCell.h"

@interface FriendViewController : BBViewController
<UITableViewDataSource, UITableViewDelegate, PullTableViewDelegate, UIScrollViewDelegate, UserCellDelegate> {

    int currentPage;
    PullTableView *userTable;
    NSMutableArray *users;

}

@property (nonatomic, assign) long userId;

- (id)initWithUser:(long)userId;

@end
