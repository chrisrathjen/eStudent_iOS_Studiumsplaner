//
//  ESMensaViewController.h
//  eStudent
//
//  Created by Nicolas Autzen on 21.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MensaDataManager.h"

@interface ESMensaViewController : UIViewController <UIActionSheetDelegate, UIScrollViewDelegate, MensaDataManagerDelegate>

@property (nonatomic,strong) MensaDataManager *dataManager;
@property (nonatomic,strong) IBOutlet UILabel *dateLabel;
@property (nonatomic,strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic,strong) IBOutlet UINavigationItem *mensaTitle;
@property (nonatomic,strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic,strong) IBOutlet UIPageControl *pageControl;
@property (nonatomic) int currentPage;
@property (nonatomic) int weekday;
@property (nonatomic,strong) NSDate *currentDate;
@property (nonatomic)BOOL essensFarbenGesetzt;

- (void) addMealsToView:(id)meals atPosition:(int)positionOnScreen;
- (IBAction) chooseMensa:(id)sender;
- (BOOL) isWeekend;
- (NSString *) date:(NSDate *)date;


@end
