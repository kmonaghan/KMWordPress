//
//  KMWordPressPostList.m
//  
//
//  Created by Karl Monaghan on 30/09/2012.
//  Copyright (c) 2012 Crayons and Brown Paper. All rights reserved.
//

#import "KMWordPressPostList.h"

#import "KMWordPressPost.h"

@implementation KMWordPressPostList

+ (KMWordPressPostList *)instanceFromDictionary:(NSDictionary *)aDictionary
{

    KMWordPressPostList *instance = [[KMWordPressPostList alloc] init];
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

    if ([key isEqualToString:@"posts"]) {

        if ([value isKindOfClass:[NSArray class]])
{

            NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:1];
            for (id valueMember in value) {
                KMWordPressPost *populatedMember = [KMWordPressPost instanceFromDictionary:valueMember];
                [myMembers addObject:populatedMember];
            }

            self.posts = myMembers;

        }

    } else {
        [super setValue:value forKey:key];
    }

}


- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{

    if ([key isEqualToString:@"count_total"]) {
        [self setValue:value forKey:@"countTotal"];
    } else {
        DLog(@"undefined key: %@", key);
        
        //[super setValue:value forUndefinedKey:key];
    }

}


@end
