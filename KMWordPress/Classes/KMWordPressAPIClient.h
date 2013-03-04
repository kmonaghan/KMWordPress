//
//  KMWordPressAPIClient.h
//  KMWordPress
//
//  Created by Karl Monaghan on 21/10/2012.
//  Copyright (c) 2012 Crayons and Brown Paper. All rights reserved.
//

#import "AFHTTPClient.h"

@class KMWordPressPost;

@interface KMWordPressAPIClient : AFHTTPClient
+ (instancetype)sharedClient;

- (void)loadFromPostId:(NSString *)postId
           withSuccess:(void (^)(KMWordPressPost* post))success
           withFailure:(void (^)(NSError *error))failure;
- (void)loadFromPostUrl:(NSURL *)postUrl
            withSuccess:(void (^)(KMWordPressPost* post))success
            withFailure:(void (^)(NSError *error))failure;
@end
