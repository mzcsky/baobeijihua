//
//  MoreViewController.h
//  baby
//
//  Created by zhang da on 14-4-1.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "BBViewController.h"

@interface SettingViewController : BBViewController
<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate> {
    
    UITableView *moreTable;
    
}

@end
