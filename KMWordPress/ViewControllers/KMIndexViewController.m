//
//  KMIndexViewController.m
//  KMWordPress
//
//  Created by Karl Monaghan on 02/12/2012.
//  Copyright (c) 2012 Crayons and Brown Paper. All rights reserved.
//

#import "UISearchBar+alwaysEnableCancelButton.h"

#import "KMIndexViewController.h"
#import "KMPostViewController.h"
#import "KMAboutViewController.h"
#import "KMSubmitTipViewController.h"
#import "NetworkPhotoAlbumViewController.h"

#import "KMPostListDataSource.h"

#import "KMWordPressPost.h"

@interface KMIndexViewController ()
@property (nonatomic, strong) UISearchBar *blogSearch;
@property (nonatomic, strong) UIView *menuView;

@property (nonatomic, assign) CGPoint startLocation;

@property (nonatomic, assign) BOOL menuDisplayed;

@property (nonatomic, strong) NSDateFormatter *dateFormat;

@end

@implementation KMIndexViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.dateFormat = [[NSDateFormatter alloc] init];
        [self.dateFormat setDateFormat:@"EEE"];
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    self.title = @"Broadsheet";
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoLight];
    
    button.frame = CGRectMake(button.frame.origin.x, button.frame.origin.y, button.frame.size.width + 13, button.frame.size.height);
    
    [button addTarget:self action:@selector(aboutAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *infoItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    self.navigationItem.leftBarButtonItem = infoItem;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                                                           target:self
                                                                                           action:@selector(submitTip)];
    self.blogSearch = [[UISearchBar alloc] initWithFrame:CGRectMake(0,0,320,44)];
    self.blogSearch.delegate = self;
    self.blogSearch.showsScopeBar = YES;
    self.blogSearch.placeholder = @"Search Broadsheet.ie";
    
    self.tableView.tableHeaderView = self.blogSearch;
    
    self.tableView.contentOffset = CGPointMake(0, 44.0f);
    
    self.tableView.delegate = self;

    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"broadsheet_black.png"]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ((CGPointEqualToPoint(self.tableView.contentOffset, CGPointZero)) || (self.tableView.contentOffset.y <= 44.0f))
    {
        self.tableView.contentOffset = CGPointMake(0, 44.0f);
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadPosts)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated

{
    [self.blogSearch resignFirstResponder];
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)aboutAction:(id)sender
{
    KMAboutViewController *vc = [[KMAboutViewController alloc] initWithNibName:@"KMAboutViewController" bundle:nil];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self.navigationController presentViewController:navController
                                            animated:YES
                                          completion:nil];
}

- (void) endRefresh {
    [super endRefresh];
    
    self.tableView.contentOffset = CGPointMake(0, 44.0f);
}

- (void)submitTip
{
    KMSubmitTipViewController *vc = [[KMSubmitTipViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self.navigationController presentViewController:navController
                                            animated:YES
                                          completion:nil];
}

- (void)reloadPosts
{
    [self loadPosts:NO];
}

- (void)loadPosts:(BOOL)more
{
    if (!more)
    {
        [self.blogSearch resignFirstResponder];
    }
    
    [super loadPosts:more];
}

- (void)finishedLoad:(BOOL)more
{
    [super finishedLoad:more];
    
    if (!more)
    {
        [self endRefresh];
    }
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchBar.text length])
    {
        searchBar.showsCancelButton = YES;
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{        
    [self.blogSearch resignFirstResponder];
    
    if ([self.blogSearch.text length])
    {
        [self.dataSource searchPosts:self.blogSearch.text];
        
        [self loadPosts:NO];
        
        [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"uiAction"
                                                          withAction:@"search"
                                                           withLabel:nil
                                                           withValue:nil];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.blogSearch resignFirstResponder];
        
    self.blogSearch.text = @"";
    
    searchBar.showsCancelButton = NO;
    
    [self.dataSource fetchRecentPosts];
    
    [self loadPosts:NO];
}

- (void)showMenu:(UIGestureRecognizer *)sender
{
    if (self.menuDisplayed)
    {
        return;
    }
    
    CGPoint location = [sender locationInView:self.view];
    
    if ((sender.state == UIGestureRecognizerStateBegan) && CGPointEqualToPoint(self.startLocation, CGPointZero))
    {
        self.startLocation = location;
    }
    else if (sender.state == UIGestureRecognizerStateEnded)
    {
        if (self.startLocation.y > location.y)
        {
            self.menuDisplayed = YES;
            
            CGRect menuFrame = self.menuView.frame;
            menuFrame.origin.y = self.tableView.frame.size.height - 50;
            
            CGRect tableFrame = self.tableView.frame;
            tableFrame.size.height = self.view.frame.size.height - 50.0F;
            
            [UIView animateWithDuration:0.3F animations:^(){
                self.menuView.frame = menuFrame;
                self.tableView.frame = tableFrame;
            }];
        }
        
        self.startLocation = CGPointZero;
    }
}

#pragma mark - UIScrollViewDelegate
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    [scrollView setContentOffset:CGPointMake(0, 44) animated:YES];
    
    return NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ((scrollView.contentOffset.y > 0) && (scrollView.contentOffset.y < 44))
    {
        [scrollView setContentOffset:CGPointMake(0, 44) animated:YES];
    }
}
@end
