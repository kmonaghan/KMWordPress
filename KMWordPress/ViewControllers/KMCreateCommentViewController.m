//
//  KMCreateCommentViewController.m
//  KMWordPress
//
//  Created by Karl Monaghan on 22/10/2012.
//  Copyright (c) 2012 Crayons and Brown Paper. All rights reserved.
//

#import "MBProgressHUD.h"
#import "HTAutocompleteTextField.h"
#import "HTAutocompleteManager.h"

#import "KMCreateCommentViewController.h"

#import "KMTextfieldCell.h"
#import "KMTextviewCell.h"

#import "KMWordPressPost.h"
#import "KMWordPressPostComment.h"

@interface KMCreateCommentViewController()
@property (strong, nonatomic) UITextField *name;
@property (strong, nonatomic) HTAutocompleteTextField *email;
@property (strong, nonatomic) UITextField *url;
@property (strong, nonatomic) UITextView *message;
@property (nonatomic, strong) KMWordPressPost *post;
@property (nonatomic, strong) KMWordPressPostComment *comment;
@end

@implementation KMCreateCommentViewController
- (id)initWithPost:(KMWordPressPost *)post
{
    self = [self initWithStyle:UITableViewStyleGrouped];
    
    if (self)
    {
        self.post = post;
    }
    return self;
}

- (id)initWithPost:(KMWordPressPost *)post withComment:(KMWordPressPostComment *)comment
{
    self = [self initWithPost:post];
    
    if (self)
    {
        self.comment = comment;
    }
    
    return self;
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        _name = [[UITextField alloc] initWithFrame:CGRectMake(5, 11, 290, 22)];
        _name.returnKeyType = UIReturnKeyNext;
        _name.placeholder= @"Your name";
        _name.delegate = self;
        _name.autocorrectionType = UITextAutocorrectionTypeNo;
        _name.backgroundColor = [UIColor clearColor];
        _name.clearButtonMode = UITextFieldViewModeWhileEditing;
        
        _email = [[HTAutocompleteTextField alloc] initWithFrame:CGRectMake(5, 11, 290, 22)];
        _email.keyboardType = UIKeyboardTypeEmailAddress;
        _email.returnKeyType = UIReturnKeyNext;
        _email.placeholder = @"Your email address";
        _email.delegate = self;
        _email.backgroundColor = [UIColor clearColor];
        _email.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _email.clearButtonMode = UITextFieldViewModeWhileEditing;
        _email.autocompleteDataSource = [HTAutocompleteManager sharedManager];
        _email.autocompleteType = HTAutocompleteTypeEmail;
        _email.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _email.autocompleteDisabled = NO;
        _email.autocorrectionType = UITextAutocorrectionTypeNo;
        
        _url = [[UITextField alloc] initWithFrame:CGRectMake(5, 11, 290, 22)];
        _url.keyboardType = UIKeyboardTypeURL;
        _url.returnKeyType = UIReturnKeyNext;
        _url.placeholder = @"Your website";
        _url.delegate = self;
        _url.backgroundColor = [UIColor clearColor];
        _url.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _url.text = [defaults objectForKey:@"comment_url"];
        _url.clearButtonMode = UITextFieldViewModeWhileEditing;
        
        _message = [[UITextView alloc] initWithFrame:CGRectMake(0, 5, 300, 122)];
        _message.backgroundColor = [UIColor clearColor];
        _message.font = _email.font;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                          target:self
                                                                                          action:@selector(done)];
    
    UINib *nib = [UINib nibWithNibName: @"KMTextfieldCell"  bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"KMTextfieldCell"];
    
    UINib *nib2 = [UINib nibWithNibName: @"KMTextviewCell"  bundle:nil];
    [self.tableView registerNib:nib2 forCellReuseIdentifier:@"KMTextviewCell"];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancel)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Post"
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                             action:@selector(createPost)];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.name.text = [defaults objectForKey:@"comment_name"];
    self.email.text = [defaults objectForKey:@"comment_email"];
    self.url.text = [defaults objectForKey:@"comment_url"];
    
    if (![self.name.text length])
    {
        [self.name becomeFirstResponder];
    }
    else if (![self.email.text length])
    {
        [self.email becomeFirstResponder];
    }
    else
    {
        [self.message becomeFirstResponder];
    }
    
    [[[GAI sharedInstance] defaultTracker] sendView:@"Post Comment"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [[KMWordPressAPIClient sharedClient] cancelAllHTTPOperationsWithMethod:@"POST" path:@"?json=respond.submit_comment"];
}

