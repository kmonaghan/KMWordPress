//
//  KMWordPressPostComment.h
//  
//
//  Created by Karl Monaghan on 30/09/2012.
//  Copyright (c) 2012 Crayons and Brown Paper. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KMWordPressPostAuthor;

@interface KMWordPressPostComment : NSObject

@property (nonatomic, strong) NSNumber *kMWordPressPostCommentId;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *parent;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *avatar;
@property (nonatomic, strong) NSArray *childComments;
@property (nonatomic, strong) KMWordPressPostAuthor *author;
@property (nonatomic, strong) NSDate *commentDate;
@property (nonatomic, assign) NSInteger childLevel;

+ (KMWordPressPostComment *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;
- (NSString *)formattedDate;
@end
