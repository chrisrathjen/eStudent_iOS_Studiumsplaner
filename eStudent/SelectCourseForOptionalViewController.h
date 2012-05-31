//
//  SelectCourseForOptionalViewController.h
//  eStudent
//
//  Created by Christian Rathjen on 26.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Course_ER.h"
#import "Optional.h"

@class SelectCourseForOptionalViewController;
@protocol SelectCoursesDelegate
- (void)selectedCourse:(Course_ER *)aCourse inOptional:(Optional *)anOptional;
- (void)removeCourse:(Course_ER *)aCourse fromOptional:(Optional *)anOptional;
@end

@interface SelectCourseForOptionalViewController : UITableViewController

@property (nonatomic, strong)NSArray *courses;
@property (nonatomic, strong)Optional *anOptional;
@property (nonatomic, strong)id <SelectCoursesDelegate> delegate;

@end
