//
//  KMWordPressPostControl.m
//  KMWordPress
//
//  Created by Karl Monaghan on 17/12/2012.
//  Copyright (c) 2012 Crayons and Brown Paper. All rights reserved.
//

#define COLOR_RGB(r,g,b,a)      [UIColor colorWithRed:((r)/255.0) green:((g)/255.0) blue:((b)/255.0) alpha:(a)]

#import <Twitter/Twitter.h>
#import "Facebook.h"

#import "UIView+KMWordPress.h"
#import "GRButtons.h"

#import "KMWordPressPostControl.h"

#import "KMCommentListViewController.h"
#import "KMCreateCommentViewController.h"

#import "KMWordPressPost.h"

@interface KMWordPressPostControl()
@property (nonatomic, assign) BOOL shareButtonsVisible;
@property (nonatomic, assign) BOOL dontHide;

@property (nonatomic, strong) UIView *buttonView;
@property (nonatomic, strong) UIView *captureView;
@property (nonatomic, strong) UIButton *viewCommentButton;
@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) UIButton *makeCommentButton;
@property (nonatomic, strong) UIButton *makeFavouriteButton;
@property (nonatomic, strong) UIView *viewCommentButtonView;
@property (nonatomic, strong) UIView *shareButtonView;
@property (nonatomic, strong) UIView *makeCommentButtonView;
@property (nonatomic, strong) UIView *makeFavouriteButtonView;

@property (nonatomic, strong) UIView *shareButtons;
@property (nonatomic, strong) UIButton *facebookButton;
@property (nonatomic, strong) UIButton *twitterButton;
@property (nonatomic, strong) UIButton *emailButton;
@property (nonatomic, strong) UIView *facebookView;
@property (nonatomic, strong) UIView *twitterView;
@property (nonatomic, strong) UIView *emailView;

@property (nonatomic, strong) UITapGestureRecognizer *shortTap;

@end

