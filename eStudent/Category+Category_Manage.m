//
//  Category+Category_Manage.m
//  eStudent
//
//  Created by Christian Rathjen on 16.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Category+Category_Manage.h"

@implementation Category (Category_Manage)
+ (Category *)categoryWithParsedData:(NSString *)name
                    inExamRegulation:(ExamRegulations *)anExamRegulation
              inManagedObjectContext:(NSManagedObjectContext *)context
{
    Category *aCategory = nil;
    aCategory = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:context];
    
    aCategory.name = name;
    aCategory.examReg = anExamRegulation;
    
    return aCategory;
}
@end
