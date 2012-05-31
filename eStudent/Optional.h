//
//  Optional.h
//  eStudent
//
//  Created by Christian Rathjen on 30.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Category, Course_ER;

@interface Optional : NSManagedObject

@property (nonatomic, retain) NSNumber * cp;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * vak;
@property (nonatomic, retain) Category *category;
@property (nonatomic, retain) NSSet *courses;
@end

@interface Optional (CoreDataGeneratedAccessors)

- (void)addCoursesObject:(Course_ER *)value;
- (void)removeCoursesObject:(Course_ER *)value;
- (void)addCourses:(NSSet *)values;
- (void)removeCourses:(NSSet *)values;

@end
