//
//  Category.m
//  eStudent
//
//  Created by Christian Rathjen on 30.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Category.h"
#import "Choosable.h"
#import "Course_ER.h"
#import "Criterion.h"
#import "ExamRegulations.h"
#import "Optional.h"


@implementation Category

@dynamic name;
@dynamic courses;
@dynamic criteria;
@dynamic examReg;
@dynamic hasChoice;
@dynamic optional;

@end
