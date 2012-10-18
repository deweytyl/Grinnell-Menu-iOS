//
//  Settings.m
//  Grinnell-Menu-iOS
//
//  Created by Colin Tremblay on 10/22/11.
//  Copyright 2011 __GrinnellAppDev__. All rights reserved.
//

#import "SettingsViewController.h"
#import "VenueViewController.h"
#import "Grinnell_Menu_iOSAppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@implementation SettingsViewController{
    Grinnell_Menu_iOSAppDelegate *mainDelegate;
}

@synthesize gotIdeasTextLabel, tipsTextView, tipsLabel, banner, contactButton, filtersNameArray, veganSwitch, ovoSwitch, gfSwitch, passSwitch;

//Do some initialization of our own
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        mainDelegate = (Grinnell_Menu_iOSAppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return self;
}
/*
- (void)viewWillLayoutSubviews
{
    if (UIInterfaceOrientationIsPortrait(
                                         [UIApplication sharedApplication].statusBarOrientation))
    {
        gotIdeasTextLabel.hidden = NO;
        tipsTextView.hidden = NO;
        tipsLabel.hidden = NO;
        contactButton.hidden = NO;
        banner.hidden = NO;
    }
    else
    {
        gotIdeasTextLabel.hidden = YES;
        tipsTextView.hidden = YES;
        tipsLabel.hidden = YES;
        contactButton.hidden = YES;
        if (mainDelegate.passover)
            banner.hidden = YES;
    }
}*/
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)settingsDelegateDidFinish:(SettingsViewController *)controller {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section {
    if (mainDelegate.passover){
        passSwitch.hidden = false;
        return 4;
    }
    else{
        passSwitch.hidden = true;
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.textLabel.text = [filtersNameArray objectAtIndex:indexPath.row];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Filters";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @"";
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(settingsDelegateDidFinish:)];
    [[self navigationItem] setLeftBarButtonItem:backButton];
    [super viewDidLoad];
    self.title = @"Settings"; 
    
    //filtersNameArray contains the names of all the filters. If you want to add more filters, You can add the name to this array. Change the number of rows to be returned. And then drag in a switch into the nib file for that particular filter.
    if (mainDelegate.passover)
        filtersNameArray = [NSArray arrayWithObjects:@"Vegan Filter", @"Ovolacto Filter", @"Gluten Free Filter", @"Passover Filter", nil];
    else
        filtersNameArray = [NSArray arrayWithObjects:@"Vegan Filter", @"Ovolacto Filter", @"Gluten Free Filter", nil];
    
    //We set the switches to thier default values
    [veganSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"VeganSwitchValue"]];
    [ovoSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"OvoSwitchValue"]];
    [gfSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"GFSwitchValue"]];
    [passSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"PassSwitchValue"]];
    
    ///For iPad view. Modify value to set the appropriate width and height for the content size.
    self.contentSizeForViewInPopover = CGSizeMake(280.0, 400.0);
}

-(void)viewWillAppear:(BOOL)animated {
    //Customise tips Label
    tipsLabel.textColor = [UIColor colorWithRed:0.298 green:0.337 blue:0.424 alpha:1.0];
    gotIdeasTextLabel.textColor = [UIColor colorWithRed:0.298 green:0.337 blue:0.424 alpha:1.0];
    [tipsTextView setBackgroundColor:[UIColor whiteColor]];
    //[tipsTextView setFont:[UIFont boldSystemFontOfSize:16.0]];
    [tipsTextView setTextAlignment:UITextAlignmentLeft];
    [tipsTextView setEditable:NO];
    // For the border and rounded corners
    [[tipsTextView layer] setBorderColor:[[UIColor whiteColor] CGColor]];
    [[tipsTextView layer] setBorderWidth:2.3];
    [[tipsTextView layer] setCornerRadius:15];
    [tipsTextView setClipsToBounds: YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    //When user clicks done, the default values of the filters are set to the values of the switches
    [[NSUserDefaults standardUserDefaults] setBool:veganSwitch.isOn forKey:@"VeganSwitchValue"];
    [[NSUserDefaults standardUserDefaults] setBool:ovoSwitch.isOn forKey:@"OvoSwitchValue"];
    [[NSUserDefaults standardUserDefaults] setBool:gfSwitch.isOn forKey:@"GFSwitchValue"];
    [[NSUserDefaults standardUserDefaults] setBool:passSwitch.isOn forKey:@"PassSwitchValue"];
    [mainDelegate.venueViewController loadNextMenu];
    [super viewWillDisappear:YES];
}

- (void)viewDidUnload {
    [self setTipsTextView:nil];
    [self setTipsLabel:nil];
    [self setGotIdeasTextLabel:nil];
    [super viewDidUnload];
}

#pragma mark - Added methods
- (IBAction)contactUs:(id)sender {
    // From within your active view controller
    if([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        
        [mailViewController setSubject:@"Feedback - Glicious!"];
        [mailViewController setToRecipients:[NSArray arrayWithObject:@"appdev@grinnell.edu"]];
        
        [self presentModalViewController:mailViewController animated:YES];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissModalViewControllerAnimated:YES];
}

@end