- (void)cancel
{
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

- (BOOL)validate
{
    BOOL result = YES;
    NSMutableString *errorMessage = @"".mutableCopy;
    if (![self.name.text length])
    {
        result = NO;
        
        [errorMessage appendString:@"Please enter your name\n"];
    }

    if (![self.email.text length])
    {
        result = NO;
        [errorMessage appendString:@"Please enter an email address\n"];
    }
    
    if (![self.message.text length])
    {
        result = NO;
        [errorMessage appendString:@"Please enter a message"];
    }
    
    if (!result)
    {
        DLog(@"errorMessage: %@", errorMessage);
        
        UILabel *errorLabel = [UILabel new];
        errorLabel.text = errorMessage;
        errorLabel.numberOfLines = 0;
        errorLabel.frame = CGRectMake(10, 10, 300, 22);
        [errorLabel sizeToFit];
        errorLabel.backgroundColor = [UIColor clearColor];
        
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, errorLabel.frame.size.height + 20)];
        
        [header addSubview:errorLabel];
        
        self.tableView.tableHeaderView = header;
    }
    
    return result;
}

- (void)createPost
{
    self.tableView.tableHeaderView = nil;
    
    if (![self validate])
    {
        return;
    }

    [self.name resignFirstResponder];
    [self.email resignFirstResponder];
    [self.url resignFirstResponder];
    [self.message resignFirstResponder];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = NSLocalizedString(@"Posting Comment", nil);
    
    NSMutableDictionary *params = @{@"post_id": self.post.kMWordPressPostId, @"email" : self.email.text, @"name" : self.name.text, @"content" : self.message.text}.mutableCopy;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:self.name.text forKey:@"comment_name"];
    [defaults setObject:self.email.text forKey:@"comment_email"];
    
    if ([self.url.text length])
    {
        [defaults setObject:self.url.text forKey:@"comment_url"];
        params[@"url"] = self.url.text;
    }
    
    if (self.comment)
    {
        params[@"comment_parent"] = self.comment.kMWordPressPostCommentId;
    }
    
    [defaults synchronize];
    
    __block KMCreateCommentViewController *blockSelf = self;
    
    [[KMWordPressAPIClient sharedClient] postPath:@"?json=respond.submit_comment"
                                       parameters:params
                                          success:^(AFHTTPRequestOperation *operation, id JSON) {
                                              
                                              DLog(@"JSON: %@", JSON);
                                              
                                              if (![JSON[@"status"] isEqualToString:@"error"])
                                              {
                                                  KMWordPressPostComment *comment = [KMWordPressPostComment instanceFromDictionary:JSON];
                                                  
                                                  [blockSelf.post addComment:comment];
                                                  
                                                  if (blockSelf.redirectResponse)
                                                  {
                                                      blockSelf.redirectResponse(comment);
                                                  }
                                                  else
                                                  {
                                                      [blockSelf.presentingViewController dismissViewControllerAnimated:YES
                                                                                                             completion:nil];
                                                  }
                                              }
                                              else
                                              {
                                                  [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                  
                                                  [blockSelf showErrorMessage:JSON[@"error"]];
                                              }
                                          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                              DLog(@"error: %@", error);
                                              
                                              [MBProgressHUD hideHUDForView:self.view animated:YES];
                                              
                                              [blockSelf showError:error];
                                              
                                              self.navigationItem.rightBarButtonItem.enabled = YES;
                                          }];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 3)
    {
        KMTextviewCell *cell = (KMTextviewCell *)[tableView dequeueReusableCellWithIdentifier:@"KMTextviewCell"];
        
        cell.inputView = self.message;
        
        return cell;
    }
    
    KMTextfieldCell *cell = (KMTextfieldCell *)[tableView dequeueReusableCellWithIdentifier:@"KMTextfieldCell"];
    
    switch (indexPath.row) {
        case 0:
            cell.inputField = self.name;
            break;
        case 1:
            cell.inputField = self.email;
            break;
        case 2:
            cell.inputField = self.url;
            break;
        default:
            break;
    }
    
    return cell;
}


#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 3)
    {
        return 132.0f;
    }
    
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            [self.name becomeFirstResponder];
            break;
        case 1:
            [self.email becomeFirstResponder];
            break;
        case 2:
            [self.url becomeFirstResponder];
        case 3:
            [self.message becomeFirstResponder];
        default:
            break;
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.name)
    {
        [self.email becomeFirstResponder];
        return NO;
    }
    else if (textField == self.email)
    {
        [self.url becomeFirstResponder];
    }
    else if (textField == self.url)
    {
        [self.message becomeFirstResponder];
    }
    
    return YES;
}
@end
