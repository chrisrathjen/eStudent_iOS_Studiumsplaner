//
//  Choosable+Choosable_Manage.m
//  eStudent
//
//  Created by Christian Rathjen on 16.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Choosable+Choosable_Manage.h"

@implementation Choosable (Choosable_Manage)
+ (Choosable *)choosableWithParsedData:(Category *)aCategory
                              withName:(NSString *)name
                                    cp:(NSNumber *)cp
                              duration:(NSNumber *)duration
                inManagedObjectContext:(NSManagedObjectContext *)context
{
    Choosable *aChoosable = nil;
    aChoosable = [NSEntityDescription insertNewObjectForEntityForName:@"Choosable" inManagedObjectContext:context];
    aChoosable.name = name;
    aChoosable.cp = cp;
    aChoosable.duration = duration;
    aChoosable.category = aCategory;
    
    return aChoosable;
}
@end
