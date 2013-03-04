//
//  UISearchBar+alwaysEnableCancelButton.m
//  KMWordPress
//
//  Created by Karl Monaghan on 20/02/2013.
//  Copyright (c) 2013 Crayons and Brown Paper. All rights reserved.
//

#import "UISearchBar+alwaysEnableCancelButton.h"

@implementation UISearchBar (alwaysEnableCancelButton)
- (BOOL)resignFirstResponder
{
    for (UIView *v in self.subviews) {
        // Force the cancel button to stay enabled
        if ([v isKindOfClass:[UIControl class]]) {
            ((UIControl *)v).enabled = YES;
        }
        
        // Dismiss the keyboard
        if ([v isKindOfClass:[UITextField class]]) {
            [(UITextField *)v resignFirstResponder];
        }
    }
    
    return YES;
}
@end
