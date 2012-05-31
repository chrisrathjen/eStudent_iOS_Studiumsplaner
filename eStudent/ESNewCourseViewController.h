//
//  ESNewCourseViewController.h
//  eStudent
//
//  Created by Nicolas Autzen on 09.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Veranstaltung.h"
#import "ESStundenplanDataManager.h"

@interface ESNewCourseViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic,strong)IBOutlet UITextField *titel;
@property (nonatomic,strong)IBOutlet UITextField *ort;
@property (nonatomic,strong)IBOutlet UISegmentedControl *veranstaltungsart;
@property (nonatomic,strong)IBOutlet UILabel *artLabel;
@property (nonatomic,strong)IBOutlet UIScrollView *scrollView;
@property (nonatomic,strong)IBOutlet UISegmentedControl *wochentag;
@property (nonatomic,strong)IBOutlet UITableViewCell *anfangsdatum;
@property (nonatomic,strong)IBOutlet UITableViewCell *anfangszeit;
@property (nonatomic,strong)IBOutlet UITableViewCell *endzeit;
@property (nonatomic,strong)IBOutlet UITableViewCell *enddatum;
@property (nonatomic,strong)IBOutlet UIDatePicker *datePicker;
@property (nonatomic,strong)IBOutlet UIBarButtonItem *fertigButton;
@property (nonatomic,strong)NSDate *currentDate;
@property (nonatomic,strong)Veranstaltung *veranstaltungZumBearbeiten;

@property (nonatomic, strong) ESStundenplanDataManager *stundenplanDataManager;

- (IBAction)dismissNewCourseViewController:(id)sender;
- (IBAction)fertigButtonIsTouched:(id)sender;

@end
