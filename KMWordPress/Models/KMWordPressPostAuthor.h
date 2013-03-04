//
//  KMWordPressPostAuthor.h
//  
//
//  Created by Karl Monaghan on 30/09/2012.
//  Copyright (c) 2012 Crayons and Brown Paper. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KMWordPressPostAuthor : NSObject

@property (nonatomic, strong) NSString *descriptionText;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, strong) NSNumber *kMWordPressPostAuthorId;
@property (nonatomic, strong) NSString *slug;
@property (nonatomic, strong) NSString *url;


+ (KMWordPressPostAuthor *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

@end
