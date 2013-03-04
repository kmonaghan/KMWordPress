//
//  KMViewController.m
//  KMWordPress
//
//  Created by Karl Monaghan on 09/01/2013.
//  Copyright (c) 2013 Crayons and Brown Paper. All rights reserved.
//

#import "UIView+KMWordPress.h"

#import "KMViewController.h"
#import "KMIndexViewController.h"

#import "KMFullScreenHelpView.h"

@interface KMViewController ()

@end

@implementation KMViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
 
    self.fullScreen = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.fullScreen addTarget:self
                        action:@selector(fullScreenToggle:)
              forControlEvents:UIControlEventTouchDown];
    [self.fullScreen setImage:[UIImage imageNamed:@"338-enter-fullscreen.png"] forState:UIControlStateNormal];
    self.fullScreen.frame = CGRectMake(self.view.frame.size.width - 50.0f, self.view.frame.size.height - 50.0f -44.0f, 75.0f, 75.0f);
    [self.fullScreen setAlpha:0.5];
    self.fullScreen.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.fullScreen];
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backButton addTarget:self
                        action:@selector(backAction)
              forControlEvents:UIControlEventTouchDown];
    [self.backButton setImage:[UIImage imageNamed:@"39-back.png"] forState:UIControlStateNormal];
    self.backButton.frame = CGRectMake(-25.0f, self.view.frame.size.height - 50.0f -44.0f, 75.0f, 75.0f);
    [self.backButton setAlpha:0.5];
    self.backButton.backgroundColor = [UIColor clearColor];
    self.backButton.hidden = YES;
    [self.view addSubview:self.backButton];
    
    if (self.wantsFullScreenLayout)
    {
        [self.fullScreen setImage:[UIImage imageNamed:@"338-enter-fullscreen.png"] forState:UIControlStateNormal];
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    if (self.wantsFullScreenLayout || [KMWordPress sharedInstance].fullScreen)
    {
        [self makeFullscreen:YES];
    }

    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)attachBackSwipe:(UIView *)view
{
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(back)];
    
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [view addGestureRecognizer:swipe];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)fullScreenToggle:(id)sender
{
    [self makeFullscreen:!self.wantsFullScreenLayout];
}

- (void)makeFullscreen:(BOOL)fullscreen
{
    if (self.wantsFullScreenLayout == fullscreen)
    {
        return;
    }

    [[UIApplication sharedApplication] setStatusBarHidden:fullscreen
                                            withAnimation:UIStatusBarAnimationSlide];
    [self.navigationController setNavigationBarHidden:fullscreen
                                             animated:YES];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    
    self.wantsFullScreenLayout = fullscreen;
    
    //CGFloat duration = (sender) ? 0.1f : 0;
    CGFloat duration = 0.1f;
    
    [UIView animateWithDuration:duration animations:^(){
        self.fullScreen.frame = CGRectMake(self.view.frame.size.width - 50.0f, self.view.frame.size.height - 50.0f, 75.0f, 75.0f);
        self.backButton.frame = CGRectMake(-25.0f, self.view.frame.size.height - 50.0f, 75.0f, 75.0f);
    }
                     completion:^(BOOL finished) {
                         
                         [self.fullScreen setImage:[UIImage imageNamed:(self.wantsFullScreenLayout) ? @"339-exit-fullscreen.png" : @"338-enter-fullscreen.png"] forState:UIControlStateNormal];
                         if (![self isKindOfClass:[KMIndexViewController class]])
                         {
                             self.backButton.hidden = !self.wantsFullScreenLayout;
                         }
                        
                         [KMWordPress sharedInstance].fullScreen = fullscreen;
                     }];
    
    if (fullscreen && ![[NSUserDefaults standardUserDefaults] boolForKey:@"fullscreenHelpShown"])
    {
        KMFullScreenHelpView *view = [KMFullScreenHelpView viewFromNib];
        
        [self.view addSubview:view];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"fullscreenHelpShown"];
    }
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
