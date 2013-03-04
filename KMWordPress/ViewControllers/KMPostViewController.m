//
//  KMPostViewController.m
//  KMWordPress
//
//  Created by Karl Monaghan on 30/09/2012.
//  Copyright (c) 2012 Crayons and Brown Paper. All rights reserved.
//

#import "NSString+HTML.h"
#import "UIView+KMWordPress.h"

#import "KMPostViewController.h"
#import "KMWebViewController.h"
#import "KMPostListViewController.h"
#import "NetworkPhotoAlbumViewController.h"

#import "KMPostHelpView.h"

#import "KMWordPressPostControl.h"

#import "KMPostListDataSource.h"

#import "KMWordPressPost.h"
#import "KMWordPressPostAuthor.h"
#import "KMWordPressCategory.h"
#import "KMWordPressTag.h"

@interface KMPostViewController ()
@property (strong, nonatomic) KMWordPressPostControl *buttonControl;

@property (nonatomic, strong) NSString *postId;
@property (nonatomic, strong) NSURL *postUrl;
@property (nonatomic, strong) UIScrollView *scrollView;

@property (strong, nonatomic) UILabel *previousTitleLabel;
@property (strong, nonatomic) UILabel *nextTitleLabel;

@property (assign, nonatomic) CGFloat fontSize;

@end

@implementation KMPostViewController
- (id)initWithPostId:(NSString *)postId
{
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        self.postId = postId;
    }
    return self;
}

- (id)initWithPost:(KMWordPressPost *)post
{
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        self.post = post;
        self.buttonControl.post = post;
        self.index = 0;
    }
    return self;
}

- (id)initWithDataSource:(KMPostListDataSource *)source withStartIndex:(NSInteger)index
{
    self = [self initWithNibName:nil bundle:nil];
    if (self)
    {
        // Custom initialization
        self.dataSource = source;
        self.index = index;
        self.post = source.items[index];
        self.buttonControl.post = _post;
        
    }
    return self;
}

- (id)initWithPostUrl:(NSURL *)url
{
    self = [self initWithNibName:nil bundle:nil];
    if (self)
    {
        // Custom initialization
        self.index = 0;
        self.postUrl = url;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        self.buttonControl = [KMWordPressPostControl new];
        self.buttonControl.delegate = self;
        
        self.fontSize = [[NSUserDefaults standardUserDefaults] floatForKey:@"fontsize"];
        
        if (!self.fontSize)
        {
            self.fontSize = 16.0f;
        }
    }
    return self;
}

