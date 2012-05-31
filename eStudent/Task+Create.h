//
//  Task+Create.h
//  eStudent
//
//  Created by Georg Scharsich on 14.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Task.h"
#import "TaskCategory.h"

@interface Task (Create)
+ (Task *)TaskFromUserInput:(NSString *)name
                       date:(NSString *)date
                   priority:(NSNumber *)priority
                 inCategory:(TaskCategory *)category
           inManagedContext:(NSManagedObjectContext *)context;
@end
