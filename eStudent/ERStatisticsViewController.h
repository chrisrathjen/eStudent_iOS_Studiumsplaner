//
//  ERStatisticsViewController.h
//  eStudent
//
//  Created by Christian Rathjen on 29.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ERDataManager.h"
#import "ExamRegulations.h"

@interface ERStatisticsViewController : UIViewController <UITableViewDataSource, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *aLabel;
@property (strong, nonatomic)ExamRegulations *aRegulation;
@property (weak, nonatomic) IBOutlet UIProgressView *aProgressBar;
@property (weak, nonatomic) IBOutlet UITableView *aTableView;
@end
