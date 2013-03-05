//
//  KMPullToRefreshContentView.m
//  KMWordPress
//
//  Created by Karl Monaghan on 05/03/2013.
//  Copyright (c) 2013 Crayons and Brown Paper. All rights reserved.
//

#import "KMPullToRefreshContentView.h"

@implementation KMPullToRefreshContentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[[UIColor colorWithRed:0.89f green:0.89f blue:0.89f alpha:1.0f]  CGColor], nil];
    [self.layer insertSublayer:gradient atIndex:0];
}

@end
