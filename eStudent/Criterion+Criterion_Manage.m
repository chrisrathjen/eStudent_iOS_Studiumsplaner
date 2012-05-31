//
//  Criterion+Criterion_Manage.m
//  eStudent
//
//  Created by Christian Rathjen on 16.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Criterion+Criterion_Manage.h"

@implementation Criterion (Criterion_Manage)
+ (Criterion *)criterionWithParsedData:(NSString *)name
                                  note:(NSString *)note
                            inCategory:(Category *)aCategory
                             inContext:(NSManagedObjectContext *)context
{
    Criterion *aCriterion = nil;
    aCriterion = [NSEntityDescription insertNewObjectForEntityForName:@"Criterion" inManagedObjectContext:context];
    
    aCriterion.name = name;
    aCriterion.note = note;
    aCriterion.category = aCategory;
    
    return aCriterion;
}
@end