@implementation KMWordPressPostControl
- (void)attachButtonsToView
{
    self.captureView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.delegate.view.frame.size.width, self.delegate.view.frame.size.height)];
    self.captureView.backgroundColor = [UIColor clearColor];
    
    self.shortTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                            action:@selector(shortTapAction:)];
    self.shortTap.numberOfTapsRequired = 1;
    
    self.shortTap.delegate = self;

    [self.captureView addGestureRecognizer:self.shortTap];

    self.captureView.hidden = YES;
    [self.delegate.view addSubview:self.captureView];

    self.buttonView = [[UIView alloc] initWithFrame:CGRectMake(-300.0f, -300.0f, 300.0f, 300.0f)];
    
    self.viewCommentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.viewCommentButton addTarget:self
                               action:@selector(viewComments)
                     forControlEvents:UIControlEventTouchDown];
    [self.viewCommentButton setImage:[UIImage imageNamed:@"09-chat-2.png"] forState:UIControlStateNormal];
    self.viewCommentButton.frame = CGRectMake(0, 0, 50.0f, 50.0f);
    
    self.viewCommentButtonView = [[UIView alloc] initWithFrame:CGRectMake(50.0f, 50.0f, 50.0f, 50.0f)];
    [self.viewCommentButtonView setAlpha:0];
    [self.viewCommentButtonView circleTheSquare:[UIColor lightGrayColor]];
    
    [self.viewCommentButtonView addSubview:self.viewCommentButton];
    [self.buttonView addSubview:self.self.viewCommentButtonView];
    
    self.shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.shareButton addTarget:self
                         action:@selector(share)
               forControlEvents:UIControlEventTouchDown];
    [self.shareButton setImage:[UIImage imageNamed:@"211-action-grey.png"] forState:UIControlStateNormal];
    self.shareButton.frame = CGRectMake(0, 0, 50.0f, 50.0f);

    self.shareButtonView = [[UIView alloc] initWithFrame:CGRectMake(50.0f, 50.0f, 50.0f, 50.0f)];
    [self.shareButtonView setAlpha:0];
    [self.shareButtonView circleTheSquare:[UIColor lightGrayColor]];
    
    [self.shareButtonView addSubview:self.shareButton];
    [self.buttonView addSubview:self.shareButtonView];
    
    self.makeCommentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.makeCommentButton addTarget:self
                               action:@selector(makeComment)
                     forControlEvents:UIControlEventTouchDown];
    [self.makeCommentButton setImage:[UIImage imageNamed:@"216-compose.png"] forState:UIControlStateNormal];
    self.makeCommentButton.frame = CGRectMake(0, 0, 50.0f, 50.0f);
    
    self.makeCommentButtonView = [[UIView alloc] initWithFrame:CGRectMake(50.0f, 50.0f, 50.0f, 50.0f)];
    [self.makeCommentButtonView setAlpha:0];
    [self.makeCommentButtonView circleTheSquare:[UIColor lightGrayColor]];
    
    [self.makeCommentButtonView addSubview:self.makeCommentButton];
    [self.buttonView addSubview:self.makeCommentButtonView];
    
    [self.delegate.view addSubview:self.buttonView];
    
    self.shareButtons = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100.0f, 200.0f)];
    
    self.emailButton = GRButton(GRTypeMail, 5.0f, 5.0f, 40.0f, self, @selector(shareViaEmail), COLOR_RGB(225, 119, 26, 1), GRStyleOut);
    self.twitterButton = GRButton(GRTypeTwitter, 5.0f, 5.0f, 40.0f, self, @selector(postToTwitter), COLOR_RGB(0, 172, 238, 1), GRStyleOut);
    self.facebookButton = GRButton(GRTypeFacebook, 5.0f, 5.0f, 40.0f, self, @selector(postToFacebookFeed), COLOR_RGB(60, 90, 154, 1), GRStyleOut);
    
    self.emailView = [[UIView alloc] initWithFrame:CGRectMake(0, 50.0f, 50.0f, 50.0f)];
    [self.emailView circleTheSquare:COLOR_RGB(225, 119, 26, 1)];
    
    [self.emailView addSubview:self.emailButton];
    [self.shareButtons addSubview:self.emailView];
    
    self.twitterView = [[UIView alloc] initWithFrame:CGRectMake(0, 50.0f, 50.0f, 50.0f)];
    [self.twitterView circleTheSquare:COLOR_RGB(0, 172, 238, 1)];
    
    [self.twitterView addSubview:self.twitterButton];
    [self.shareButtons addSubview:self.twitterView];
    
    self.facebookView = [[UIView alloc] initWithFrame:CGRectMake(0, 50.0f, 50.0f, 50.0f)];
    [self.facebookView circleTheSquare:COLOR_RGB(60, 90, 154, 1)];
    
    [self.facebookView addSubview:self.facebookButton];
    [self.shareButtons addSubview:self.facebookView];
    
    [self.shareButtons setAlpha:0];
    
    [self.buttonView addSubview:self.shareButtons];
    
    UITapGestureRecognizer *shortTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(shortTapAction:)];
    shortTap2.numberOfTapsRequired = 1;
    shortTap2.delegate = self;
    
    [self.buttonView addGestureRecognizer:shortTap2];
    
    UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(longTapAction:)];
    
    longTap.delegate = self;
    
    [self.delegate.view addGestureRecognizer:longTap];
    
    self.viewCommentButtonView.center = CGPointMake(150.0f, 125.0f);
    self.shareButtonView.center = CGPointMake(150.0f, 125.0f);
    self.makeCommentButtonView.center = CGPointMake(150.0f, 125.0f);

}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]])
    {
        return NO;
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{    
    if (([touch.view isKindOfClass:[UIButton class]]))
    {
        return NO;
    }
    
    return YES;
}

#pragma mark - Facebook
- (void)postToFacebookFeed
{
    [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"uiAction"
                                                      withAction:@"facebookShare"
                                                       withLabel:nil
                                                       withValue:nil];
    
    [self shortTapAction:nil];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"name":self.post.title , @"link":self.post.url, @"description" : self.post.content}];
    
    // Initiate a Facebook instance
    Facebook *facebook = [[Facebook alloc] initWithAppId:FBSession.activeSession.appID andDelegate:nil];
    
    // Set the session information for the Facebook instance
    facebook.accessToken = FBSession.activeSession.accessToken;
    facebook.expirationDate = FBSession.activeSession.expirationDate;
    
    // Invoke the dialog
    [facebook dialog:@"feed" andParams:params andDelegate:nil];
}

