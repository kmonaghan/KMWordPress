//
//  KMDataSource.h
//  KMWordPress
//
//  Created by Karl Monaghan on 22/10/2012.
//  Copyright (c) 2012 Crayons and Brown Paper. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KMDataSource : NSObject <UITableViewDataSource>
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, assign, getter=isLoading) BOOL loading;

- (id)initWithSuccess:(void (^)(void))success withFailure:(void (^)(NSError *error))failure;
- (void)loadItems:(BOOL)more;
@end
