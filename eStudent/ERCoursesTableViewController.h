//
//  ERCoursesTableViewController.h
//  eStudent
//
//  Created by Christian Rathjen on 15.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ERDataManager.h"
#import "Category.h"


@interface ERCoursesTableViewController : UITableViewController
@property (nonatomic, strong) ERDataManager *dataManager; 
@property (nonatomic, strong) Category *category;

- (IBAction)moveCourses:(id)sender;
- (IBAction)deleteSelectedCourses:(id)sender;

@end
