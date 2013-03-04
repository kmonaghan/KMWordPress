//
//  KMWordPressPostComment.m
//  
//
//  Created by Karl Monaghan on 30/09/2012.
//  Copyright (c) 2012 Crayons and Brown Paper. All rights reserved.
//

#import "KMWordPressPostComment.h"
#import "KMWordPressPostAuthor.h"

static NSDateFormatter *sPostCommentDateFormatter = nil;

@implementation KMWordPressPostComment

+ (KMWordPressPostComment *)instanceFromDictionary:(NSDictionary *)aDictionary
{

    KMWordPressPostComment *instance = [[KMWordPressPostComment alloc] init];
    [instance setAttributesFromDictionary:aDictionary];
    return instance;

}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.childLevel = 0;
    }
    
    return self;
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
    if ([key isEqualToString:@"date"])
    {
        self.date = value;
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        self.commentDate = [df dateFromString:value];
    }
    else
    {
        [super setValue:value forKey:key];
    }
    
}


- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{

    if ([key isEqualToString:@"id"])
    {
        [self setValue:value forKey:@"kMWordPressPostCommentId"];
    }
    else if ([key isEqualToString:@"author"])
    {
        if ([value isKindOfClass:[NSDictionary class]])
        {
            self.author = [KMWordPressPostAuthor instanceFromDictionary:value];
        }
    }
    else
    {
        DLog(@"undefined key: %@", key);
        
        //[super setValue:value forUndefinedKey:key];
    }

}

- (NSString *)formattedDate
{
    if (sPostCommentDateFormatter == nil)
    {
        sPostCommentDateFormatter = [NSDateFormatter new];
        [sPostCommentDateFormatter setDateFormat:@"h:mm a, MMMM d, yyyy"];
    }
    
    return [sPostCommentDateFormatter stringFromDate:self.commentDate];
}
@end
