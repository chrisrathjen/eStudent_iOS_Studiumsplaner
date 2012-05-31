//
//  Course_ER.h
//  eStudent
//
//  Created by Christian Rathjen on 30.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Category, Choosable, Optional;

@interface Course_ER : NSManagedObject

@property (nonatomic, retain) NSNumber * cp;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSNumber * mark;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * necCP;
@property (nonatomic, retain) NSNumber * passed;
@property (nonatomic, retain) NSString * vak;
@property (nonatomic, retain) Category *category;
@property (nonatomic, retain) Choosable *isChoice;
@property (nonatomic, retain) NSSet *optional;
@end

@interface Course_ER (CoreDataGeneratedAccessors)

- (void)addOptionalObject:(Optional *)value;
- (void)removeOptionalObject:(Optional *)value;
- (void)addOptional:(NSSet *)values;
- (void)removeOptional:(NSSet *)values;

@end
