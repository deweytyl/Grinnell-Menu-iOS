//
//  MenuModel.m
//  G-licious
//
//  Created by Maijid Moujaled on 11/2/13.
//  Copyright (c) 2013 Maijid Moujaled. All rights reserved.
//

#import "MenuModel.h"
#import "Dish.h"
#import "Station.h"
#import "Meal.h"
#import <Reachability.h>

@interface MenuModel()

@property(nonatomic, strong) NSDictionary *menuDictionary;
@property(nonatomic, strong) NSArray *originalMenu;
@property (nonatomic, assign) BOOL hasAvailableDays;

- (NSArray *)createMenuFromDictionary:(NSDictionary *)theMenuDictionary;

@end


@implementation MenuModel
{
    Reachability *internetReachable;
}

- (id)initWithDate:(NSDate *)aDate
{
    self = [super init];
    if  (self) {
        //initialize
        self.date = aDate;
        
    }
    return self;
}



- (void)performFetchWithCompletionBlock:(FetchCompletionBlock)completion
{
    
    //Get the date Components. TODO pull this out.
    [self getAvailableDays];
    
    
    //We need to pick the right components in the cases self.date changes.
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:self.date];
    int selectedDay = [components day];
    int selectedMonth = [components month];
    int selectedYear = [components year];
    
    //File Directories used.
    NSString *tempPath = NSTemporaryDirectory();
    NSString *daymenuplist = [NSString stringWithFormat:@"%d-%d-%d.plist", selectedMonth, selectedDay, selectedYear];
    NSString *path = [tempPath stringByAppendingPathComponent:daymenuplist];
    
    //If file has been previously cached, use cached copy.
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        self.menuDictionary = [[NSDictionary alloc] initWithContentsOfFile:path];
        NSArray *originalMenu = [self createMenuFromDictionary:self.menuDictionary];
        NSArray *filteredMenu = [self applyFiltersTo:originalMenu];
        
        //return filteredMenu;
        completion(filteredMenu, nil);
        DLog(@"Loading Json from iPhone cache");
    } else {
        DLog(@"Downloading new data");
        NSString *urlString = [NSMutableString stringWithFormat:@"http://tcdb.grinnell.edu/apps/glicious/%d-%d-%d.json", selectedMonth, selectedDay, selectedYear];
        
        // NSString *urlString = [NSString stringWithFormat:@"http://tcdb.grinnell.edu/apps/glicious/11-2-2013.json"];
        
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            //Check the response to see if we got a 200.
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if  (httpResponse.statusCode == 200) {
                //We have some data.
                
                NSError *jsonError;
                self.menuDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                      options:NSJSONReadingAllowFragments
                                                                        error:&jsonError];
                
                
                if (jsonError) {
                    DLog(@"Error converting to json")
                } else {
                    [self.menuDictionary writeToFile:path atomically:YES];
                }
                
                /*//Parses it.
                 NSAssert(self.menuDictionary, nil);
                 
                 NSArray *originalMenu = [self createMenuFromDictionary:self.menuDictionary];
                 NSArray *filteredMenu = [self applyFiltersTo:originalMenu];
                 return filteredMenu;
                 
                 */
                NSArray *originalMenu = [self createMenuFromDictionary:self.menuDictionary];
                NSArray *filteredMenu = [self applyFiltersTo:originalMenu];
                
                
                DLog(@"Final filteredMenu: %@" , filteredMenu);
                //Might need to dispatch_async to make sure that thigns are executed on the main queue.
                //return filteredMenu;
                completion(filteredMenu, nil);
                
            } else {
                
                NSString *body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                DLog(@"Recieved HTTP: %ld: %@", (long)httpResponse.statusCode, body);
                completion(nil, error);
                //Show error Alert
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
                });
            }
        }];
        
        [task resume];
    }
}



/* Fetches the menu for the date: self.date
 * Loads cached menu if available.
 * If not, downloads new menu from TCDB and caches it.
 * Returns the filtered Menu
 */

