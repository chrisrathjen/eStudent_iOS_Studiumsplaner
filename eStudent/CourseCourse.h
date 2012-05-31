//
//  CourseCourse.h
//  eStudent
//
//  Created by Jalyna on 28.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CourseDate, CourseStaff, CourseSubject;

@interface CourseCourse : NSManagedObject

@property (nonatomic, retain) NSString * course_description;
@property (nonatomic, retain) NSString * ects;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * vak;
@property (nonatomic, retain) CourseSubject *belongsToSubject;
@property (nonatomic, retain) NSSet *hasDate;
@property (nonatomic, retain) NSSet *hasStaff;

@end

@interface CourseCourse (CoreDataGeneratedAccessors)

- (void)addHasDateObject:(CourseDate *)value;
- (void)removeHasDateObject:(CourseDate *)value;
- (void)addHasDate:(NSSet *)values;
- (void)removeHasDate:(NSSet *)values;

- (void)addHasStaffObject:(CourseStaff *)value;
- (void)removeHasStaffObject:(CourseStaff *)value;
- (void)addHasStaff:(NSSet *)values;
- (void)removeHasStaff:(NSSet *)values;



@end
