//
//  KMPostListDataSource.m
//  KMWordPress
//
//  Created by Karl Monaghan on 30/09/2012.
//  Copyright (c) 2012 Crayons and Brown Paper. All rights reserved.
//

#import "KMPostListDataSource.h"

#import "KMWordPressPost.h"
#import "KMWordPressCategory.h"
#import "KMWordPressTag.h"

#import "KMPostTableViewCell.h"
#import "KMLoadMoreCell.h"

@interface KMPostListDataSource()
@property (strong, nonatomic) NSDictionary *params;
@property (assign, nonatomic) NSInteger postTotal;
@property (strong, nonatomic) NSDate * yesterday;
@property (strong, nonatomic) NSDictionary *postIds;
@end

@implementation KMPostListDataSource
- (id)init
{
    self = [super init];
    
    if (self)
    {
        [self reset];
    }
    
    return self;
}

- (void)fetchRecentPosts
{
    self.params = @{@"json" : @"get_recent_posts"};
}

- (void)fetchAuthorPosts:(NSNumber *)authorId
{
    self.params = @{@"json" : @"get_author_posts", @"author_id" : authorId};
}

- (void)searchPosts:(NSString *)search
{
    self.params = @{@"json" : @"1", @"s" : search};
}

- (void)fetchCategory:(NSNumber *)categoryId
{
    self.params = @{@"json" : @"get_category_posts", @"id" : categoryId};
}

- (void)fetchTag:(NSNumber *)tagId
{
    self.params = @{@"json" : @"get_tag_posts", @"id" : tagId};
}

- (void)loadMore:(BOOL)more withSuccess:(void (^)(void))success withFailure:(void (^)(NSError *error))failure
{
    [self cancel];
    
    self.loading = YES;
    
    self.yesterday = [NSDate dateWithTimeIntervalSinceNow:-86400];
    
    self.page = (more) ? self.page + 1 : 1;
    
    NSMutableDictionary *fetchParams  = self.params.mutableCopy;
    fetchParams[@"page"] = [NSString stringWithFormat:@"%d", self.page];
        
    __block KMPostListDataSource *blockSelf = self;
    
    [[KMWordPressAPIClient sharedClient] getPath:@""
                                      parameters:fetchParams
                                         success:^(AFHTTPRequestOperation *operation, id JSON) {
                                             
                                             if (self.page == 1)
                                             {
                                                 [blockSelf reset];
                                             }
                                             
                                             for (NSDictionary *attributes in JSON[@"posts"])
                                             {
                                                 KMWordPressPost *post = [KMWordPressPost instanceFromDictionary:attributes];
                                                 //[mutablePosts addObject:post];
                                                 
                                                 [blockSelf addPost:post];
                                             }
                                             
                                             //blockSelf.items = mutablePosts;
                                             
                                             if (JSON[@"tag"])
                                             {
                                                 blockSelf.tag = [KMWordPressTag instanceFromDictionary:JSON[@"tag"]];
                                                 blockSelf.postTotal = [JSON[@"tag"][@"post_count"] intValue];
                                             }
                                             else if (JSON[@"category"])
                                             {
                                                 blockSelf.category = [KMWordPressCategory instanceFromDictionary:JSON[@"category"]];
                                                 blockSelf.postTotal = [JSON[@"category"][@"post_count"] intValue];
                                             }
                                             else
                                             {
                                                 blockSelf.postTotal = (JSON[@"count_total"]) ? [JSON[@"count_total"] intValue] : [JSON[@"post_count"] intValue];
                                             }
                                             
                                             if (success)
                                             {
                                                 success();
                                             }
                                             
                                             blockSelf.loading = NO;
     
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             DLog(@"Failure: %@", error);
                                             
                                             blockSelf.loading = NO;
                                             
                                             if (failure)
                                             {
                                                 failure(error);
                                             }
                                         }];
}

- (void)loadPostFromUrl:(NSString *)postUrl withSuccess:(void (^)(KMWordPressPost* post))success withFailure:(void (^)(NSError *error))failure
{
    __block KMPostListDataSource *blockSelf = self;
    
    [[KMWordPressAPIClient sharedClient] loadFromPostUrl:[NSURL URLWithString:postUrl]
                                             withSuccess:^(KMWordPressPost *post) {
                                                 [blockSelf addPost:post];
                                                 
                                                 if (success)
                                                 {
                                                     success(post);
                                                 }
                                                 
                                                 blockSelf.loading = NO;
                                             }
                                             withFailure:^(NSError *error){
                                                 if (failure)
                                                 {
                                                     failure(error);
                                                 }
                                             }];
}

- (BOOL)canLoadMore
{
    return (self.postTotal > [self.items count]);
}

- (void)cancel
{
    [[KMWordPressAPIClient sharedClient] cancelAllHTTPOperationsWithMethod:@"GET" path:@""];
}

- (void)reset
{
    self.page = 1;
    self.postTotal = 0;
    self.postIds = @{};
    self.items = @[];
}

- (void)addPost:(KMWordPressPost *)post
{
    if (!self.postIds[post.kMWordPressPostId])
    {
        NSMutableArray *posts = self.items.mutableCopy;
        [posts addObject:post];
        
        self.items = posts;
        
        NSMutableDictionary *ids = self.postIds.mutableCopy;
        ids[post.kMWordPressPostId] = [NSNumber numberWithInt:([self.items count] - 1)];
        
        self.postIds = ids;
        
        self.updates = YES;
    }
    else
    {
        NSMutableArray *posts = self.items.mutableCopy;
        [posts replaceObjectAtIndex:[self.postIds[post.kMWordPressPostId] intValue] withObject:post];
        
        self.items = posts;
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self canLoadMore])
    {
        return [self.items count] + 1;
    }
    
    return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [self.items count])
    {
        KMPostTableViewCell *cell = (KMPostTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"KMPostTableViewCell"];
        
        cell.yesterday = self.yesterday;
        cell.parentViewController = self.postViewController;
        
        KMWordPressPost *post = [self.items objectAtIndex:indexPath.row];
        
        [cell showPost:post];
        
        return cell;
    }
    else
    {
        KMLoadMoreCell *cell = (KMLoadMoreCell *)[tableView dequeueReusableCellWithIdentifier:@"KMLoadMoreCell"];
        [cell.activityIndicator startAnimating];
        
        return cell;
    }
}
@end
