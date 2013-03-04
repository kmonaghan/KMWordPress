//
//  KMWebViewController.m
//  KMWordPress
//
//  Created by Karl Monaghan on 30/10/2012.
//  Copyright (c) 2012 Crayons and Brown Paper. All rights reserved.
//

#import "KMWebViewController.h"

@interface KMWebViewController ()
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *webBackButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *forwardButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *stopReloadButton;
@property (strong, nonatomic) UIActivityIndicatorView *activity;
@property (strong, nonatomic) IBOutlet UIToolbar *webToolBar;

@property (strong, nonatomic) NSURLRequest *request;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;


- (IBAction)backAction:(id)sender;
- (IBAction)forwardAction:(id)sender;
- (IBAction)stopStartAction:(id)sender;
- (IBAction)openInSafariAction:(id)sender;
- (IBAction)toggleWebFullScreen:(id)sender;

@end

@implementation KMWebViewController
- (id)initWithWebURL:(NSURLRequest *)request
{
    self = [self initWithNibName:@"KMWebViewController" bundle:nil];
    if (self) {
        // Custom initialization
        self.request = request;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    _webView.delegate = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    // Do any additional setup after loading the view from its nib.
    self.activity = [UIActivityIndicatorView new];
    [self.activity startAnimating];
    self.activity.hidesWhenStopped = YES;
    self.activity.frame = CGRectMake(3,3,25,25);
    
    self.activityIndicator.hidden = YES;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activity];
    
    self.webView.delegate = self;
    
    self.webBackButton.enabled = NO;
    self.forwardButton.enabled = NO;
    
    [self.webView loadRequest:self.request];
    
    [self attachBackSwipe:self.webView];
    
    [[[GAI sharedInstance] defaultTracker] sendView:@"Web Browser"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setWebView:nil];
    [self setWebToolBar:nil];
    [self setActivityIndicator:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.wantsFullScreenLayout)
    {
        self.fullScreen.hidden = YES;
        self.backButton.hidden = YES;
    }
}

- (IBAction)backAction:(id)sender
{
    [self.webView goBack];
}

- (IBAction)forwardAction:(id)sender
{
    [self.webView goForward];
}

- (IBAction)stopStartAction:(id)sender
{
    if (self.webView.isLoading)
    {
        [self.webView stopLoading];
    }
    else
    {
        [self.webView reload];
    }
}

- (IBAction)openInSafariAction:(id)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"Open in Safari", nil), NSLocalizedString(@"Copy To Clipboard", nil), nil];
    [sheet showInView:self.view];
}

- (IBAction)toggleWebFullScreen:(id)sender
{
    [self makeFullscreen:YES];
}

- (void)makeFullscreen:(BOOL)fullscreen
{
    [super makeFullscreen:fullscreen];
    
    self.fullScreen.hidden = !fullscreen;
    self.backButton.hidden = !fullscreen;

    self.webToolBar.hidden = fullscreen;
    
    if (self.webToolBar.hidden)
    {
        self.webView.frame = [UIScreen mainScreen].bounds;
        DLog(@"%@", NSStringFromCGRect(self.webView.frame));
    }
    else
    {
        self.webView.$height = [UIScreen mainScreen].bounds.size.height - 20.0f - 44.0f - 44.0f;
    }
    //[self.navigationController setToolbarHidden:fullscreen animated:YES];
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.activityIndicator.hidden = YES;
    
    if (!webView.loading)
    {
        self.stopReloadButton.image = [UIImage imageNamed:@"reload.png"];
    
        self.webBackButton.enabled = [self.webView canGoBack];
        self.forwardButton.enabled = [self.webView canGoForward];
        
        [self.activity stopAnimating];
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.activity startAnimating];
    
    if (self.wantsFullScreenLayout)
    {
        self.activityIndicator.hidden = NO;
        [self.activityIndicator startAnimating];
    }
    self.activity.hidden = NO;
    
    self.stopReloadButton.image = [UIImage imageNamed:@"46-no.png"];
}

#pragma  mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex)
    {
        return;
    }
    
    switch (buttonIndex) {
        case 0:
        {
            [[UIApplication sharedApplication] openURL:[self.webView.request URL]];
        }
            break;
        case 1:
        {
            UIPasteboard *pb = [UIPasteboard generalPasteboard];
            [pb setString:[[self.webView.request URL] absoluteString]];
        }
            break;
        default:
            break;
    }
}
@end
