//
//  KMDataSource.m
//  KMWordPress
//
//  Created by Karl Monaghan on 22/10/2012.
//  Copyright (c) 2012 Crayons and Brown Paper. All rights reserved.
//

#import "KMDataSource.h"

@implementation KMDataSource
- (id)init
{
    self = [super init];
    if (self)
    {
        self.items = @[];
    }
    
    return self;
}

- (id)initWithSuccess:(void (^)(void))success withFailure:(void (^)(NSError *error))failure
{
    self = [self init];
    if (self)
    {

    }
    
    return self;
}

- (void)loadItems:(BOOL)more
{

}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.items count];
}
@end
