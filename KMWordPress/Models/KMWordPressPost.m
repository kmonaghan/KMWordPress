//
//  KMWordPressPost.m
//  
//
//  Created by Karl Monaghan on 30/09/2012.
//  Copyright (c) 2012 Crayons and Brown Paper. All rights reserved.
//

#import "SORelativeDateTransformer.h"

#import "KMWordPressAPIClient.h"

#import "KMWordPressPost.h"

#import "KMWordPressPostAttachment.h"
#import "KMWordPressPostAuthor.h"
#import "KMWordPressCategory.h"
#import "KMWordPressPostComment.h"
#import "KMWordPressTag.h"

#import "KMWordPressPostAttachmentImages.h"
#import "KMWordPressImage.h"

static NSDateFormatter *sPostDateFormatter = nil;
static SORelativeDateTransformer *sRelativetDateFormatter = nil;

@implementation KMWordPressPost

+ (KMWordPressPost *)instanceFromDictionary:(NSDictionary *)aDictionary
{

    KMWordPressPost *instance = [[KMWordPressPost alloc] init];
    [instance setAttributesFromDictionary:aDictionary];
    return instance;

}

- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary
{

    if (![aDictionary isKindOfClass:[NSDictionary class]]) {
        return;
    }

    [self setValuesForKeysWithDictionary:aDictionary];

}

- (void)setValue:(id)value forKey:(NSString *)key
{
    
    if ([key isEqualToString:@"attachments"]) {
        
        if ([value isKindOfClass:[NSArray class]])
        {
            
            NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[value count]];
            for (id valueMember in value) {
                KMWordPressPostAttachment *populatedMember = [KMWordPressPostAttachment instanceFromDictionary:valueMember];
                [myMembers addObject:populatedMember];
            }
            
            self.attachments = myMembers;
            
        }
        
    } else if ([key isEqualToString:@"author"]) {
        
        if ([value isKindOfClass:[NSDictionary class]]) {
            self.author = [KMWordPressPostAuthor instanceFromDictionary:value];
        }
        
    } else if ([key isEqualToString:@"categories"]) {
        
        if ([value isKindOfClass:[NSArray class]])
        {
            
            NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[value count]];
            for (id valueMember in value) {
                KMWordPressCategory *populatedMember = [KMWordPressCategory instanceFromDictionary:valueMember];
                [myMembers addObject:populatedMember];
            }
            
            self.categories = myMembers;
            
        }
        
    } else if ([key isEqualToString:@"comments"]) {
        
        if ([value isKindOfClass:[NSArray class]])
        {
            NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[value count]];
            for (id valueMember in value) {
                KMWordPressPostComment *populatedMember = [KMWordPressPostComment instanceFromDictionary:valueMember];
                [myMembers addObject:populatedMember];
            }
            
            [self sortComments:myMembers];
        }
        
    } else if ([key isEqualToString:@"tags"]) {
        
        if ([value isKindOfClass:[NSArray class]])
        {
            
            NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[value count]];
            for (id valueMember in value) {
                KMWordPressTag *populatedMember = [KMWordPressTag instanceFromDictionary:valueMember];
                [myMembers addObject:populatedMember];
            }
            
            self.tags = myMembers;
            
        }
        
    }
    else if ([key isEqualToString:@"date"])
    {
        self.date = value;
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        self.postDate = [df dateFromString:value];
    }
    else
    {
        [super setValue:value forKey:key];
    }
    
}

