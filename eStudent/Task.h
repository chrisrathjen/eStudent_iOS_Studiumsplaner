//
//  Task.h
//  eStudent
//
//  Created by Georg Scharsich on 29.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TaskCategory;

@interface Task : NSManagedObject

@property (nonatomic, retain) NSNumber * done;
@property (nonatomic, retain) NSString * duedate;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * priority;
@property (nonatomic, retain) TaskCategory *category;

@end