#pragma mark - Twitter
- (void)postToTwitter
{
    [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"uiAction"
                                                      withAction:@"twitterShare"
                                                       withLabel:nil
                                                       withValue:nil];
    
    [self shortTapAction:nil];
    
    if ([TWTweetComposeViewController canSendTweet])
    {
        TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];
        
        [tweetSheet setInitialText:[NSString stringWithFormat:@"%@ via @broadsheet_ie", self.post.title]];
        
        [tweetSheet addURL: [NSURL URLWithString:self.post.url]];
        
        [self.delegate.navigationController presentModalViewController:tweetSheet animated:YES];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"No Twitter Accounts"
                                  message:@"You must set up at least one account in Settings > Twitter before you can share via Twitter"
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark - Send Email
- (void)shareViaEmail
{
    [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"uiAction"
                                                      withAction:@"emailShare"
                                                       withLabel:nil
                                                       withValue:nil];
    
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        
        mailer.mailComposeDelegate = self;
        
        [mailer setSubject:[NSString stringWithFormat:@"You may like this story: %@", self.post.titlePlain]];
        
        NSString *body = [NSString stringWithFormat:@"Hi,<br /><br />I thought you might like this story '%@'.  You can view the full story on the <a href=\"%@\">Broadsheet.ie</a> site.", self.post.titlePlain, self.post.url];
        [mailer setMessageBody:body isHTML:YES];
        
        [self.delegate.navigationController presentModalViewController:mailer animated:YES];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No email settings"
                                                        message:@"You can't send emails from this device"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)sendEmail
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        
        mailer.mailComposeDelegate = self;
        
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        
        [mailer setSubject:[NSString stringWithFormat:@"Feedback for %@", [infoDictionary objectForKey:@"CFBundleName"]]];
        
        NSString *body = [NSString stringWithFormat:@"\n\n\nApp version: %@ (%@)\niOS Version: %@\niOS Device: %@", [infoDictionary objectForKey:@"CFBundleShortVersionString"], [infoDictionary objectForKey:@"CFBundleVersion"], [[UIDevice currentDevice] systemVersion], [[UIDevice currentDevice] model]];
        [mailer setMessageBody:body isHTML:NO];
        
        [mailer setToRecipients:@[@"feedback@crayonsandbrownpaper.com"]];
        
        [self.delegate.navigationController presentModalViewController:mailer animated:YES];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No email settings"
                                                        message:@"You can't send emails from this device"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            //DLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            //DLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            //DLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            //DLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            //DLog(@"Mail not sent.");
            break;
    }
    
    [controller.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - button actions
- (void)share
{
    [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"uiAction"
                                                      withAction:@"showShare"
                                                       withLabel:nil
                                                       withValue:nil];
    
    if (self.shareButtonsVisible)
    {
        return;
    }
    
    self.shareButtons.center = CGPointMake(self.shareButtonView.center.x + 25.0f, self.shareButtonView.center.y) ;
    self.dontHide = YES;

    [UIView animateWithDuration:0.3
                     animations:^(void) {
                         [self.shareButtons setAlpha:1.0];
                         
                         [self.facebookView setAlpha:1.0];
                         [self.emailView setAlpha:1.0];
                         [self.twitterView setAlpha:1.0];
                         
                         self.twitterView.frame = CGRectMake(50.0f, 15.0f, 50.0f, 50.0f);
                         self.facebookView.frame = CGRectMake(50.0f, 75.0f, 50.0f, 50);
                         self.emailView.frame = CGRectMake(50.0f, 135.0f, 50.0f, 50.0f);
                         
                     }
                     completion:^(BOOL finished) {
                         self.shareButtonsVisible = YES;
                         self.dontHide = NO;
                     }
     ];
}

- (void)viewComments
{
    [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"uiAction"
                                                      withAction:@"viewComments"
                                                       withLabel:nil
                                                       withValue:nil];
    
    if ([self.post.commentCount intValue])
    {
        KMCommentListViewController *vc = [[KMCommentListViewController alloc] initWithPost:self.post
                                                                             withFullScreen:self.delegate.wantsFullScreenLayout];
        
        [self.delegate.navigationController pushViewController:vc animated:YES];
    }
}

- (void)makeComment
{
    [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"uiAction"
                                                      withAction:@"makeComment"
                                                       withLabel:nil
                                                       withValue:nil];
    
    KMCreateCommentViewController *vc = [[KMCreateCommentViewController alloc] initWithPost:self.post];
    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self.delegate.navigationController presentViewController:nc animated:YES completion:nil];
}

