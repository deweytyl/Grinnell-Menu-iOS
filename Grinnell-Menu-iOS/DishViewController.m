//
//  DishView.m
//  Grinnell-Menu-iOS
//
//  Created by Colin Tremblay on 10/22/11.
//  Copyright 2011 __GrinnellAppDev__. All rights reserved.
//

#import "DishViewController.h"
#import "Grinnell_Menu_iOSAppDelegate.h"
#import "Dish.h"
#import "Venue.h"
#import <QuartzCore/QuartzCore.h>
#import "TDBadgedCell.h"

@implementation DishViewController
{
    UIColor *EvenbadgeColor;
    UIColor *OddbadgeColor;
}
@synthesize theTableView, backgroundImageView, selectedDish;

- (IBAction)toVenueView:(id)sender {
    [self.navigationController popToViewController: [self.navigationController.viewControllers objectAtIndex:1] animated:YES]; 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
- (void)viewWillAppear:(BOOL)animated {
    self.title = selectedDish.name;
    [super viewWillAppear:animated];
//    self.backgroundImageView.layer.shadowColor = [UIColor blackColor].CGColor;
//    self.backgroundImageView.layer.shadowOffset = CGSizeMake(0, 1);
//    self.backgroundImageView.layer.shadowOpacity = 1;
//    self.backgroundImageView.layer.shadowRadius = 1;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    OddbadgeColor = [UIColor colorWithRed:0.192 green:0.512 blue:0.792 alpha:1.0];
    EvenbadgeColor = [UIColor colorWithRed:0.192 green:0.432 blue:0.792 alpha:1];
    OddbadgeColor = [UIColor blackColor];
}

- (void)viewDidUnload {
    [self setBackgroundImageView:nil];
    [self setTheTableView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    //I wanted the padding so it centered... so i put a tab =] Feel free to do this better... DrJid
   return @"     Nutritional Information";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    // NSString *formattedSectionTitle = [sectionTitle capitalizedString];
    if (sectionTitle == nil) {
        return nil;
    }
    // Create label with section title
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(20, 6, 300, 30);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    // label.font = [UIFont fontWithName:@"Vivaldi" size:32];
    label.font = [UIFont boldSystemFontOfSize:20];
    //[UIFont fontWithName:@"Vivaldi" size:38]
    
    label.text = sectionTitle;
    
    // Create header view and add label as a subview
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    [view addSubview:label];
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section {
    return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";    
    TDBadgedCell *cell = [[TDBadgedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Calories";
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        cell.badge.radius = 9;
//        cell.badgeString = [NSString stringWithFormat:@"%@", [selectedDish.nutrition objectForKey:@"KCAL"]];
        cell.badgeString = [NSString stringWithFormat:@"%.3f", [[selectedDish.nutrition objectForKey:@"KCAL"] floatValue]];

    }
    else if (indexPath.row == 1) {
        cell.textLabel.text = @"Saturated Fat"; 
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        cell.badgeString = [NSString stringWithFormat:@"%.3fg", [[selectedDish.nutrition objectForKey:@"SFA"] floatValue]];
        cell.badge.radius = 9;
        
    }
    else if (indexPath.row == 2) {
        cell.textLabel.text = @"Trans Fat";
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
//        cell.badgeString = [NSString stringWithFormat:@"%@g", [selectedDish.nutrition objectForKey:@"FATRN"]];
        cell.badgeString = [NSString stringWithFormat:@"%.1fg", [[selectedDish.nutrition objectForKey:@"FATRN"] floatValue]];

        cell.badge.radius = 9;
    }
    else if (indexPath.row == 3) {
        cell.textLabel.text = @"Sodium";
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
//        cell.badgeString = [NSString stringWithFormat:@"%@mg", [selectedDish.nutrition objectForKey:@"NA"]];
        cell.badgeString = [NSString stringWithFormat:@"%.3fmg", [[selectedDish.nutrition objectForKey:@"NA"] floatValue]];

        cell.badge.radius = 9;
    }
    else if (indexPath.row == 4) {
        cell.textLabel.text = @"Sugar";
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
//        cell.badgeString = [NSString stringWithFormat:@"%@g", [selectedDish.nutrition objectForKey:@"SUGR"]];
        cell.badgeString = [NSString stringWithFormat:@"%.3fg", [[selectedDish.nutrition objectForKey:@"SUGR"] floatValue]];

        cell.badge.radius = 9;
    }
    else if (indexPath.row == 5) {
        cell.textLabel.text = @"Dietary Fiber";
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
//        cell.badgeString = [NSString stringWithFormat:@"%@g", [selectedDish.nutrition objectForKey:@"TDFB"]];
        cell.badgeString = [NSString stringWithFormat:@"%.1fg", [[selectedDish.nutrition objectForKey:@"TDFB"] floatValue]];

        cell.badge.radius = 9;
    }
    else if (indexPath.row == 6) {
        cell.textLabel.text = @"Cholesterol";
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
//        cell.badgeString = [NSString stringWithFormat:@"%@mg", [selectedDish.nutrition objectForKey:@"CHOL"]];
        cell.badgeString = [NSString stringWithFormat:@"%.3fmg", [[selectedDish.nutrition objectForKey:@"CHOL"] floatValue]];

        cell.badge.radius = 9;
    }
    else if (indexPath.row == 7) {
        cell.textLabel.text = @"Protein";
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
//        cell.badgeString = [NSString stringWithFormat:@"%@g", [selectedDish.nutrition objectForKey:@"PRO"]];
        cell.badgeString = [NSString stringWithFormat:@"%.3fg", [[selectedDish.nutrition objectForKey:@"PRO"] floatValue]];

        cell.badge.radius = 9;
    }
    if (indexPath.row % 2) {
        [cell setBackgroundColor:[UIColor colorWithRed:0.93 green:0.9 blue:0.9 alpha:1]];
        cell.badgeColor = EvenbadgeColor;
    }
    else {
        [cell setBackgroundColor:[UIColor underPageBackgroundColor]];
        cell.badgeColor = OddbadgeColor;
    }
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Disable selection on rows. 
    return nil;
}

@end