- (void)dealloc
{
    self.webView.delegate = nil;
    self.scrollView.delegate = nil;
    self.buttonControl.delegate = nil;
    
    [self.scrollView removeObserver:self
                         forKeyPath:@"contentOffset"
                            context:NULL];
    [self.scrollView removeObserver:self
                         forKeyPath:@"frame"
                            context:NULL];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    
	// Do any additional setup after loading the view.    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.delegate = self;
    
    for (UIView *view in [self.webView.scrollView subviews])
    {
        if ([view isKindOfClass:[UIImageView class]])
        {
            [view setHidden:YES];
        }
    }
    
    self.scrollView = self.webView.scrollView;
    self.scrollView.delegate = self;
    [self.scrollView addObserver:self
                      forKeyPath:@"contentOffset"
                         options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionPrior
                         context:NULL];

    [self.scrollView addObserver:self
                      forKeyPath:@"frame"
                         options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionPrior
                         context:NULL];
/*
    [self.view addSubview:self.webView];
    
    self.buttonControl.delegate = self;
     
    [self.buttonControl attachButtonsToView];
*/    
    self.loadNextView = [[UIView alloc] initWithFrame:CGRectMake(0, -50.0f, self.view.frame.size.width, 50.0f)];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.loadNextView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[[UIColor colorWithRed:0.89f green:0.89f blue:0.89f alpha:1.0f] CGColor], nil];
    [self.loadNextView.layer insertSublayer:gradient atIndex:0];
    
    self.nextTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 3.0f, self.view.frame.size.width - 20.0f, 44)];
    self.nextTitleLabel.backgroundColor = [UIColor clearColor];
    self.nextTitleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    self.nextTitleLabel.numberOfLines = 2;
    self.nextTitleLabel.textAlignment = UITextAlignmentCenter;
    
    [self.loadNextView addSubview:self.nextTitleLabel];
    
    UIView *bottomBlackLine = [[UIView alloc] initWithFrame:CGRectMake(0, 49.0f, self.view.frame.size.width, 1.0f)];
    bottomBlackLine.backgroundColor = [UIColor lightGrayColor];
    [self.loadNextView addSubview:bottomBlackLine];
    
    [self.view addSubview:self.loadNextView];
    
    self.loadPreviousView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.view.frame.size.height, self.view.frame.size.width, 50.0f)];
    CAGradientLayer *gradient2 = [CAGradientLayer layer];
    gradient2.frame = self.loadNextView.bounds;
    gradient2.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0.89f green:0.89f blue:0.89f alpha:1.0f] CGColor], (id)[[UIColor whiteColor] CGColor], nil];
    [self.loadPreviousView.layer insertSublayer:gradient2 atIndex:0];
    
    self.previousTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 3.0f, self.view.frame.size.width - 20.0f, 44.0f)];
    self.previousTitleLabel.backgroundColor = [UIColor clearColor];
    
    self.previousTitleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    self.previousTitleLabel.numberOfLines = 2;
    self.previousTitleLabel.textAlignment = UITextAlignmentCenter;
    
    [self.loadPreviousView addSubview:self.previousTitleLabel];
    
    UIView *topBlackLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1.0f)];
    topBlackLine.backgroundColor = [UIColor lightGrayColor];
    [self.loadPreviousView addSubview:topBlackLine];
    
    [self.view addSubview:self.loadPreviousView];
    
    self.loadPreviousView.hidden = YES;
    self.loadNextView.hidden = YES;

    [self.view addSubview:self.webView];
    
    self.buttonControl.delegate = self;
    
    [self.buttonControl attachButtonsToView];
    
    if (self.post)
    {
        [self loadPost];
    }
    else if (self.postUrl)
    {
        [[KMWordPressAPIClient sharedClient] loadFromPostUrl:self.postUrl
                                                 withSuccess:^(KMWordPressPost *post) {
                                                     self.post = post;
                                                     self.buttonControl.post = post;
                                                     [self loadPost];
                                                 }
                                                 withFailure:^(NSError *error){
                                                     [self showError:error];
                                                 }];
    }
    else
    {
        [[KMWordPressAPIClient sharedClient] loadFromPostId:self.postId
                                                withSuccess:^(KMWordPressPost *post) {
                                                    self.post = post;
                                                    self.buttonControl.post = post;
                                                    [self loadPost];
                                                }
                                                withFailure:^(NSError *error){
                                                    [self showError:error];
                                                }];
    }
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(pinchAction:)];
    
    [self.webView addGestureRecognizer:pinch];
    
    UISwipeGestureRecognizer *leftswipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self.buttonControl
                                                                                action:@selector(viewComments)];
    
    leftswipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.webView addGestureRecognizer:leftswipe];
    
    [self attachBackSwipe:self.webView];
    
    [self.view bringSubviewToFront:self.fullScreen];
    [self.view bringSubviewToFront:self.backButton];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"helpShown"])
    {
        KMPostHelpView *help = [KMPostHelpView viewFromNib];

        help.$height = self.view.$height;
        
        [self.view addSubview:help];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"helpShown"];
    }

}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.webView stopLoading];
    
    [self.buttonControl shortTapAction:nil];
    
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(BOOL)shouldAutorotate
{
    return NO;
}

- (BOOL)canLoadNext
{
    if ([self.dataSource.items count] > 1)
    {
        if (self.index > 0)
        {
            return YES;
        }
    }
    
    return NO;
}

- (void)loadNext
{
    if ([self canLoadNext])
    {
        self.index--;
    
        self.post = self.dataSource.items[self.index];
    
        [self loadPost];
    }
}

- (BOOL)canLoadPrevious
{
    if (self.dataSource  && (((self.index + 1) < [self.dataSource.items count])
        || (self.post.previousUrl)))
    {
        return YES;
    }
    
    return NO;
}

- (void)loadPrevious
{
    if ([self canLoadPrevious])
    {
        self.index++;
        
        if (self.index < [self.dataSource.items count])
        {
            self.post = self.dataSource.items[self.index];
            
            [self loadPost];
        }
        else if (self.post.previousUrl)
        {
            __block KMPostViewController *blockSelf = self;
            
            // Update the content inset
            self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 75.0f, 0);
            self.loadPreviousView.$y = self.scrollView.$bottom - 75.0f;
            
            [self.dataSource loadPostFromUrl:self.post.previousUrl
                                 withSuccess:^(KMWordPressPost *post) {
                                     blockSelf.post = post;
                                     blockSelf.buttonControl.post = post;

                                     blockSelf.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
                                     blockSelf.loadPreviousView.$y = self.scrollView.$bottom;
                                     [blockSelf loadPost];
                                     
                                     
                                 }
                                 withFailure:^(NSError *error){
                                     [blockSelf showError:error];

                                     blockSelf.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
                                     blockSelf.loadPreviousView.$y = self.scrollView.$bottom;
                                 }];
        }
        
    }
}

