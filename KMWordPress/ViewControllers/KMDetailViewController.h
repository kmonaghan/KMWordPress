//
//  KMDetailViewController.h
//  KMWordPress
//
//  Created by Karl Monaghan on 03/01/2013.
//  Copyright (c) 2013 Crayons and Brown Paper. All rights reserved.
//

#import "KMPostViewController.h"

@class KMWordPressPost;

@interface KMDetailViewController : KMPostViewController <UISplitViewControllerDelegate>
- (void)setDetailItem:(KMWordPressPost *)newDetailItem withIndex:(NSInteger)index;
@end
