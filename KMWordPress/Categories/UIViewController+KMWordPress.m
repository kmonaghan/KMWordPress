//
//  UIViewController+KMWordPress.m
//  KMWordPress
//
//  Created by Karl Monaghan on 17/01/2013.
//  Copyright (c) 2013 Crayons and Brown Paper. All rights reserved.
//
#import "AJNotificationView.h"

#import "UIViewController+KMWordPress.h"

@implementation UIViewController (KMWordPress)
- (void)showError:(NSError *)error
{
    NSString *message = [error localizedDescription];
    
    if (([error.domain isEqualToString:@"AFNetworkingErrorDomain"])
        || ([error.domain isEqualToString:@"NSURLErrorDomain"]))
    {
        message = @"Check your network connection, or Broadsheet.ie is not available.";
    }
    
    [AJNotificationView showNoticeInView:self.view
                                    type:AJNotificationTypeRed
                                   title:message
                         linedBackground:AJLinedBackgroundTypeDisabled
                               hideAfter:5];
}

- (void)showErrorMessage:(NSString *)error
{
    [AJNotificationView showNoticeInView:self.view
                                    type:AJNotificationTypeRed
                                   title:error
                         linedBackground:AJLinedBackgroundTypeDisabled
                               hideAfter:5];
}

- (void)showMessage:(NSString *)message
{
    [AJNotificationView showNoticeInView:self.view
                                    type:AJNotificationTypeBlue
                                   title:message
                         linedBackground:AJLinedBackgroundTypeDisabled
                               hideAfter:5];
}
@end
