//
//  Food+Create.m
//  mensa_data
//
//  Created by Christian Rathjen on 22.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Food+Create.h"

@implementation Food (Create)
+ (Food *)foodWithFoodEntry:(foodEntry *)aFoodEntry
                orderString:(NSString *)order
             onDayOfTheWeek:(Day *)day
           inManagedContext:(NSManagedObjectContext *)context
{
    Food * aFood = nil;
    aFood = [NSEntityDescription insertNewObjectForEntityForName:@"Food" inManagedObjectContext:context];
    //NSLog(@"Speichere: %@",aFoodEntry.name);
    aFood.name = aFoodEntry.name;
    aFood.foodDescription = aFoodEntry.foodDescription;
    aFood.extra = aFoodEntry.extra;
    aFood.type = aFoodEntry.type;
    aFood.staffPrice = aFoodEntry.staffPrice;
    aFood.studentPrice = aFoodEntry.studentPrice;
    aFood.order = order;
    aFood.day = day; //Zum Essen gehoerdender Tag (inverses dieser Verbindung wird automatisch gesetzt)
    return aFood;
}
@end
