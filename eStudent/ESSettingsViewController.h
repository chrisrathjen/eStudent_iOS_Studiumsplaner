//
//  ESSettingsViewController.h
//  eStudent
//
//  Created by Nicolas Autzen on 23.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ESSettingsViewController : UIViewController <UIActionSheetDelegate>

@property (nonatomic)BOOL essensFarbenGesetzt;
@property (nonatomic,strong)IBOutlet UITableViewCell *essensSwitchCell;
@property (nonatomic,strong)IBOutlet UISwitch *essensFarbenSwitch;

- (IBAction)deleteAllDatabases:(id)sender;//aktuell nur studnenplan
- (IBAction)essensSwitchgeswitched:(id)sender;
- (IBAction)resetTips:(id)sender;

@end