- (NSArray *)performFetch {
    
    [self getAvailableDays];
    [self setCurrentPage];
    
    //We need to pick the right components in the cases self.date changes.
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:self.date];
    int selectedDay = [components day];
    int selectedMonth = [components month];
    int selectedYear = [components year];
    
    //File Directories used.
    NSString *tempPath = NSTemporaryDirectory();
    NSString *daymenuplist = [NSString stringWithFormat:@"%d-%d-%d.plist", selectedMonth, selectedDay, selectedYear];
    NSString *path = [tempPath stringByAppendingPathComponent:daymenuplist];
    
    //Check to see if the file has previously been cached else Get it from server.
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        self.menuDictionary = [[NSDictionary alloc] initWithContentsOfFile:path];
        NSLog(@"Loading Json from iPhone cache");
    } else if ([self networkCheck]) {
        //correct version
        NSMutableString *url = [NSMutableString stringWithFormat:@"http://tcdb.grinnell.edu/apps/glicious/%d-%d-%d.json", selectedMonth, selectedDay, selectedYear];
        
        
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        NSError *error = nil;
        if (data)
        {
            self.menuDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                  options:kNilOptions
                                                                    error:&error];
            NSLog(@"Downloaded new data");
            if (error) {
                NSLog(@"There was an error: %@", [error localizedDescription]);
            }
            // Cache the menudictionary after downloading.
            [self.menuDictionary writeToFile:path atomically:YES];
        } else {
            //TODO Handle Data Nil Error!!
            
            
        }

        //return [self performFetchHelper];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Yikes!" message:@"It appears that the internet connection is offline" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
        return nil;
    }
    
    NSArray *originalMenu = [self createMenuFromDictionary:self.menuDictionary];
    NSArray *filteredMenu = [self applyFiltersTo:originalMenu];
    return filteredMenu;

}

- (NSArray *)performFetchHelper
{
    [self getAvailableDays];
    [self setCurrentPage];
    
    
    if (self.availableDays < 0 ) {
        //There are no menus on the server.
        //TODO handle this event appropriately.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh-oh!" message:@"Looks like there are no menus available. Check back when later perhaps?" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
    }
    
    
    //Get the date Components. TODO pull this out.
    
    //We need to pick the right components in the cases self.date changes.
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:self.date];
    int selectedDay = [components day];
    int selectedMonth = [components month];
    int selectedYear = [components year];
    
    //File Directories used.
    NSString *tempPath = NSTemporaryDirectory();
    NSString *daymenuplist = [NSString stringWithFormat:@"%d-%d-%d.plist", selectedMonth, selectedDay, selectedYear];
    NSString *path = [tempPath stringByAppendingPathComponent:daymenuplist];
    
    //Check to see if the file has previously been cached else Get it from server.
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        self.menuDictionary = [[NSDictionary alloc] initWithContentsOfFile:path];
        NSLog(@"Loading Json from iPhone cache");
    }  else {
        //correct version
        NSMutableString *url = [NSMutableString stringWithFormat:@"http://tcdb.grinnell.edu/apps/glicious/%d-%d-%d.json", selectedMonth, selectedDay, selectedYear];
        
        
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        NSError *error = nil;
        if (data)
        {
            self.menuDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                  options:kNilOptions
                                                                    error:&error];
            NSLog(@"Downloaded new data");
            if (error) {
                NSLog(@"There was an error: %@", [error localizedDescription]);
            }
            // Cache the menudictionary after downloading.
            [self.menuDictionary writeToFile:path atomically:YES];
        } else {
            //TODO Handle Data Nil Error!!
            
            
        }
    }
    
    //Parses it.
    //  NSAssert(self.menuDictionary, nil);
    
    
    NSArray *originalMenu = [self createMenuFromDictionary:self.menuDictionary];
    NSArray *filteredMenu = [self applyFiltersTo:originalMenu];
    return filteredMenu;
}


/*
 - (NSArray *)parseMenu:(NSData *)data {
 NSError *jsonError;
 self.menuDictionary = [NSJSONSerialization JSONObjectWithData:data
 options:NSJSONReadingAllowFragments
 error:&jsonError];
 
 if (!jsonError) {
 //Set the array to the response.
 DLog(@"response results: %@", self.menuDictionary);
 } else {
 DLog(@"Error: %@", [jsonError localizedDescription] );
 }
 
 //Parses it.
 NSAssert(self.menuDictionary, nil);
 
 NSArray *originalMenu = [self createMenuFromDictionary:self.menuDictionary];
 NSArray *filteredMenu = [self applyFiltersTo:originalMenu];
 return filteredMenu;
 }
 */


