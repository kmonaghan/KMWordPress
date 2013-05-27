//
//  KMAppDelegate.m
//  KMWordPress
//
//  Created by Karl Monaghan on 30/09/2012.
//  Copyright (c) 2012 Crayons and Brown Paper. All rights reserved.
//
#import "YISplashScreen.h"
#import "Harpy.h"
#import "Appirater.h"
#import "AFNetworkActivityIndicatorManager.h"

#import "KMAppDelegate.h"

#import "KMIndexViewController.h"

#import "KMMasterViewController.h"
#import "KMDetailViewController.h"

#import "KMNavigationController.h"

@interface KMAppDelegate()
@property (nonatomic, strong) UISplitViewController *splitViewController;
@end

@implementation KMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [YISplashScreen show];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    [YISplashScreen hide];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    KMIndexViewController *viewController = [[KMIndexViewController alloc] initWithNibName:nil bundle:nil];
    
    self.navController = [[KMNavigationController alloc] initWithRootViewController:viewController];
    
    self.window.rootViewController = self.navController;
    
    [self.window makeKeyAndVisible];
    
    [[Harpy sharedInstance] setAppID:@"413093424"];
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    [GAI sharedInstance].dispatchInterval = 20;
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-SOMENUMBER-3"];
    
    [Appirater setAppId:@"413093424"];
    [Appirater setDaysUntilPrompt:7];
    [Appirater setUsesUntilPrompt:21];
    [Appirater setTimeBeforeReminding:2];
    
    [Appirater appLaunched:YES];
        
    return YES;
}

-(BOOL)application:(UIApplication*)application
           openURL:(NSURL*)url
 sourceApplication:(NSString*)sourceApplication
        annotation:(id)annotation
{
    [self.navController popToRootViewControllerAnimated:NO];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [Appirater appEnteredForeground:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [[Harpy sharedInstance] checkVersionDaily];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
@end
