//
//  DetailViewController.h
//  eStudent
//
//  Created by Christian Rathjen on 09.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Course+Course_Manage.h"
#import "ERDataManager.h"

@interface DetailViewController : UIViewController
@property (nonatomic, strong) ERDataManager *dataManager;
@property (nonatomic, strong) Course_ER *course;

@end
