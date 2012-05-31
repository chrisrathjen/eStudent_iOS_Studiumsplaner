//
//  Category.h
//  eStudent
//
//  Created by Christian Rathjen on 30.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Choosable, Course_ER, Criterion, ExamRegulations, Optional;

@interface Category : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *courses;
@property (nonatomic, retain) NSSet *criteria;
@property (nonatomic, retain) ExamRegulations *examReg;
@property (nonatomic, retain) NSSet *hasChoice;
@property (nonatomic, retain) NSSet *optional;
@end

@interface Category (CoreDataGeneratedAccessors)

- (void)addCoursesObject:(Course_ER *)value;
- (void)removeCoursesObject:(Course_ER *)value;
- (void)addCourses:(NSSet *)values;
- (void)removeCourses:(NSSet *)values;

- (void)addCriteriaObject:(Criterion *)value;
- (void)removeCriteriaObject:(Criterion *)value;
- (void)addCriteria:(NSSet *)values;
- (void)removeCriteria:(NSSet *)values;

- (void)addHasChoiceObject:(Choosable *)value;
- (void)removeHasChoiceObject:(Choosable *)value;
- (void)addHasChoice:(NSSet *)values;
- (void)removeHasChoice:(NSSet *)values;

- (void)addOptionalObject:(Optional *)value;
- (void)removeOptionalObject:(Optional *)value;
- (void)addOptional:(NSSet *)values;
- (void)removeOptional:(NSSet *)values;

@end
