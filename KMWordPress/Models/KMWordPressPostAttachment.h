//
//  KMWordPressPostAttachment.h
//  
//
//  Created by Karl Monaghan on 30/09/2012.
//  Copyright (c) 2012 Crayons and Brown Paper. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KMWordPressPostAttachmentImages;

@interface KMWordPressPostAttachment : NSObject

@property (nonatomic, strong) NSNumber *kMWordPressPostAttachmentId;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSString *descriptionText;
@property (nonatomic, strong) KMWordPressPostAttachmentImages *images;
@property (nonatomic, strong) NSString *mimeType;
@property (nonatomic, strong) NSNumber *parent;
@property (nonatomic, strong) NSString *slug;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *url;


+ (KMWordPressPostAttachment *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

@end
