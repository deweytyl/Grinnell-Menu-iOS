//
//  Meal.h
//  Grinnell-Menu-iOS
//
//  Created by Maijid Moujaled on 5/28/13.
//
//

#import <Foundation/Foundation.h>

@interface Meal : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableArray *stations;

@property(nonatomic) int scoreForSorting;

-(id)initWithMealDict:(NSDictionary *)mealDict andName:(NSString *)mealName;
-(id)initWithStations:(NSMutableArray *)theStations andName:(NSString *)mealName;

@end
