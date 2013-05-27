//
//  KMSubmitTipViewController.m
//  KMWordPress
//
//  Created by Karl Monaghan on 02/12/2012.
//  Copyright (c) 2012 Crayons and Brown Paper. All rights reserved.
//
#import "MBProgressHUD.h"
#import "HTAutocompleteTextField.h"
#import "HTAutocompleteManager.h"
#import "GTMUIImage+Resize.h"
#import "BButton.h"

#import "AFHTTPRequestOperation.h"

#import "KMSubmitTipViewController.h"

#import "KMTextfieldCell.h"
#import "KMTextviewCell.h"

@interface KMSubmitTipViewController ()
@property (strong, nonatomic) UITextField *name;
@property (strong, nonatomic) HTAutocompleteTextField *email;
@property (strong, nonatomic) UITextView *message;

@property (strong, nonatomic) UIImagePickerController *picker;
@property (strong, nonatomic) UIImage *attachment;
@property (strong, nonatomic) UIImageView *attachmentView;

@property (assign, nonatomic) BOOL askAboutAttachment;
@end

@implementation KMSubmitTipViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _name = [[UITextField alloc] initWithFrame:CGRectMake(5, 11, 290, 30)];
        _name.returnKeyType = UIReturnKeyNext;
        _name.placeholder= @"Your name";
        _name.autocorrectionType = UITextAutocorrectionTypeNo;
        _name.clearButtonMode = UITextFieldViewModeWhileEditing;
        _name.delegate = self;
        
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
        
        _message = [[UITextView alloc] initWithFrame:CGRectMake(0,5,300,122)];
        _message.backgroundColor = [UIColor clearColor];
        _message.font = _email.font;
        
        _picker = [[UIImagePickerController alloc] init];
        _picker.delegate = self;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.name.text = [defaults objectForKey:@"comment_name"];
    self.email.text = [defaults objectForKey:@"comment_email"];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                          target:self
                                                                                          action:@selector(done)];
    
    UINib *nib = [UINib nibWithNibName: @"KMTextfieldCell"  bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"KMTextfieldCell"];

    UINib *nib2 = [UINib nibWithNibName: @"KMTextviewCell"  bundle:nil];
    [self.tableView registerNib:nib2 forCellReuseIdentifier:@"KMTextviewCell"];
    
    [self makeFooter];
    
    [[[GAI sharedInstance] defaultTracker] sendView:@"Submit Tip"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[KMWordPressAPIClient sharedClient] cancelAllHTTPOperationsWithMethod:@"POST" path:@"/iphone_tip.php"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)done
{
    [[self parentViewController] dismissViewControllerAnimated:YES completion:nil];
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
        UILabel *errorLabel = [UILabel new];
        errorLabel.text = errorMessage;
        errorLabel.numberOfLines = 0;
        errorLabel.frame = CGRectMake(10, 10, 300, 22);
        [errorLabel sizeToFit];
        errorLabel.backgroundColor = [UIColor clearColor];
        
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, errorLabel.frame.size.height + 20)];
        
        [header addSubview:errorLabel];
        
        self.tableView.tableHeaderView = header;
        
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    return result;
}

- (void)submit
{
    self.tableView.tableHeaderView = nil;
    
    if (![self validate])
    {
        return;
    }
    
    if (!self.askAboutAttachment && !self.attachment)
    {
        [[[UIAlertView alloc] initWithTitle:@"No Photo?"
                                    message:@"You've not attached a photo and we love pictures. Are you sure you want to submit without one?"
                                   delegate:self
                          cancelButtonTitle:@"Send Tip"
                          otherButtonTitles:@"Attach Photo", nil] show];
        
        self.askAboutAttachment = YES;
        
        return;
    }
    
    [self.view endEditing:YES];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = NSLocalizedString(@"Sending Tip", nil);
    hud.yOffset = (self.view.$y / 2) - (hud.$y / 2);
    DLog(@"hud: %@", hud);
    
    NSMutableURLRequest *afRequest = [[KMWordPressAPIClient sharedClient] multipartFormRequestWithMethod:@"POST"
                                                                                                    path:@"/iphone_tip.php"
                                                                                              parameters:@{@"name" : self.name.text, @"email" : self.email.text, @"message" : self.message.text}
                                                                               constructingBodyWithBlock:^(id <AFMultipartFormData>formData)
                                      {
                                          if (self.attachment)
                                          {
                                              [formData appendPartWithFileData:UIImagePNGRepresentation(self.attachment)
                                                                          name:@"image"
                                                                      fileName:@"tip.png"
                                                                      mimeType:@"image/png"];
                                          }
                                      }
                                      ];
    
    __block KMSubmitTipViewController *blockSelf = self;
    
    AFHTTPRequestOperation *operation = [[KMWordPressAPIClient sharedClient] HTTPRequestOperationWithRequest:afRequest
                                                                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                                     
                                                                     MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
                                                                     [self.view addSubview:HUD];
                                                                     
                                                                     HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"321-like.png"]];
                                                                     
                                                                     // Set custom view mode
                                                                     HUD.mode = MBProgressHUDModeCustomView;
                                                                     
                                                                     HUD.labelText = NSLocalizedString(@"Thanks!", nil);
                                                                     
                                                                     [HUD show:YES];
                                                                     [HUD hide:YES afterDelay:1];
                                                                     
                                                                     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                                                     
                                                                     [defaults setObject:self.name.text forKey:@"comment_name"];
                                                                     [defaults setObject:self.email.text forKey:@"comment_email"];

                                                                     [defaults synchronize];
                                                                     
                                                                     [blockSelf reset];
                                                                 }
                                                                          failure:^(AFHTTPRequestOperation *operation, NSError *error){
                                                                              DLog(@"%@", error);
                                                                              
                                                                              [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                                              
                                                                              [blockSelf showError:error];
                                                                     
                                                                 }];
    
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        
        DLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
        
    }];
    
    [operation start];
}

