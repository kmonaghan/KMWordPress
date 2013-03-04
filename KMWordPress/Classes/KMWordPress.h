//
//  KMWordPress.h
//  KMWordPress
//
//  Created by Karl Monaghan on 13/01/2013.
//  Copyright (c) 2013 Crayons and Brown Paper. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KMWordPress : NSObject
@property (assign, nonatomic) BOOL fullScreen;
+ (KMWordPress *)sharedInstance;
@end
