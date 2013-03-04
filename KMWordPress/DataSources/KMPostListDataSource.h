//
//  KMPostListDataSource.h
//  KMWordPress
//
//  Created by Karl Monaghan on 30/09/2012.
//  Copyright (c) 2012 Crayons and Brown Paper. All rights reserved.
//

#import "KMDataSource.h"

typedef void (^KMSuccessBlock)(void);
typedef void (^KMFailureBlock)(NSError *error);

@class KMWordPressPost;
@class KMPostListViewController;
@class KMWordPressCategory;
@class KMWordPressTag;

@interface KMPostListDataSource : KMDataSource
@property (assign, nonatomic) NSInteger page;
@property (strong, nonatomic) KMWordPressCategory *category;
@property (strong, nonatomic) KMWordPressTag *tag;

@property (assign,nonatomic,getter=hasUpdates) BOOL updates;
@property (weak, nonatomic) KMPostListViewController *postViewController;

- (void)fetchRecentPosts;
- (void)fetchAuthorPosts:(NSNumber *)authorId;
- (void)fetchCategory:(NSNumber *)categoryId;
- (void)fetchTag:(NSNumber *)tagId;
- (void)loadMore:(BOOL)more withSuccess:(void (^)(void))success withFailure:(void (^)(NSError *error))failure;
- (void)loadPostFromUrl:(NSString *)postUrl withSuccess:(void (^)(KMWordPressPost* post))success withFailure:(void (^)(NSError *error))failure;
- (BOOL)canLoadMore;
- (void)searchPosts:(NSString *)search;
- (void)cancel;
- (void)addPost:(KMWordPressPost *)post;
@end
