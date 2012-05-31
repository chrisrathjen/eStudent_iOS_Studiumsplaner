//
//  CategorieListing.h
//  eStudent
//
//  Created by Christian Rathjen on 22.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ERDataManager.h"

@interface CategorieListing : UITableViewController
@property (nonatomic, strong)NSArray *dataSource;
@property (nonatomic, strong)NSArray *objectsToMove;
@property (nonatomic, strong)ERDataManager *dataManager;

@end
