//
//  Course+Course_Manage.h
//  eStudent
//
//  Created by Christian Rathjen on 16.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Course_ER.h"

@interface Course_ER (Course_Manage)
+ (Course_ER *)courseWithParsedData:(NSNumber *)creditPoints
                    withDuration:(NSNumber *)duration
                            name:(NSString *)name
                           necCP:(NSNumber *)necCP
                       vakNumber:(NSString *)vak
                      inCategory:(Category *)aCategory
                     isChoosbale:(Choosable *)isChoosable
                inManagedContext:(NSManagedObjectContext *)context;
@end
