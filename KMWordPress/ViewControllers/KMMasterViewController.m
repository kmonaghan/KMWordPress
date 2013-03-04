//
//  KMMasterViewController.m
//  KMWordPress
//
//  Created by Karl Monaghan on 03/01/2013.
//  Copyright (c) 2013 Crayons and Brown Paper. All rights reserved.
//

#import "KMMasterViewController.h"
#import "KMDetailViewController.h"
#import "KMAboutViewController.h"

#import "KMPostListDataSource.h"

@interface KMMasterViewController ()

@end

@implementation KMMasterViewController

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
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoDark];
    
    button.frame = CGRectMake(button.frame.origin.x, button.frame.origin.y, button.frame.size.width + 13, button.frame.size.height);
    
    [button addTarget:self action:@selector(aboutAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *infoItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    self.navigationItem.leftBarButtonItem = infoItem;
    
    self.detailViewController.dataSource = self.dataSource;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];
    
    [self.detailViewController setDetailItem:self.dataSource.items[indexPath.row] withIndex:indexPath.row];
}

- (void)finishedLoad:(BOOL)more
{
    [super finishedLoad:more];
    
    [self.detailViewController setDetailItem:self.dataSource.items[0] withIndex:0];
}

- (IBAction)aboutAction:(id)sender
{
    KMAboutViewController *vc = [[KMAboutViewController alloc] initWithNibName:@"KMAboutViewController" bundle:nil];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self.navigationController presentViewController:navController
                                            animated:YES
                                          completion:nil];
}
@end
