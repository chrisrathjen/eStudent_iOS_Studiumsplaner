//
//  CourseDate.h
//  eStudent
//
//  Created by Jalyna on 28.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CourseCourse;

@interface CourseDate : NSManagedObject

@property (nonatomic, retain) NSString * dayEnd;
@property (nonatomic, retain) NSString * dayStart;
@property (nonatomic, retain) NSString * endRange;
@property (nonatomic, retain) NSString * prefix;
@property (nonatomic, retain) NSString * room;
@property (nonatomic, retain) NSString * startRange;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * weekDay;
@property (nonatomic, retain) CourseCourse *belongsToCourseDate;

@end
