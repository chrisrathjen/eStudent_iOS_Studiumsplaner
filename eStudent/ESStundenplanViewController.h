//
//  ESStundenplanViewController.h
//  eStudent
//
//  Created by Nicolas Autzen on 05.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "CMPopTipView.h"
#import "ESNewCourseViewController.h"
#import "Veranstaltung.h"
#import "ESStundenplanDataManager.h"

@interface ESStundenplanViewController : UIViewController <UIScrollViewDelegate, CMPopTipViewDelegate, ESStundenplanDataManagerDelegate, UIActionSheetDelegate>

@property (nonatomic,strong)IBOutlet UIBarButtonItem *bearbeitenButton;
@property (nonatomic,strong)IBOutlet UIBarButtonItem *heuteButton;
@property (nonatomic,strong)IBOutlet UIBarButtonItem *addButton;
@property (nonatomic,strong)IBOutlet UIToolbar *toolbar;
@property (nonatomic,strong)ESNewCourseViewController *createCourseViewController;
@property (nonatomic,strong)IBOutlet UIBarButtonItem *flexibleSpace;
@property (nonatomic,strong)IBOutlet UILabel *dateLabel;
@property (nonatomic,strong)IBOutlet UIScrollView *scrollview;
@property (nonatomic)int weekday;
@property (nonatomic,copy)NSArray *weekdays;
@property (nonatomic,strong)NSDate *currentDate;
@property (nonatomic)int currentPage;
@property (nonatomic)BOOL blocker;
@property (nonatomic,copy)NSArray *veranstaltungen;
@property (nonatomic,strong)IBOutlet UIScrollView *middle;
@property (nonatomic,strong)IBOutlet UIScrollView *left;
@property (nonatomic,strong)IBOutlet UIScrollView *right;   
@property (nonatomic,strong)IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic,strong)CMPopTipView *addCourseTip;
@property (nonatomic,strong)Veranstaltung *veranstaltungZumBearbeiten;
@property (nonatomic,strong)NSTimer *timer;

@property (nonatomic)BOOL isLeftBlocked;
@property (nonatomic)BOOL isMiddleBlocked;
@property (nonatomic)BOOL isRightBlocked;

@property (nonatomic,strong)ESStundenplanDataManager *stundenplanDataManager;

@property (nonatomic,strong)NSMutableArray *coursesReadyToDelete;

- (IBAction)bearbeiten:(id)sender;
- (IBAction)heuteButtonPressed:(id)sender;
- (NSString *) date:(NSDate *)date;
- (void)getStundenplanData;
- (void)setToday;
- (void)setVeranstaltungsAnzeige:(UIScrollView *)position mitDaten:(NSMutableArray *)vs;
- (void)setStundenplan;
- (NSDate *)normalizeDate:(NSDate *)date;
- (void)veranstaltungBearbeiten:(id)sender;
- (BOOL)isTheCourseRightNow:(Veranstaltung *)v;
- (void)setVisibility:(UITapGestureRecognizer *)sender;
- (void)setInvisibility:(UITapGestureRecognizer *)sender;

@end
