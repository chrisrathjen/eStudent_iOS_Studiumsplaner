//
//  TaskCategory+Create.m
//  eStudent
//
//  Created by Georg Scharsich on 14.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TaskCategory+Create.h"

@implementation TaskCategory (Create)
+(TaskCategory *)TaskCategoryFromUserInput:(NSString *)name
                          inManagedContext:(NSManagedObjectContext *)context
{
    TaskCategory *aTaskCategory = [NSEntityDescription insertNewObjectForEntityForName:@"TaskCategory" inManagedObjectContext:context];
    
    aTaskCategory.name = name;
    
    return aTaskCategory;
}
@end