- (NSArray *)flattenComments:(KMWordPressPostComment *)comment
{
    if ([comment.childComments count])
    {
        NSMutableArray *comments = @[].mutableCopy;
        
        for (KMWordPressPostComment *childComment in comment.childComments)
        {
            [comments addObject:childComment];
            
            if (childComment.childComments)
            {
                [comments addObjectsFromArray:[self flattenComments:childComment]];
            }
        }
        
        return comments;
    }
        
    return @[];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{

    if ([key isEqualToString:@"comment_count"]) {
        [self setValue:value forKey:@"commentCount"];
    } else if ([key isEqualToString:@"comment_status"]) {
        [self setValue:value forKey:@"commentStatus"];
    } else if ([key isEqualToString:@"id"]) {
        [self setValue:value forKey:@"kMWordPressPostId"];
    } else if ([key isEqualToString:@"title_plain"]) {
        [self setValue:value forKey:@"titlePlain"];
    } else if ([key isEqualToString:@"next_url"]) {
        [self setValue:value forKey:@"nextUrl"];
    } else if ([key isEqualToString:@"previous_url"]) {
        [self setValue:value forKey:@"previousUrl"];
    } else if ([key isEqualToString:@"next_title"]) {
        [self setValue:value forKey:@"nextTitle"];
    } else if ([key isEqualToString:@"previous_title"]) {
        [self setValue:value forKey:@"previousTitle"];
    } else {
        DLog(@"undefined key: %@", key);
        
        //[super setValue:value forUndefinedKey:key];
    }

}

- (NSString *) getThumbnailUrl
{
    if ([self.thumbnail length])
    {
        return self.thumbnail;
    }
    
	if ([self.attachments count])
	{
		KMWordPressPostAttachment* attachement = [self.attachments objectAtIndex:0];
        
        return attachement.images.medium.url;
	}
	
	return nil;
}

- (KMWordPressPostAttachment *)findAttachment:(NSString *)url
{
    for (KMWordPressPostAttachment *item in self.attachments)
    {
        if ([item.url isEqualToString:url])
        {
            return item;
        }
    }
    
    return nil;
}

- (NSInteger)findAttachmentIndex:(NSString *)url
{
    NSInteger index = 0;
    for (KMWordPressPostAttachment *item in self.attachments)
    {
        if ([item.url isEqualToString:url])
        {
            return index;
        }
        
        index++;
    }
    
    return 0;
}

- (BOOL)isPhotogallery
{
    return ([self.attachments count] > 3);
}

- (NSString *)formattedDate
{
    if (sPostDateFormatter == nil)
    {
        sPostDateFormatter = [NSDateFormatter new];
        [sPostDateFormatter setDateFormat:@"h:mm a, MMMM d, yyyy"];
    }
    
    return [sPostDateFormatter stringFromDate:self.postDate];
}

- (NSString *)relativeDate
{
    if (sRelativetDateFormatter == nil)
    {
        sRelativetDateFormatter = [SORelativeDateTransformer new];
    }
    
    return [sRelativetDateFormatter transformedValue:self.postDate];
}

- (void)addComment:(KMWordPressPostComment *)comment
{
    NSMutableArray *items = self.comments.mutableCopy;
    [items addObject:comment];
    [self sortComments:items];
    
    self.commentCount = [NSNumber numberWithInt:[self.comments count]];
}

- (void)sortComments:(NSArray *)unorderedComments
{
    NSMutableDictionary *allComments = @{}.mutableCopy;
    
    for (KMWordPressPostComment *valueMember in unorderedComments)
    {
        valueMember.childComments = nil;
        allComments[valueMember.kMWordPressPostCommentId] = valueMember;
    }
    
    NSArray *sortedComments = [unorderedComments sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"kMWordPressPostCommentId" ascending:YES]]];
    
    NSMutableArray *commentParents = @[].mutableCopy;
    
    for (KMWordPressPostComment *comment in sortedComments)
    {
        if ([comment.parent intValue])
        {
            KMWordPressPostComment *parentComment = allComments[comment.parent];
            
            if (parentComment)
            {
                if ([parentComment.childComments count])
                {
                    
                    NSMutableArray *childrenComments = parentComment.childComments.mutableCopy;
                    [childrenComments addObject:comment];
                    parentComment.childComments = childrenComments;
                }
                else
                {
                    parentComment.childComments = @[comment];
                }
                
                comment.childLevel = parentComment.childLevel + 1;
                
                allComments[comment.parent] = parentComment;
            }
            else
            {
                [commentParents addObject:comment];
            }
        }
        else
        {
            [commentParents addObject:comment];
        }
    }
    
    NSMutableArray *commentsWithChildren = @[].mutableCopy;
    for (KMWordPressPostComment *comment in commentParents)
    {
        [commentsWithChildren addObject:comment];
        
        if ([comment.childComments count])
        {
            [commentsWithChildren addObjectsFromArray:[self flattenComments:comment]];
        }
        
    }
    
    self.comments = commentsWithChildren;
}
@end
