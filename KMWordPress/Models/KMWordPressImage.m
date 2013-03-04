//
//  KMWordPressImage.m
//  
//
//  Created by Karl Monaghan on 30/09/2012.
//  Copyright (c) 2012 Crayons and Brown Paper. All rights reserved.
//

#import "KMWordPressImage.h"

@implementation KMWordPressImage

+ (KMWordPressImage *)instanceFromDictionary:(NSDictionary *)aDictionary
{

    KMWordPressImage *instance = [[KMWordPressImage alloc] init];
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

@end
