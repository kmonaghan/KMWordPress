//
//  KMWordPressPostAttachmentImages.h
//  
//
//  Created by Karl Monaghan on 30/09/2012.
//  Copyright (c) 2012 Crayons and Brown Paper. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KMWordPressImage;

@interface KMWordPressPostAttachmentImages : NSObject

@property (nonatomic, strong) KMWordPressImage *full;
@property (nonatomic, strong) KMWordPressImage *large;
@property (nonatomic, strong) KMWordPressImage *largeFeature;
@property (nonatomic, strong) KMWordPressImage *medium;
@property (nonatomic, strong) KMWordPressImage *postThumbnail;
@property (nonatomic, strong) KMWordPressImage *smallFeature;
@property (nonatomic, strong) KMWordPressImage *thumbnail;


+ (KMWordPressPostAttachmentImages *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

@end
