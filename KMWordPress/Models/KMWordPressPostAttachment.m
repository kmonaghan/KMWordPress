//
//  KMWordPressPostAttachment.m
//  
//
//  Created by Karl Monaghan on 30/09/2012.
//  Copyright (c) 2012 Crayons and Brown Paper. All rights reserved.
//

#import "KMWordPressPostAttachment.h"

#import "KMWordPressPostAttachmentImages.h"

@implementation KMWordPressPostAttachment

+ (KMWordPressPostAttachment *)instanceFromDictionary:(NSDictionary *)aDictionary
{

    KMWordPressPostAttachment *instance = [[KMWordPressPostAttachment alloc] init];
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

    if ([key isEqualToString:@"images"]) {

        if ([value isKindOfClass:[NSDictionary class]]) {
            self.images = [KMWordPressPostAttachmentImages instanceFromDictionary:value];
        }

    } else {
        [super setValue:value forKey:key];
    }

}


- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{

    if ([key isEqualToString:@"id"]) {
        [self setValue:value forKey:@"kMWordPressPostAttachmentId"];
    } else if ([key isEqualToString:@"description"]) {
        [self setValue:value forKey:@"descriptionText"];
    } else if ([key isEqualToString:@"mime_type"]) {
        [self setValue:value forKey:@"mimeType"];
    } else {
        DLog(@"undefined key: %@", key);
        
        //[super setValue:value forUndefinedKey:key];
    }

}


@end