- (void)favourite
{
    
}

#pragma mark - touch events
- (void)longTapAction:(UILongPressGestureRecognizer *)gesture
{
    if (self.buttonsVisible)
    {
        return;
    }

    [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"uiAction"
                                                      withAction:@"showControls"
                                                       withLabel:nil
                                                       withValue:nil];
    
    self.buttonView.center = [gesture locationInView:gesture.view];
    
    [UIView animateWithDuration:0.3
                     animations:^(void) {
                         [self.buttonView setAlpha:1.0];
                         
                         CGFloat offset = 95.0f;
                         if ([self.post.commentCount intValue])
                         {
                             [self.viewCommentButtonView setAlpha:1.0];
                             
                             offset = 125.0f;
                         }
                         
                         [self.shareButtonView setAlpha:1.0];
                                                  
                         self.viewCommentButtonView.frame = CGRectMake(65.0f, 75.0f, 50.0f, 50.0f);
                         if ([self.post.commentStatus isEqualToString:@"open"])
                         {
                             [self.makeCommentButtonView setAlpha:1.0];
                             self.makeCommentButton.enabled = YES;
                             
                             self.makeCommentButtonView.frame = CGRectMake(offset, 75.0f, 50.0f, 50.0f);
                             self.shareButtonView.frame = CGRectMake(offset + 60.0f, 75.0f, 50.0f, 50.0f);
                         }
                         else
                         {
                             self.shareButtonView.frame = CGRectMake(125.0f, 75.0f, 50.0f, 50.0f);
                             
                             self.makeCommentButton.enabled = NO;
                         }
                     }
                     completion:^(BOOL finished) {
                         self.buttonsVisible = YES;
                         self.captureView.hidden = NO;
                     }
     ];
    
    
}

- (void)shortTapAction:(UITapGestureRecognizer *)gesture
{
    if (self.dontHide)
    {
        return;
    }
    
    if (self.shareButtonsVisible)
    {
        [UIView animateWithDuration:0.3
                         animations:^(void) {
                             [self.shareButtons setAlpha:0];
                             
                             [self.facebookView setAlpha:0];
                             [self.twitterView setAlpha:0];
                             [self.emailView setAlpha:0];
                             
                             self.facebookView.frame = CGRectMake(0, 50.0f, 50.0f, 50.0f);
                             self.twitterView.frame = CGRectMake(0, 50.0f, 50.0f, 50.0f);
                             self.emailView.frame = CGRectMake(0, 50.0f, 50.0f, 50.0f);
                         }
                         completion:^(BOOL finished) {
                             self.shareButtonsVisible = NO;
                         }
         ];
    }
    
    if (self.buttonsVisible)
    {
        CGPoint center = CGPointMake(self.buttonView.$width / 2, self.buttonView.$height / 2);
        
        [UIView animateWithDuration:0.3
                         animations:^(void) {
                             [self.buttonView setAlpha:0];
                             
                             [self.viewCommentButtonView setAlpha:0];
                             [self.shareButtonView setAlpha:0];
                             [self.makeCommentButtonView setAlpha:0];
                             //[self.makeFavouriteButtonView setAlpha:0];
                             
                             self.viewCommentButtonView.center = center;
                             self.shareButtonView.center = center;
                             self.makeCommentButtonView.center = center;
                         }
                         completion:^(BOOL finished) {
                             self.buttonsVisible = NO;
                             self.captureView.hidden = YES;
                         }
         ];
    }
}

@end
