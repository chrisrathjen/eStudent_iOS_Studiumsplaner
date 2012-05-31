//
//  CourseSubject.h
//  eStudent
//
//  Created by Jalyna on 28.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CourseCourse;

@interface CourseSubject : NSManagedObject

@property (nonatomic, retain) NSString * file;
@property (nonatomic, retain) NSString * semester;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *hasCourses;

@end

@interface CourseSubject (CoreDataGeneratedAccessors)

- (void)addHasCoursesObject:(CourseCourse *)value;
- (void)removeHasCoursesObject:(CourseCourse *)value;
- (void)addHasCourses:(NSSet *)values;
- (void)removeHasCourses:(NSSet *)values;

@end
