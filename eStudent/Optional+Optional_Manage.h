//
//  Optional+Optional_Manage.h
//  eStudent
//
//  Created by Christian Rathjen on 16.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Optional.h"

@interface Optional (Optional_Manage)
+ (Optional *)anOptionalWithParsedData:(NSNumber *)creditPoints
                                  name:(NSString *)name
                             vakNumber:(NSString *)vak
                            inCategory:(Category *)aCategory
                inManagedObjectContext:(NSManagedObjectContext *)context;
@end
