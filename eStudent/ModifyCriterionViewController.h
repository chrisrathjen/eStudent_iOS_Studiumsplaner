//
//  ModifyCriterionViewController.h
//  eStudent
//
//  Created by Christian Rathjen on 10.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Criterion.h"
#import "ERDataManager.h"

@interface ModifyCriterionViewController : UIViewController 
- (IBAction)valueChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic) Criterion *aCriterion;
@property (strong, nonatomic) ERDataManager *aDataManager;


@end
