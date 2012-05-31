//
//  Day+Create.m
//  mensa_data
//
//  Created by Christian Rathjen on 22.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Day+Create.h"

@implementation Day (Create)
+ (Day *)dayWithParsedData:(NSString *)name
                  location:(Menu *)menu
          inManagedContext:(NSManagedObjectContext *)context
{
    Day *aDay = nil;
    aDay = [NSEntityDescription insertNewObjectForEntityForName:@"Day" inManagedObjectContext:context];
    aDay.name = name;
    aDay.location = menu;    
    return aDay;
}
@end
