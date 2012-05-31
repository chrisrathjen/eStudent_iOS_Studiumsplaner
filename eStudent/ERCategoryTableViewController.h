//
//  ERCategoryTableViewController.h
//  eStudent
//
//  Created by Christian Rathjen on 15.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ERDataManager.h"
#import "ExamRegulations.h"

@interface ERCategoryTableViewController : UITableViewController
@property (nonatomic, strong) ExamRegulations *Regulation;
@property (nonatomic, strong) ERDataManager *dataManager;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *statsButtom;

@end
