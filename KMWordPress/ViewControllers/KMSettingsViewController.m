//
//  KMSettingsViewController.m
//  KMWordPress
//
//  Created by Karl Monaghan on 13/02/2013.
//  Copyright (c) 2013 Crayons and Brown Paper. All rights reserved.
//

#import "HTAutocompleteTextField.h"
#import "HTAutocompleteManager.h"
#import "BButton.h"

#import "KMSettingsViewController.h"

#import "KMTextfieldCell.h"
#import "KMSwitchCell.h"
#import "KMSliderCell.h"

@interface KMSettingsViewController ()
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (strong, nonatomic) UITextField *name;
@property (strong, nonatomic) HTAutocompleteTextField *email;
@property (strong, nonatomic) UITextField *url;
@property (strong, nonatomic) IBOutlet BButton *saveButton;

- (IBAction)saveAction:(id)sender;

@end

@implementation KMSettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Settings";
    
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.tableView.tableFooterView = self.footerView;
    
    UINib *nib = [UINib nibWithNibName: @"KMTextfieldCell"  bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"KMTextfieldCell"];
    
    UINib *nib2 = [UINib nibWithNibName: @"KMSliderCell"  bundle:nil];
    [self.tableView registerNib:nib2 forCellReuseIdentifier:@"KMSliderCell"];

    UINib *nib3 = [UINib nibWithNibName: @"KMSwitchCell"  bundle:nil];
    [self.tableView registerNib:nib3 forCellReuseIdentifier:@"KMSwitchCell"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.name = [[UITextField alloc] initWithFrame:CGRectMake(5, 11, 290, 22)];
    self.name.returnKeyType = UIReturnKeyNext;
    self.name.placeholder= @"Your name";
    self.name.delegate = self;
    self.name.autocorrectionType = UITextAutocorrectionTypeNo;
    self.name.backgroundColor = [UIColor clearColor];
    self.name.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    self.email = [[HTAutocompleteTextField alloc] initWithFrame:CGRectMake(5, 11, 290, 22)];
    self.email.keyboardType = UIKeyboardTypeEmailAddress;
    self.email.returnKeyType = UIReturnKeyNext;
    self.email.placeholder = @"Your email address";
    self.email.delegate = self;
    self.email.backgroundColor = [UIColor clearColor];
    self.email.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.email.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.email.autocompleteDataSource = [HTAutocompleteManager sharedManager];
    self.email.autocompleteType = HTAutocompleteTypeEmail;
    self.email.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.email.autocompleteDisabled = NO;
    
    self.url = [[UITextField alloc] initWithFrame:CGRectMake(5, 11, 290, 22)];
    self.url.keyboardType = UIKeyboardTypeURL;
    self.url.returnKeyType = UIReturnKeyNext;
    self.url.placeholder = @"Your website";
    self.url.delegate = self;
    self.url.backgroundColor = [UIColor clearColor];
    self.url.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.url.text = [defaults objectForKey:@"comment_url"];
    self.url.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    self.name.text = [defaults objectForKey:@"comment_name"];
    self.email.text = [defaults objectForKey:@"comment_email"];
    self.url.text = [defaults objectForKey:@"comment_url"];
    
    [self.saveButton setType:BButtonTypePrimary];
    
    [[[GAI sharedInstance] defaultTracker] sendView:@"Settings"];
}

- (void)viewDidUnload
{
    [self setFooterView:nil];
    [self setSaveButton:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveAction:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    KMSwitchCell *cell = (KMSwitchCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0 ]];
    [defaults setBool:!cell.itemSwitch.on forKey:@"helpShown"];
    [defaults setBool:!cell.itemSwitch.on forKey:@"fullscreenHelpShown"];
    
    if ([self.name.text length])
    {
        [defaults setObject:self.name.text forKey:@"comment_name"];
    }
    
    if ([self.email.text length])
    {
        [defaults setObject:self.email.text forKey:@"comment_email"];
    }
    
    if ([self.url.text length])
    {
        [defaults setObject:self.url.text forKey:@"comment_url"];
    }
    
    KMSliderCell *sliderCell = (KMSliderCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2 ]];
    [defaults setFloat:sliderCell.slider.value forKey:@"fontsize"];
    
    [defaults synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sliderChanged:(UISlider *)slider
{
    
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 3;
            break;
        case 2:
            return 1;
            break;
        default:
            break;
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Help";
            break;
        case 1:
            return @"Comment details";
            break;
        case 2:
            return @"Text Size";
            break;
        default:
            break;
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        KMSwitchCell *cell = (KMSwitchCell *)[tableView dequeueReusableCellWithIdentifier:@"KMSwitchCell"];

        cell.switchLabel.text = @"Show help";
        cell.itemSwitch.on = ![[NSUserDefaults standardUserDefaults] boolForKey:@"helpShown"];
        return cell;
    }
    else if (indexPath.section == 1)
    {
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
    else if (indexPath.section == 2)
    {
        KMSliderCell *cell = (KMSliderCell *)[tableView dequeueReusableCellWithIdentifier:@"KMSliderCell"];

        cell.slider.value = [[NSUserDefaults standardUserDefaults] floatForKey:@"fontsize"];
        
        [cell.slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
        return cell;
    }
    
    return nil;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 1:
            switch (indexPath.row) {
                case 0:
                    [self.name becomeFirstResponder];
                    break;
                case 1:
                    [self.email becomeFirstResponder];
                    break;
                case 2:
                    [self.url becomeFirstResponder];
                    break;
                default:
                    break;
            }
            break;
            
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
    
    return YES;
}

@end
