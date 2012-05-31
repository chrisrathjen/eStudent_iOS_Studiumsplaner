//
//  CoursesDetailsViewController.h
//  eStudent
//
//  Created by Jalyna on 11.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CourseCourse.h"
#import "ERDataManager.h"
#import "ESStundenplanDataManager.h"

@interface CoursesDetailsViewController : UIViewController <UITableViewDataSource, ERDataManagerDelegate, ESStundenplanDataManagerDelegate> {
    UITableView *tv;
}

@property (nonatomic, retain) IBOutlet UITableView *tv;
@property (nonatomic,strong) ERDataManager *dataManager; // Data-Manager um Informationen aus dem Studiumsplaner zu bekommen
@property (nonatomic, strong)ESStundenplanDataManager *stundenplanDataManager; // Data-Manager um Informationen zum Stundenplan zu erhalten
@property (nonatomic, retain) IBOutlet CourseCourse *course;

@end