/* Creates and returns the array of meals.
 * Requires the menuDictionary downloaded from the server.
 */
-(NSArray *)createMenuFromDictionary:(NSDictionary *)theMenuDictionary
{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    //Go through Menu Dictionary and create a meal for each Meal available.
    [theMenuDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *mealName, NSDictionary *mealDict, BOOL *stop) {
        NSLog(@"Mealname: %@, mealDict:", mealName);
        
        if (![mealName isEqualToString:@"PASSOVER"]) {
            //next step - create the Meal(i.e Breakfast, Lunch, etc)
            Meal *aMeal = [[Meal alloc] initWithMealDict:mealDict andName:mealName];
            [tempArray addObject:aMeal];
        }
    }];
    
    //This sortDescriptor helps us to assure the Breakfast-Lunch-Dinner-Outtakes ordering.
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"scoreForSorting" ascending:YES];
    [tempArray sortUsingDescriptors:@[sortDescriptor]];
    
    self.originalMenu = [[NSArray alloc] initWithArray:tempArray];
    return self.originalMenu;
}

//Returns a filtered Menu depending on the values of the Filter Switches.
-(NSArray *)applyFiltersTo:(NSArray *)originalMenu
{
    
    NSMutableArray *filteredMenu = [[NSMutableArray alloc] init];
    
    //Load Switch values
    BOOL ovoSwitchValue, veganSwitchValue, gfSwitchValue, passSwitchValue;
    veganSwitchValue = [[NSUserDefaults standardUserDefaults] boolForKey:@"VeganSwitchValue"];
    ovoSwitchValue = [[NSUserDefaults standardUserDefaults] boolForKey:@"OvoSwitchValue"];
    gfSwitchValue = [[NSUserDefaults standardUserDefaults] boolForKey:@"GFSwitchValue"];
    passSwitchValue = [[NSUserDefaults standardUserDefaults] boolForKey:@"PassSwitchValue"];
    
    
    NSPredicate *passPred = [NSPredicate predicateWithFormat:@"passover == YES"];
    NSPredicate *ovoPred = [NSPredicate predicateWithFormat:@"ovolacto == YES"];
    NSPredicate *veganPred = [NSPredicate predicateWithFormat:@"vegan == YES"];
    NSPredicate *gfPred = [NSPredicate predicateWithFormat:@"glutenFree == YES"];
    
    NSMutableArray *predicates = [[NSMutableArray alloc] init];
    
    if (ovoSwitchValue) [predicates addObject:ovoPred];
    if (veganSwitchValue) [predicates addObject:veganPred];
    if (gfSwitchValue) [predicates addObject:gfPred];
    if (passSwitchValue) [predicates addObject:passPred];
    
    [originalMenu enumerateObjectsUsingBlock:^(Meal *meal, NSUInteger idx, BOOL *stop) {
        NSMutableArray *originalMealStations = [[NSMutableArray alloc] initWithArray:meal.stations];
        
        //Create Favorite's Station and set it up TODO
        NSMutableArray *filteredStations = [[NSMutableArray alloc] init];
        
        [originalMealStations enumerateObjectsUsingBlock:^(Station *aStation, NSUInteger idx, BOOL *stop) {
            Station *filteredStation = [[Station alloc] init];
            filteredStation.name = aStation.name;
            
            [aStation.dishes enumerateObjectsUsingBlock:^(Dish *aDish, NSUInteger idx, BOOL *stop) {
                Dish *dish = [[Dish alloc] initWithOtherDish:aDish];
                
                //TODO handle favorites.
                [filteredStation.dishes addObject:dish];
            }];
            
            [filteredStations addObject:filteredStation];
            
            for (NSPredicate *predicate in predicates) {
                // NSLog(@"Pred: %@", predicate);
                for (Station *theStation in filteredStations) {
                    [theStation.dishes filterUsingPredicate:predicate];
                    
                    if (theStation.dishes.count == 0) {
                        [filteredStations removeObject:theStation];
                    }
                }
            }
        }];
        
        Meal *filteredMeal = [[Meal alloc] initWithStations:filteredStations andName:meal.name];
        [filteredMenu addObject:filteredMeal];
    }];
    
    return filteredMenu;
}

