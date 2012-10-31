//
//  modifyTaskViewController.h
//  eStudent
//
//  Created by Georg Scharsich on 14.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task+Create.h"
@protocol tasksDelegate
@optional
- (void)savingFinished; // DelegateMethode nach erfolgreichem Speichern einer aenderung
@end

@interface modifyTaskViewController : UIViewController

//Actions die vom user im Interface aufgerufen werden koennen
- (IBAction)segmentValueChanged:(id)sender;
- (IBAction)dateChanged:(id)sender;
- (IBAction)removeDueDate:(id)sender;

//Interface objecte (Label, Textfelder, ...)
@property (weak, nonatomic) IBOutlet UISegmentedControl *segControl;
@property (weak, nonatomic) IBOutlet UILabel *dueDateLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *catButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

//Diese Attribute werden vom vorherigen View gesetzt
@property (strong, nonatomic)Task *aTask;
@property (strong, nonatomic)id <tasksDelegate> delegate;
@property (strong, nonatomic) UIManagedDocument *document;

@end
