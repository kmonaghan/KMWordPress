//
//  KMCreateCommentViewController.h
//  KMWordPress
//
//  Created by Karl Monaghan on 22/10/2012.
//  Copyright (c) 2012 Crayons and Brown Paper. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KMWordPressPost;
@class KMWordPressPostComment;

typedef void (^commentFinishBlock) (KMWordPressPostComment*);

@interface KMCreateCommentViewController : UITableViewController <UITextFieldDelegate, UITextViewDelegate>
@property (readwrite, nonatomic, copy) commentFinishBlock redirectResponse;

- (id)initWithPost:(KMWordPressPost *)post;
- (id)initWithPost:(KMWordPressPost *)post withComment:(KMWordPressPostComment *)comment;
@end
