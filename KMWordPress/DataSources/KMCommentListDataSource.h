//
//  KMCommentListDataSource.h
//  KMWordPress
//
//  Created by Karl Monaghan on 22/10/2012.
//  Copyright (c) 2012 Crayons and Brown Paper. All rights reserved.
//

#import "KMDataSource.h"

@class KMWordPressPost;
@class KMCommentListViewController;

@interface KMCommentListDataSource : KMDataSource
@property(weak, nonatomic) KMCommentListViewController *parentViewController;

- (id)initWithPost:(KMWordPressPost *)post;
@end
