//
//  KMCommentListViewController.m
//  KMWordPress
//
//  Created by Karl Monaghan on 22/10/2012.
//  Copyright (c) 2012 Crayons and Brown Paper. All rights reserved.
//
#import "KMCommentListViewController.h"
#import "KMCreateCommentViewController.h"
#import "KMWebViewController.h"

#import "KMPullToRefreshContentView.h"

#import "KMCommentListDataSource.h"

#import "KMCommentTableViewCell.h"

#import "KMWordPressPost.h"
#import "KMWordPressPostComment.h"

@interface KMCommentListViewController()
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) KMCommentListDataSource *dataSource;
@property (nonatomic, strong) KMWordPressPost *post;
@property (nonatomic, assign) BOOL startInFullScreen;
@property (strong, nonatomic) SSPullToRefreshView *pullToRefreshView;
@end
@implementation KMCommentListViewController
- (id)initWithPost:(KMWordPressPost *)post withFullScreen:(BOOL)fullscreen
{
    self = [super initWithNibName:nil bundle:nil];
    
    if (self)
    {
        _post = post;
        _dataSource = [[KMCommentListDataSource alloc] initWithPost:post];
        _dataSource.parentViewController = self;
        _startInFullScreen = fullscreen;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.tableView.delegate = self;
    self.tableView.dataSource = self.dataSource;
    
    [self.view addSubview:self.tableView];
    
    self.pullToRefreshView = [[SSPullToRefreshView alloc] initWithScrollView:self.tableView delegate:self];
    self.pullToRefreshView.contentView = [[KMPullToRefreshContentView alloc] initWithFrame:CGRectZero];
    
    UINib *nib = [UINib nibWithNibName: @"KMCommentTableViewCell"  bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"KMCommentTableViewCell"];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                           target:self
                                                                                           action:@selector(makeComment)];
    
    [self.view bringSubviewToFront:self.fullScreen];
    [self.view bringSubviewToFront:self.backButton];
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(back)];
    
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipe];
    
    [self attachBackSwipe:self.view];
    
    [[[GAI sharedInstance] defaultTracker] sendView:[NSString stringWithFormat:@"Comment List: %@ %@", self.post.titlePlain, self.post.kMWordPressPostId]];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.pullToRefreshView = nil;
}

- (void)makeComment
{
    [self replyToComment:nil];
}

- (void)replyToComment:(KMWordPressPostComment *)comment
{
    KMCreateCommentViewController *vc = [[KMCreateCommentViewController alloc] initWithPost:self.post withComment:comment];
    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    __block KMCommentListViewController *blockSelf = self;
    vc.redirectResponse = ^(KMWordPressPostComment *reply) {
        if (reply)
        {
            DLog(@"reply: %@", reply);
            
            [blockSelf.presentedViewController dismissViewControllerAnimated:YES
                                                                  completion:nil];
            
            blockSelf.dataSource.items = blockSelf.post.comments;
            
            [blockSelf.tableView reloadData];
            
            int index = [self.dataSource.items indexOfObject:reply];
            
            if (index)
            {
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]
                                      atScrollPosition:UITableViewScrollPositionMiddle
                                              animated:YES];
            }
        }
    };
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self.navigationController presentViewController:nc animated:YES completion:nil];
}

- (void)showWebPage:(NSURL *)URL
{
    KMWebViewController *vc = [[KMWebViewController alloc] initWithWebURL:[NSURLRequest requestWithURL:URL]];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	KMCommentTableViewCell *cell = (KMCommentTableViewCell *)[self.dataSource tableView:self.tableView cellForRowAtIndexPath:indexPath];

	return [cell requiredRowHeightInTableView:tableView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	KMCommentTableViewCell *cell = (KMCommentTableViewCell *)[self.dataSource tableView:self.tableView cellForRowAtIndexPath:indexPath];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{    
    KMWordPressPostComment *comment = self.dataSource.items[indexPath.row];
    
    if ([comment.status isEqualToString:@"pending"])
    {
        //cell.backgroundColor = [UIColor lightGrayColor];
    }
}

#pragma mark -
#pragma mark SSPullToRefreshViewDelegate Methods

- (void)pullToRefreshViewDidStartLoading:(SSPullToRefreshView *)view {
    [self.pullToRefreshView startLoading];
    
    __block KMCommentListViewController *blockSelf = self;
    
    [[KMWordPressAPIClient sharedClient] getPath:@""
                                      parameters:@{@"json" : @"get_post", @"post_id" : self.post.kMWordPressPostId}
                                         success:^(AFHTTPRequestOperation *operation, id JSON) {
                                             DLog(@"JSON: %@", JSON);
                                             
                                             blockSelf.post = [KMWordPressPost instanceFromDictionary:JSON[@"post"]];
                                             
                                             blockSelf.dataSource.items = blockSelf.post.comments;
                                             
                                             [blockSelf.tableView reloadData];
                                             [blockSelf.pullToRefreshView finishLoading];
                                             [blockSelf.pullToRefreshView.contentView setLastUpdatedAt:[NSDate date] withPullToRefreshView:blockSelf.pullToRefreshView];
                                             
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             DLog(@"Failure: %@", error);
                                             
                                             [blockSelf showError:error];
                                             
                                             [blockSelf.pullToRefreshView finishLoading];
                                         }];

}
@end
