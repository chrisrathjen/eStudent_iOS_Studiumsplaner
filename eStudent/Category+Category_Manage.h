//
//  Category+Category_Manage.h
//  eStudent
//
//  Created by Christian Rathjen on 16.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Category.h"

@interface Category (Category_Manage)
+ (Category *)categoryWithParsedData:(NSString *)name
                    inExamRegulation:(ExamRegulations *)anExamRegulation
              inManagedObjectContext:(NSManagedObjectContext *)context;
@end
