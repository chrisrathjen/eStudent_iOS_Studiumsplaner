//
//  CategoriesViewController.h
//  eStudent
//
//  Created by Georg Scharsich on 25.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskCategory.h"
@class CategoriesViewController;
@protocol CategoriesViewControllerDelegate
@optional
-(void)categorieFromUserSelection:(TaskCategory *)aTaskCategorie;

@end
@interface CategoriesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

- (IBAction)createNewCategorie:(id)sender;

@property (nonatomic , strong) id <CategoriesViewControllerDelegate> delegate;
@property (nonatomic, strong) UIManagedDocument *document; //Document mit DB link
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *theTextField;
@end
