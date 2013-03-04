//
//  KMWordPressPost.h
//  
//
//  Created by Karl Monaghan on 30/09/2012.
//  Copyright (c) 2012 Crayons and Brown Paper. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KMWordPressPostAuthor;
@class KMWordPressPostAttachment;
@class KMWordPressPostComment;

@interface KMWordPressPost : NSObject

@property (nonatomic, strong) NSArray *attachments;
@property (nonatomic, strong) KMWordPressPostAuthor *author;
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSNumber *commentCount;
@property (nonatomic, strong) NSArray *comments;
@property (nonatomic, strong) NSString *commentStatus;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSDate *postDate;
@property (nonatomic, strong) NSString *excerpt;
@property (nonatomic, strong) NSString *modified;
@property (nonatomic, strong) NSNumber *kMWordPressPostId;
@property (nonatomic, strong) NSString *slug;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *titlePlain;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *thumbnail;
@property (strong, nonatomic) NSString *previousUrl;
@property (strong, nonatomic) NSString *nextUrl;
@property (strong, nonatomic) NSString *previousTitle;
@property (strong, nonatomic) NSString *nextTitle;

+ (KMWordPressPost *)instanceFromDictionary:(NSDictionary *)aDictionary;

- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

- (NSString *)getThumbnailUrl;
- (KMWordPressPostAttachment *)findAttachment:(NSString *)url;
- (NSInteger)findAttachmentIndex:(NSString *)url;
- (BOOL)isPhotogallery;
- (NSString *)formattedDate;
- (NSString *)relativeDate;
- (void)addComment:(KMWordPressPostComment *)comment;
@end
