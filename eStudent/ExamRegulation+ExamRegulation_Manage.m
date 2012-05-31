//
//  ExamRegulation+ExamRegulation_Manage.m
//  eStudent
//
//  Created by Christian Rathjen on 16.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ExamRegulation+ExamRegulation_Manage.h"

@implementation ExamRegulations (ExamRegulation_Manage)
+ (ExamRegulations *)examRegulationWithParsedData:(NSNumber *)creditPoints
                                   regulationName:(NSString *)regulationName
                                        facultyNr:(NSNumber *)facultyNumber
                                   regulationDate:(NSString *)regulationDate
                                          subject:(NSString *)subject
                                           degree:(NSString *)degree
                                 inManagedContext:(NSManagedObjectContext *)context
{
    ExamRegulations *aRegulation = nil;
    aRegulation = [NSEntityDescription insertNewObjectForEntityForName:@"ExamRegulations" inManagedObjectContext:context];
    
    aRegulation.cp = creditPoints;
    aRegulation.fileName = regulationName;
    aRegulation.facultyNr = facultyNumber;
    aRegulation.regulationdate = regulationDate;
    aRegulation.subject = subject;
    aRegulation.degree = degree;
    return aRegulation;
}

@end
