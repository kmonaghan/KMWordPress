//
//  KMWordPressPostAttachmentImages.m
//  
//
//  Created by Karl Monaghan on 30/09/2012.
//  Copyright (c) 2012 Crayons and Brown Paper. All rights reserved.
//

#import "KMWordPressPostAttachmentImages.h"

#import "KMWordPressImage.h"

@implementation KMWordPressPostAttachmentImages

+ (KMWordPressPostAttachmentImages *)instanceFromDictionary:(NSDictionary *)aDictionary
{

    KMWordPressPostAttachmentImages *instance = [[KMWordPressPostAttachmentImages alloc] init];
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

    if ([key isEqualToString:@"full"]) {

        if ([value isKindOfClass:[NSDictionary class]]) {
            self.full = [KMWordPressImage instanceFromDictionary:value];
        }

    } else if ([key isEqualToString:@"large"]) {

        if ([value isKindOfClass:[NSDictionary class]]) {
            self.large = [KMWordPressImage instanceFromDictionary:value];
        }

    } else if ([key isEqualToString:@"large-feature"]) {

        if ([value isKindOfClass:[NSDictionary class]]) {
            self.largeFeature = [KMWordPressImage instanceFromDictionary:value];
        }

    } else if ([key isEqualToString:@"medium"]) {

        if ([value isKindOfClass:[NSDictionary class]]) {
            self.medium = [KMWordPressImage instanceFromDictionary:value];
        }

    } else if ([key isEqualToString:@"post-thumbnail"]) {

        if ([value isKindOfClass:[NSDictionary class]]) {
            self.postThumbnail = [KMWordPressImage instanceFromDictionary:value];
        }

    } else if ([key isEqualToString:@"small-feature"]) {

        if ([value isKindOfClass:[NSDictionary class]]) {
            self.smallFeature = [KMWordPressImage instanceFromDictionary:value];
        }

    } else if ([key isEqualToString:@"thumbnail"]) {

        if ([value isKindOfClass:[NSDictionary class]]) {
            self.thumbnail = [KMWordPressImage instanceFromDictionary:value];
        }

    } else {
        [super setValue:value forKey:key];
    }

}


- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{

    if ([key isEqualToString:@"large-feature"]) {
        [self setValue:value forKey:@"largeFeature"];
    } else if ([key isEqualToString:@"post-thumbnail"]) {
        [self setValue:value forKey:@"postThumbnail"];
    } else if ([key isEqualToString:@"small-feature"]) {
        [self setValue:value forKey:@"smallFeature"];
    } else {
        DLog(@"undefined key: %@", key);
        
        //[super setValue:value forUndefinedKey:key];
    }

}


@end
