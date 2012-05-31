//
//  TaskCategory+Create.h
//  eStudent
//
//  Created by Georg Scharsich on 14.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TaskCategory.h"

@interface TaskCategory (Create)
+(TaskCategory *)TaskCategoryFromUserInput:(NSString *)name
                          inManagedContext:(NSManagedObjectContext *)context;
@end
