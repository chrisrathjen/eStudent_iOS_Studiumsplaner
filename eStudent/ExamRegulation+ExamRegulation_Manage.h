//
//  ExamRegulation+ExamRegulation_Manage.h
//  eStudent
//
//  Created by Christian Rathjen on 16.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ExamRegulations.h"


@interface ExamRegulations (ExamRegulation_Manage)
+ (ExamRegulations *)examRegulationWithParsedData:(NSNumber *)creditPoints
                                   regulationName:(NSString *)regulationName
                                        facultyNr:(NSNumber *)facultyNumber
                                   regulationDate:(NSString *)regulationDate
                                          subject:(NSString *)subject
                                           degree:(NSString *)degree
                                 inManagedContext:(NSManagedObjectContext *)context;


@end
