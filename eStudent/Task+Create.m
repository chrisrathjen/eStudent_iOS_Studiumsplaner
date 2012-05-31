//
//  Task+Create.m
//  eStudent
//
//  Created by Georg Scharsich on 14.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Task+Create.h"

@implementation Task (Create)
+ (Task *)TaskFromUserInput:(NSString *)name
                       date:(NSString *)date
                   priority:(NSNumber *)priority
                 inCategory:(TaskCategory *)category
           inManagedContext:(NSManagedObjectContext *)context
{
    Task *aTask = [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:context];
    
    aTask.name = name;
    aTask.duedate = date;
    aTask.priority = priority;
    aTask.category = category;
    
    return aTask;
}
@end
