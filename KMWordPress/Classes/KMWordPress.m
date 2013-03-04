//
//  KMWordPress.m
//  KMWordPress
//
//  Created by Karl Monaghan on 13/01/2013.
//  Copyright (c) 2013 Crayons and Brown Paper. All rights reserved.
//

#import "KMWordPress.h"

@implementation KMWordPress
+ (KMWordPress *)sharedInstance {
    static KMWordPress *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[KMWordPress alloc] init];
    });
    
    return _sharedClient;
}
@end
