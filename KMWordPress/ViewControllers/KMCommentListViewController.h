//
//  KMCommentListViewController.h
//  KMWordPress
//
//  Created by Karl Monaghan on 22/10/2012.
//  Copyright (c) 2012 Crayons and Brown Paper. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SSPullToRefresh.h"

#import "KMViewController.h"

@class KMWordPressPost;
@class KMWordPressPostComment;

@interface KMCommentListViewController : KMViewController <UITableViewDelegate, SSPullToRefreshViewDelegate>
- (id)initWithPost:(KMWordPressPost *)post withFullScreen:(BOOL)fullscreen;
- (void)replyToComment:(KMWordPressPostComment *)comment;
- (void)showWebPage:(NSURL *)URL;
@end
