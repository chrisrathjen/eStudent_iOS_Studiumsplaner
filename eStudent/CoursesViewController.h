//
//  CoursesViewController.h
//  eStudent
//
//  Created by Jalyna on 02.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SemesterListLoader.h"

@interface CoursesViewController : UIViewController

@property (nonatomic, strong) SemesterListLoader *downloader;

@end
