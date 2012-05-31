//
//  Food+Create.h
//  mensa_data
//
//  Created by Christian Rathjen on 22.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Food.h"
#import "foodEntry.h"
#import "Day.h"

//Diese Kategorie erweitert die Datenbank Entity Food um eine Methode zum erstellen neuer Foodeintraege.
@interface Food (Create)
+ (Food *)foodWithFoodEntry:(foodEntry *)aFoodEntry
                orderString:(NSString *)order
             onDayOfTheWeek:(Day *)day
           inManagedContext:(NSManagedObjectContext *)context;
@end
