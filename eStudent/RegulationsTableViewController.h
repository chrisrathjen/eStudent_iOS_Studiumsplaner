//
//  RegulationsTableViewController.h
//  eStudent
//
//  Created by Christian Rathjen on 15.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "ERDataManager.h"
#import "ERRegulationListingDownloader.h"

@interface RegulationsTableViewController : CoreDataTableViewController
@property (nonatomic, strong) ERDataManager *dataManager;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButtom;

@end
