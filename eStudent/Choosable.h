//
//  Choosable.h
//  eStudent
//
//  Created by Christian Rathjen on 30.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Category, Course_ER;

@interface Choosable : NSManagedObject

@property (nonatomic, retain) NSNumber * cp;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Category *category;
@property (nonatomic, retain) NSSet *choices;
@end

@interface Choosable (CoreDataGeneratedAccessors)

- (void)addChoicesObject:(Course_ER *)value;
- (void)removeChoicesObject:(Course_ER *)value;
- (void)addChoices:(NSSet *)values;
- (void)removeChoices:(NSSet *)values;

@end
