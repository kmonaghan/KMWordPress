//
//  UIViewController+KMWordPress.h
//  KMWordPress
//
//  Created by Karl Monaghan on 17/01/2013.
//  Copyright (c) 2013 Crayons and Brown Paper. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (KMWordPress)
- (void)showError:(NSError *)error;
- (void)showErrorMessage:(NSString *)error;
- (void)showMessage:(NSString *)message;
@end
