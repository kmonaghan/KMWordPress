//
//  KMMasterViewController.h
//  KMWordPress
//
//  Created by Karl Monaghan on 03/01/2013.
//  Copyright (c) 2013 Crayons and Brown Paper. All rights reserved.
//

#import "KMPostListViewController.h"

@class KMDetailViewController;

@interface KMMasterViewController : KMPostListViewController
@property (strong, nonatomic) KMDetailViewController *detailViewController;
@end
