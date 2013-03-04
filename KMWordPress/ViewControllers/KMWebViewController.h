//
//  KMWebViewController.h
//  KMWordPress
//
//  Created by Karl Monaghan on 30/10/2012.
//  Copyright (c) 2012 Crayons and Brown Paper. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KMViewController.h"

@interface KMWebViewController : KMViewController <UIWebViewDelegate, UIActionSheetDelegate>
- (id)initWithWebURL:(NSURLRequest *)request;
@end
