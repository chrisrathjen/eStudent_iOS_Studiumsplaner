//
//  ExamRegulations.h
//  eStudent
//
//  Created by Christian Rathjen on 30.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Category;

@interface ExamRegulations : NSManagedObject

@property (nonatomic, retain) NSNumber * cp;
@property (nonatomic, retain) NSString * degree;
@property (nonatomic, retain) NSNumber * facultyNr;
@property (nonatomic, retain) NSString * fileName;
@property (nonatomic, retain) NSString * regulationdate;
@property (nonatomic, retain) NSString * subject;
@property (nonatomic, retain) NSSet *categories;
@end

@interface ExamRegulations (CoreDataGeneratedAccessors)

- (void)addCategoriesObject:(Category *)value;
- (void)removeCategoriesObject:(Category *)value;
- (void)addCategories:(NSSet *)values;
- (void)removeCategories:(NSSet *)values;

@end
