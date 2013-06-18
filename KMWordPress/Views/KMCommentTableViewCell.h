//
//  KMCommentTableViewCell.h
//  KMWordPress
//
//  Created by Karl Monaghan on 30/10/2012.
//  Copyright (c) 2012 Crayons and Brown Paper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTAttributedTextCell.h"

@class KMWordPressPostComment;

@interface KMCommentTableViewCell : DTAttributedTextCell <DTAttributedTextContentViewDelegate>
@property(weak, nonatomic) KMCommentListViewController *parentViewController;
- (void)showComment:(KMWordPressPostComment *)comment;

@end
