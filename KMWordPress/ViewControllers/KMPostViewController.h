//
//  KMPostViewController.h
//  KMWordPress
//
//  Created by Karl Monaghan on 30/09/2012.
//  Copyright (c) 2012 Crayons and Brown Paper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KMViewController.h"

@class KMWordPressPost;
@class KMPostListDataSource;

@interface KMPostViewController : KMViewController <UIWebViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, strong) KMPostListDataSource* dataSource;
@property (nonatomic, strong) KMWordPressPost *post;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) UIView *loadPreviousView;
@property (nonatomic, strong) UIView *loadNextView;
@property (nonatomic, strong) UIWebView *webView;

- (id)initWithPost:(KMWordPressPost *)post;
- (id)initWithPostUrl:(NSURL *)url;
- (id)initWithDataSource:(KMPostListDataSource *)source withStartIndex:(NSInteger)index;
- (void)loadPost;
@end
