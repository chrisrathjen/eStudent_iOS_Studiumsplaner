//
//  Criterion+Criterion_Manage.h
//  eStudent
//
//  Created by Christian Rathjen on 16.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Criterion.h"

@interface Criterion (Criterion_Manage)
+ (Criterion *)criterionWithParsedData:(NSString *)name
                                  note:(NSString *)note
                            inCategory:(Category *)aCategory
                             inContext:(NSManagedObjectContext *)context;
@end
