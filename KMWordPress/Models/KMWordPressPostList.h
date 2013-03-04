//
//  KMWordPressPostList.h
//  
//
//  Created by Karl Monaghan on 30/09/2012.
//  Copyright (c) 2012 Crayons and Brown Paper. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KMWordPressPostList : NSObject

@property (nonatomic, strong) NSNumber *count;
@property (nonatomic, strong) NSNumber *countTotal;
@property (nonatomic, strong) NSNumber *pages;
@property (nonatomic, strong) NSArray *posts;
@property (nonatomic, strong) NSString *status;


+ (KMWordPressPostList *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

@end
