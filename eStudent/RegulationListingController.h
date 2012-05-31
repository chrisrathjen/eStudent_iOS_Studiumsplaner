//
//  RegulationListingController.h
//  eStudent
//
//  Created by Christian Rathjen on 24.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ERRegulationListingDownloader.h"
#import "ERDataManager.h"

@interface RegulationListingController : UITableViewController
@property (nonatomic, strong) ERRegulationListingDownloader *downloader;
@end