-(void)printMenu:(NSArray *)menuArray
{
    for (Meal *meal in menuArray) {
        for (Station *station in meal.stations) {
            NSLog(@"%@ %@",station.name, station.dishes);
        }
    }
}

- (void)getAvailableDays
{
    
    if (!self.hasAvailableDays) {
        
        //requestQueue = dispatch_queue_create("edu.grinnell.glicious", NULL);
        
        //There's a network connection. Before Pulling in any real data. Let's check if there actually is any data available.
        //Using the available days json to do this. Is there a better way? Even though this works.
        NSURL *datesAvailableURL = [NSURL URLWithString:@"http://tcdb.grinnell.edu/apps/glicious/last_date.json"];
        NSError *error;
        NSData *availableData = [NSData dataWithContentsOfURL:datesAvailableURL];
        NSDictionary *availableDaysJson = [[NSDictionary alloc] init];
        
        if (availableData != nil) {
            availableDaysJson = [NSJSONSerialization JSONObjectWithData:availableData
                                                                options:kNilOptions
                                                                  error:&error];
            
            NSString *dayString = availableDaysJson[@"Last_Day"];
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"MM-dd-yyyy"];
            NSDate *lastDate = [df dateFromString:dayString];
            NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:[NSDate date] toDate:lastDate options:0];
            self.availableDays = [components day] + 1;
            self.hasAvailableDays = YES;
        } else {
            //Available Data is nil which means, the server may be down or there is something else interfering.
            //App will not run.
            //[self performSelectorOnMainThread:@selector(showNoServerAlert) withObject:nil waitUntilDone:YES];
            //return;
            
            //TODO handle ERROR! Server Error:
        }
    }
    
}

/* Sets the page value that the Stations view should scroll to depending on the time
 * of the day G-licious was accessed
 */
- (void)setCurrentPage
{
    NSDateComponents *todayComponents = [[NSCalendar currentCalendar] components:NSHourCalendarUnit | NSMinuteCalendarUnit | NSWeekdayCalendarUnit fromDate:self.date];
    
    NSDate *tomorrow = [[NSDate alloc] initWithTimeInterval:60*60*24 sinceDate:self.date];
    
    
    NSInteger hour = [todayComponents hour];
    NSInteger minute = [todayComponents minute];
    NSInteger weekday = [todayComponents weekday];
    
    //Sunday
    
    if (weekday == 1){
        if (hour < 13 || (hour < 14 && minute < 30))
            //self.mealChoice = @"Lunch";
            self.page = 0;
        else if (hour < 19)
            self.page = 1;
        //self.mealChoice = @"Dinner";
        else{
            //            self.mealChoice = @"Breakfast";
            self.date = tomorrow;
        }
    }
    
    //Saturday
    else if (weekday == 7){
        if (hour < 10)
            self.page = 0;
        else if (hour < 13 || (hour < 14 && minute < 30))
            self.page = 1;
        else if (hour < 19)
            self.page = 2;
        else{
            self.page = 0;
            self.date = tomorrow;
        }
    }
    //Friday
    else if (weekday == 6){
        if (hour < 10)
            self.page = 0;
        else if (hour < 13 || (hour < 14 && minute < 30))
            self.page = 1;
        else if (hour < 19)
            self.page = 2;
        else{
            self.page = 1;
            self.date = tomorrow;
        }
    }
    //All other days
    else{
        if (hour < 10)
            self.page = 0;
        else if (hour < 13 || (hour < 14 && minute < 30))
            self.page = 1;
        else if (hour < 20)
            self.page = 2;
        else{
            self.page = 1;
            self.date = tomorrow;
        }
    }
}

//Method to determine the availability of network Connections using the Reachability Class
- (BOOL)networkCheck {
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    return (!(networkStatus == NotReachable));
}







@end
