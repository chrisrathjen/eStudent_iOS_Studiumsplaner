//
//  SubjectCoursesViewController.h
//  eStudent
//
//  Created by Jalyna on 06.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoursesDataManager.h"

@interface SubjectCoursesViewController : UIViewController <UISearchBarDelegate, UITableViewDataSource, CoursesDataManagerDelegate> {
    UISearchBar *sb;
    UITableView *tv;
    UIToolbar *toolbar;
}

@property (nonatomic,strong) CoursesDataManager *dataManager; // dataManager um Kurse zu parsen bzw. aus der Datenbank zu laden
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UITableView *tv;
@property (nonatomic, retain) IBOutlet UISearchBar *sb;
@property (nonatomic, retain) IBOutlet NSString *fileName; // Filename des aktuellen Subject
@property (nonatomic, retain) IBOutlet NSString *semester; // Semester des aktuellen Subject
@property (nonatomic, retain) IBOutlet CourseSubject *subject; // Das aktuelle Subject
- (IBAction)switchToHome:(id)sender;
@end
