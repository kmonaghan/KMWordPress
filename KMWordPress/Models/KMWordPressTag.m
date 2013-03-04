//
//  KMWordPressTag.m
//  
//
//  Created by Karl Monaghan on 30/09/2012.
//  Copyright (c) 2012 Crayons and Brown Paper. All rights reserved.
//

#import "KMWordPressTag.h"

@implementation KMWordPressTag

+ (KMWordPressTag *)instanceFromDictionary:(NSDictionary *)aDictionary
{

    KMWordPressTag *instance = [[KMWordPressTag alloc] init];
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

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{

    if ([key isEqualToString:@"description"]) {
        [self setValue:value forKey:@"descriptionText"];
    } else if ([key isEqualToString:@"post_count"]) {
        [self setValue:value forKey:@"postCount"];
    } else if ([key isEqualToString:@"id"]) {
        [self setValue:value forKey:@"kMWordPressTagId"];
    } else {
        DLog(@"undefined key: %@", key);
        
        //[super setValue:value forUndefinedKey:key];
    }

}


@end
