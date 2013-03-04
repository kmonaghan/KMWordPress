//
//  KMWordPressPostAuthor.m
//  
//
//  Created by Karl Monaghan on 30/09/2012.
//  Copyright (c) 2012 Crayons and Brown Paper. All rights reserved.
//

#import "KMWordPressPostAuthor.h"

@implementation KMWordPressPostAuthor

+ (KMWordPressPostAuthor *)instanceFromDictionary:(NSDictionary *)aDictionary
{

    KMWordPressPostAuthor *instance = [[KMWordPressPostAuthor alloc] init];
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
    } else if ([key isEqualToString:@"first_name"]) {
        [self setValue:value forKey:@"firstName"];
    } else if ([key isEqualToString:@"last_name"]) {
        [self setValue:value forKey:@"lastName"];
    } else if ([key isEqualToString:@"id"]) {
        [self setValue:value forKey:@"kMWordPressPostAuthorId"];
    } else {
        DLog(@"undefined key: %@", key);
        
        //[super setValue:value forUndefinedKey:key];
    }

}


@end
