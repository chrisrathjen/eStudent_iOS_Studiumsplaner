//
//  Menu.h
//  mensa_data
//
//  Created by Christian Rathjen on 03.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Day;

@interface Menu : NSManagedObject

@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * week;
@property (nonatomic, retain) NSSet *days;
@end

@interface Menu (CoreDataGeneratedAccessors)

- (void)addDaysObject:(Day *)value;
- (void)removeDaysObject:(Day *)value;
- (void)addDays:(NSSet *)values;
- (void)removeDays:(NSSet *)values;

@end
