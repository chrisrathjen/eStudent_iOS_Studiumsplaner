//
//  Menu+Create.m
//  mensa_data
//
//  Created by Christian Rathjen on 22.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Menu+Create.h"

@implementation Menu (Create)
+ (Menu *)menuFromParsedData:(NSString *)location
               weekOftheYear:(NSString *)week
            inManagedContext:(NSManagedObjectContext *)context
{
    Menu * aMenu = nil;
    aMenu = [NSEntityDescription insertNewObjectForEntityForName:@"Menu" inManagedObjectContext:context];
    aMenu.location = location;
    NSLog(@"Speichere Menue fuer Woche: %@", week);
    aMenu.week = week;
    
    return aMenu;
}
@end
