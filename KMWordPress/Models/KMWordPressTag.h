//
//  KMWordPressTag.h
//  
//
//  Created by Karl Monaghan on 30/09/2012.
//  Copyright (c) 2012 Crayons and Brown Paper. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KMWordPressTag : NSObject

@property (nonatomic, strong) NSString *descriptionText;
@property (nonatomic, strong) NSNumber *postCount;
@property (nonatomic, strong) NSString *slug;
@property (nonatomic, strong) NSNumber *kMWordPressTagId;
@property (nonatomic, strong) NSString *title;


+ (KMWordPressTag *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

@end