- (void)makeFooter
{
    self.tableView.tableFooterView = nil;
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
    footer.backgroundColor = [UIColor clearColor];
    
    CGFloat offset = 10.0f;
    
    if (self.attachment)
    {
        BButton *retakePhoto = [[BButton alloc] initWithFrame:CGRectMake(10, 28, 80, 44)];
        
        [retakePhoto setTitle:@"Retake" forState:UIControlStateNormal];
        [retakePhoto addTarget:self
                     action:@selector(addPhoto)
           forControlEvents:UIControlEventTouchUpInside];
        [retakePhoto setType:BButtonTypeDefault];
        
        [footer addSubview:retakePhoto];
        
        if (self.attachmentView == nil)
        {
            self.attachmentView = [[UIImageView alloc] initWithFrame:CGRectMake(110.0f, 0.0f, 100.0f, 100.0f)];
        }
        
        self.attachmentView.image = self.attachment;
        
        offset = 55.0f;
        
        [footer addSubview:self.attachmentView];
        
        BButton *removePhoto = [[BButton alloc] initWithFrame:CGRectMake(230.0f, 28.0f, 80.0f, 44.0f)];
        
        [removePhoto setTitle:@"Remove" forState:UIControlStateNormal];
        [removePhoto addTarget:self
                     action:@selector(removePhoto)
           forControlEvents:UIControlEventTouchUpInside];
        [removePhoto setType:BButtonTypeDanger];
        
        [footer addSubview:removePhoto];
         
    }
    else
    {
        BButton *addPhoto = [[BButton alloc] initWithFrame:CGRectMake(10, 3, 300, 44)];
        
        [addPhoto setTitle:@"Add Photo" forState:UIControlStateNormal];
        [addPhoto addTarget:self
                     action:@selector(addPhoto)
           forControlEvents:UIControlEventTouchUpInside];
        [addPhoto setType:BButtonTypeDefault];
        
        [footer addSubview:addPhoto];
    }
    
    BButton *submit = [[BButton alloc] initWithFrame:CGRectMake(10.0f, 50.0f + offset, 300.0f, 44.0f)];
    
    [submit setTitle:@"Submit Tip" forState:UIControlStateNormal];
    [submit addTarget:self
               action:@selector(submit)
     forControlEvents:UIControlEventTouchUpInside];
    [submit setType:BButtonTypePrimary];
    
    [footer addSubview:submit];
    
    footer.frame = CGRectMake(0, 0, 320.0f, 100.0f + offset);
    
    self.tableView.tableFooterView = footer;
}

- (void)addPhoto
{
    [self.view endEditing:YES];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [actionSheet addButtonWithTitle:@"Take Photo"];
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        [actionSheet addButtonWithTitle:@"From Photo Library"];
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        [actionSheet addButtonWithTitle:@"From Album"];
    }
    
    [actionSheet addButtonWithTitle:@"Cancel"];
    
    actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
    
    [actionSheet showInView:self.view];
}

- (void)removePhoto
{
    self.attachment = nil;
    self.attachmentView = nil;
    
    [self makeFooter];
}

- (void)displayPicker:(UIImagePickerControllerSourceType)source
{
    self.picker.sourceType = source;
    
    [self presentModalViewController:self.picker animated:YES];
}

- (void)reset
{
    //self.name.text = nil;
    //self.email.text = nil;
    self.message.text = nil;
    self.attachment = nil;
    
    self.askAboutAttachment = NO;
    
    [self makeFooter];
}

#pragma mark - UIImagePickerControllerDelegate
- (void) imagePickerControllerDidCancel:(UIImagePickerController *) picker
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void) imagePickerController: (UIImagePickerController *) picker didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    self.attachment = [[info objectForKey:UIImagePickerControllerOriginalImage] gtm_imageByResizingToSize:CGSizeMake(800.0f, 800.0f)
                                                                                      preserveAspectRatio:YES
                                                                                                trimToFit:NO];
    [self dismissModalViewControllerAnimated:YES];
    
    [self makeFooter];
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
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2)
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
        default:
            break;
    }
    return cell;
}


#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2)
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
            [self.message becomeFirstResponder];
        default:
            break;
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    UIImagePickerControllerSourceType source;
    
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Take Photo"])
    {
        source = UIImagePickerControllerSourceTypeCamera;
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"From Photo Library"])
    {
        source = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"From Album"])
    {
        source = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }
    else
    {
        return;
        
    }
    
    [self displayPicker:(UIImagePickerControllerSourceType)source];
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
        [self.message becomeFirstResponder];
    }
    
    return YES;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.cancelButtonIndex == buttonIndex)
    {
        [self submit];
    }
    else
    {
        [self addPhoto];
    }
}
@end
