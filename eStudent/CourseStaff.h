//
//  CourseStaff.h
//  eStudent
//
//  Created by Jalyna on 28.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CourseCourse;

@interface CourseStaff : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) CourseCourse *belongsToCourseStaff;

@end
