//
//  Course+Course_Manage.m
//  eStudent
//
//  Created by Christian Rathjen on 16.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Course+Course_Manage.h"

@implementation Course_ER (Course_Manage)
+ (Course_ER *)courseWithParsedData:(NSNumber *)creditPoints
                    withDuration:(NSNumber *)duration
                            name:(NSString *)name
                           necCP:(NSNumber *)necCP
                       vakNumber:(NSString *)vak
                      inCategory:(Category *)aCategory
                     isChoosbale:(Choosable *)isChoosable
                inManagedContext:(NSManagedObjectContext *)context
{
    Course_ER *aCourse = nil;
    aCourse = [NSEntityDescription insertNewObjectForEntityForName:@"Course_ER" inManagedObjectContext:context];
    
    aCourse.cp = creditPoints;
    aCourse.duration = duration;
    aCourse.name = name;
    aCourse.necCP = necCP;
    aCourse.vak = vak;
    
    //vlt unnoetig aber falls ein Course keien Cat/choice hat wird das auch nicht gesetzt. Kp ob CoreData nil mag...
    if (aCategory) aCourse.category = aCategory;
    if (isChoosable) aCourse.isChoice = isChoosable;
    
    return aCourse;
}
@end
