//
//  KMPostListViewController.h
//  KMWordPress
//
//  Created by Karl Monaghan on 30/09/2012.
//  Copyright (c) 2012 Crayons and Brown Paper. All rights reserved.
//
#import "SSPullToRefresh.h"

#import "KMViewController.h"

@class KMPostListDataSource;
@class KMPostTableViewCell;

@interface KMPostListViewController : KMViewController <UITableViewDelegate, SSPullToRefreshViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) KMPostListDataSource *dataSource;

- (id)initWithAuthorId:(NSNumber *)authorId;
- (id)initWithCategoryId:(NSNumber *)catergoryId;
- (id)initWithTagId:(NSNumber *)tagId;
- (void)endRefresh;
- (void)loadPosts:(BOOL)more;
- (void)finishedLoad:(BOOL)more;
- (void)viewPost:(KMPostTableViewCell *)cell;
@end
