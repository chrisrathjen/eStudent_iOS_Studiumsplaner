//
//  Optional+Optional_Manage.m
//  eStudent
//
//  Created by Christian Rathjen on 16.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Optional+Optional_Manage.h"

@implementation Optional (Optional_Manage)
+ (Optional *)anOptionalWithParsedData:(NSNumber *)creditPoints
                                  name:(NSString *)name
                             vakNumber:(NSString *)vak
                            inCategory:(Category *)aCategory
                inManagedObjectContext:(NSManagedObjectContext *)context
{
    Optional *anOptional = nil;
    anOptional = [NSEntityDescription insertNewObjectForEntityForName:@"Optional" inManagedObjectContext:context];
    
    anOptional.cp = creditPoints;
    anOptional.name = name;
    anOptional.vak = vak;
    anOptional.category = aCategory;
    
    return anOptional;
}
@end
