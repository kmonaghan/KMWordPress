//
//  KMWordPressAPIClient.m
//  KMWordPress
//
//  Created by Karl Monaghan on 21/10/2012.
//  Copyright (c) 2012 Crayons and Brown Paper. All rights reserved.
//

#import "KMWordPressAPIClient.h"

#import "AFJSONRequestOperation.h"

#import "KMWordPressPost.h"

static NSString * const kKMWordpressURLString =  @"http://www.broadsheet.ie/";
//static NSString * const kKMWordpressURLString =  @"http://broadsheet.karlmonaghan.com/";

@implementation KMWordPressAPIClient
+ (instancetype)sharedClient
{
    static KMWordPressAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[KMWordPressAPIClient alloc] initWithBaseURL:[NSURL URLWithString:kKMWordpressURLString]];
    });
    
    return _sharedClient;
}

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    
    return self;
}

- (void)loadFromPostId:(NSString *)postId
           withSuccess:(void (^)(KMWordPressPost* post))success
           withFailure:(void (^)(NSError *error))failure
{
    return;
    
    [self getPath:@""
       parameters:@{@"json" : @"get_post", @"post_id" : postId}
          success:^(AFHTTPRequestOperation *operation, id JSON) {
              
              KMWordPressPost *post = [KMWordPressPost instanceFromDictionary:JSON[@"post"]];
              if (success)
              {
                  success(post);
              }
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              if (failure)
              {
                  failure(error);
              }
          }];
    
}

- (void)loadFromPostUrl:(NSURL *)postUrl
            withSuccess:(void (^)(KMWordPressPost* post))success
            withFailure:(void (^)(NSError *error))failure
{
    DLog(@"[postUrl path]: %@", [postUrl path]);
    [self getPath:[postUrl path]
       parameters:@{@"json" : @"1"}
          success:^(AFHTTPRequestOperation *operation, id JSON) {
              DLog(@"Json: %@", JSON);
              
              KMWordPressPost *post = [KMWordPressPost instanceFromDictionary:JSON[@"post"]];
              if (success)
              {
                  success(post);
              }
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              if (failure)
              {
                  failure(error);
              }
          }];
    
}
@end
