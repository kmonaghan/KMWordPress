//
//  KMPostTableViewCell.h
//  KMWordPress
//
//  Created by Karl Monaghan on 30/09/2012.
//  Copyright (c) 2012 Crayons and Brown Paper. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KMWordPressPost;
@class KMPostListViewController;

@interface KMPostTableViewCell : UITableViewCell
@property (strong, nonatomic) NSDate * yesterday;
@property (weak, nonatomic) KMPostListViewController *parentViewController;

- (void)showPost:(KMWordPressPost *)post;
@end
