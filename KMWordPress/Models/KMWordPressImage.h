//
//  KMWordPressImage.h
//  
//
//  Created by Karl Monaghan on 30/09/2012.
//  Copyright (c) 2012 Crayons and Brown Paper. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KMWordPressImage : NSObject

@property (nonatomic, assign) NSInteger height;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) NSInteger width;


+ (KMWordPressImage *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

@end
