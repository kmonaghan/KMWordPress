//
//  KMWordPressPostControl.h
//  KMWordPress
//
//  Created by Karl Monaghan on 17/12/2012.
//  Copyright (c) 2012 Crayons and Brown Paper. All rights reserved.
//

#import <MessageUI/MessageUI.h>

@class KMWordPressPost;

@interface KMWordPressPostControl : NSObject <MFMailComposeViewControllerDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, strong) KMWordPressPost *post;
@property (nonatomic, strong) UIViewController *delegate;
@property (nonatomic, assign) BOOL buttonsVisible;

- (void)attachButtonsToView;
- (void)shortTapAction:(UITapGestureRecognizer *)gesture;
- (void)viewComments;
@end