- (void)loadPost
{
    [self.webView stopLoading];
    
    NSMutableString* postHtml = @"".mutableCopy;
    
    [postHtml appendFormat:@"<html><head><script type=\"text/javascript\" src=\"kmwordpress.js\"></script>"];
    
    [postHtml appendFormat:@"<style>#singlentry {font-size: %fpx;}</style><link href='default.css' rel='stylesheet' type='text/css' />", self.fontSize];
    
    [postHtml appendFormat:@"</head><body id=\"contentbody\"><div id='maincontent' class='content'><div class='post'><div id='title'>%@</div><div><span class='date-color'>%@</span>&nbsp;<a class='author' href=\"kmwordpress://author:%@\">%@</a></div>",
     self.post.title,
     [self.post formattedDate],
     self.post.author.kMWordPressPostAuthorId,
     self.post.author.name];
    /*
    if ([self.post isPhotogallery])
    {
        [postHtml appendString:@"<div><a href=\"kmwordpress://showGallery\">View Photogallery</a></div>"];
    }
    */
    [postHtml appendFormat:@"<div id='singlentry'>%@</div></div>", self.post.content];
    
    if ([self.post.categories count])
    {
        [postHtml appendString:@"<div>"];
        
        for (KMWordPressCategory *item in self.post.categories)
        {
            [postHtml appendFormat:@"<a class=\"category\" href=\"kmwordpress://category:%@\">%@</a> ", item.kMWordPressCategoryId, item.title];
        }
        
        [postHtml appendString:@"</div>"];
    }
    
    if ([self.post.tags count])
    {
        [postHtml appendString:@"<div style=\"clear:both\">"];
        
        for (KMWordPressTag *item in self.post.tags)
        {
            [postHtml appendFormat:@"<a class=\"tag\" href=\"kmwordpress://tag:%@\">%@</a>", item.kMWordPressTagId, item.title];
        }
        
        [postHtml appendString:@"</div>"];
    }
    
    if (([postHtml rangeOfString:@"twitter-tweet"].location != NSNotFound) && ([postHtml rangeOfString:@"widgets.js"].location == NSNotFound))
    {
       [postHtml appendString:@"<script async src=\"//platform.twitter.com/widgets.js\" charset=\"utf-8\"></script>"]; 
    }
    
    postHtml = [postHtml stringByReplacingOccurrencesOfString:@"\"//platform.twitter.com/"
                                                   withString:@"\"http://platform.twitter.com/"].mutableCopy;
    
    [postHtml appendString:@"</div></body></html>"];
    
    [self.webView loadHTMLString:postHtml baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
    
    self.buttonControl.post = self.post;
    
    [self.buttonControl shortTapAction:nil];

    self.loadPreviousView.hidden = ![self canLoadPrevious];
    self.loadNextView.hidden = ![self canLoadNext];

    
    [[[GAI sharedInstance] defaultTracker] sendView:[NSString stringWithFormat:@"Post %@ %@", self.post.titlePlain, self.post.kMWordPressPostId]];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([[[request URL] scheme] isEqualToString:@"kmwordpress"])
    {
        UIViewController *vc;

        if ([[[request URL] host] isEqualToString:@"author"])
        {
            vc = [[KMPostListViewController alloc] initWithAuthorId:[[request URL] port]];
        }
        else if ([[[request URL] host] isEqualToString:@"showGallery"])
        {
            vc = [[NetworkPhotoAlbumViewController alloc] initWithPost:self.post];
        }
        else if ([[[request URL] host] isEqualToString:@"category"])
        {
            vc = [[KMPostListViewController alloc] initWithCategoryId:[[request URL] port]];
        }
        else if ([[[request URL] host] isEqualToString:@"tag"])
        {
            vc = [[KMPostListViewController alloc] initWithTagId:[[request URL] port]];
        }
        
        [self.navigationController pushViewController:vc animated:YES];
        
        return NO;
    }
    else if ([[[request URL] absoluteString] rangeOfString:@"broadsheet.ie/20"].location != NSNotFound)
    {
        KMPostViewController *vc = [[KMPostViewController alloc] initWithPostUrl:[request URL]];
        
        [self.navigationController pushViewController:vc animated:YES];
        
        return NO;
    }

    if (navigationType == UIWebViewNavigationTypeLinkClicked)
	{
        NSArray *parts = [[[request URL] absoluteString] componentsSeparatedByString:@"."];
        
        NSString *ext = [[parts lastObject] lowercaseString];
        
        if ([ext isEqualToString:@"jpg"] || [ext isEqualToString:@"jpeg"]
            || [ext isEqualToString:@"png"]
            || [ext isEqualToString:@"gif"])
        {
            if (!self.buttonControl.buttonsVisible)
            {
                NetworkPhotoAlbumViewController *detailViewController = [[NetworkPhotoAlbumViewController alloc] initWithPost:self.post
                                                                                                                 startAtIndex:[self.post findAttachmentIndex:[[request URL] absoluteString]]];
                [self.navigationController pushViewController:detailViewController animated:YES];
            }
            
        }
        else
        {
            KMWebViewController *vc = [[KMWebViewController alloc] initWithWebURL:request];
            [self.navigationController pushViewController:vc animated:YES];
        }
        
        return NO;
	}
    
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if ([self canLoadNext])
    {
        self.nextTitleLabel.text = [((KMWordPressPost *)self.dataSource.items[(self.index - 1)]).titlePlain stringByReplacingHTMLEntities];
    }
    else
    {
        self.nextTitleLabel.text = nil;
    }
    
    if ([self canLoadPrevious])
    {
        if ((self.index + 1) < [self.dataSource.items count])
        {
            self.previousTitleLabel.text = [((KMWordPressPost *)self.dataSource.items[(self.index + 1)]).titlePlain stringByReplacingHTMLEntities];
        }
        else if (self.post.previousTitle)
        {
            self.previousTitleLabel.text = [self.post.previousTitle stringByReplacingHTMLEntities];
        }
    }
    else
    {
        self.previousTitleLabel.text = nil;
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{

}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"])
    {
        if (self.scrollView.contentOffset.y == 0)
        {
            self.loadNextView.frame = CGRectMake(0, -50.0f, self.view.frame.size.width, 50.0f);
            self.loadPreviousView.frame = CGRectMake(0, self.view.frame.size.height, 320.0f, 50.0f);
            return;
        }
        
        if (self.scrollView.contentOffset.y < 0)
        {
            CGFloat offset = self.scrollView.contentOffset.y;
            
            if (offset < -50.0f) offset = -50.0f;
            
            self.loadNextView.frame = CGRectMake(0, 0 - (50.0f + offset) ,self.view.frame.size.width, 50.0f);
        }
        else if (self.view.frame.size.height > (self.scrollView.contentSize.height - self.scrollView.contentOffset.y))
        {
            CGFloat top = (self.view.frame.size.height - (self.view.frame.size.height - (self.scrollView.contentSize.height - self.scrollView.contentOffset.y)));
            if (top < (self.view.frame.size.height - 75.0f)) top = (self.view.frame.size.height - 75.0f);
            
            self.loadPreviousView.frame = CGRectMake(0, top , self.view.frame.size.width, 50.0f);
        }
    }
    else if ([keyPath isEqualToString:@"frame"])
    {
        self.loadNextView.frame = CGRectMake(0, -50.0f, self.view.frame.size.width, 50.0f);
        self.loadPreviousView.frame = CGRectMake(0, self.view.frame.size.height, 320.0f, 50.0f);
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.contentOffset.y <= -50.0f)
    {
        [self loadNext];
    }
    else if ((self.view.frame.size.height - self.loadPreviousView.frame.origin.y) >= 75.0f)
    {
        [self loadPrevious];
    }
}

#pragma mark - UIPinchGestureRecognizer
- (void)pinchAction:(UIPinchGestureRecognizer *)gestureRecognizer
{
    CGFloat pinchScale = gestureRecognizer.scale;
    
    DLog(@"pinchScale b: %f", pinchScale);
    /*
    pinchScale = round(pinchScale * 1000) / 1000.0;
    
    DLog(@"pinchScale a: %f", pinchScale);
    */
    
    if (pinchScale < 1)
    {
        self.fontSize = self.fontSize - (pinchScale / 1.5f);
    }
    else
    {
       self.fontSize = self.fontSize + (pinchScale / 2);
    }

    DLog(@"self.fontSize: %f", self.fontSize);
    
    if (self.fontSize < 16.0f)
    {
        self.fontSize = 16.0f;
    }
    else if (self.fontSize >= 40.0f)
    {
        self.fontSize = 40.0f;
    }
    
    [[NSUserDefaults standardUserDefaults] setFloat:self.fontSize forKey:@"fontsize"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"changeFontSize('%f')", self.fontSize]];
}
@end