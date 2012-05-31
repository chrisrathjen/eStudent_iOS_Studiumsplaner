//
//  Choosable+Choosable_Manage.h
//  eStudent
//
//  Created by Christian Rathjen on 16.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Choosable.h"

@interface Choosable (Choosable_Manage)
+ (Choosable *)choosableWithParsedData:(Category *)aCategory
                              withName:(NSString *)name
                                    cp:(NSNumber *)cp
                              duration:(NSNumber *)duration
                inManagedObjectContext:(NSManagedObjectContext *)context;
@end
