//
//  ESNewCourseViewController.m
//  eStudent
//
//  Created by Nicolas Autzen on 09.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ESNewCourseViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreData/CoreData.h>
#import "Veranstaltung+Create.h"
#import "ESStundenplanDataManager.h"

@interface ESNewCourseViewController ()

@end

@implementation ESNewCourseViewController

@synthesize titel, ort, veranstaltungsart, artLabel, scrollView, wochentag, anfangsdatum, anfangszeit, endzeit, enddatum, datePicker, fertigButton, currentDate, veranstaltungZumBearbeiten, stundenplanDataManager;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titel.placeholder = @"Titel";
    self.ort.placeholder = @"Ort";
    if (!self.veranstaltungZumBearbeiten) {
        self.fertigButton.enabled = NO;
    }
    else {
        [self.fertigButton setEnabled:YES];
    }
    
    [self.veranstaltungsart removeAllSegments];
    NSArray *items = [NSArray arrayWithObjects:@"V", @"K", @"S", @"Ü", nil];
    for (int i = 0; i < items.count; i++) {
        [self.veranstaltungsart insertSegmentWithTitle:[items objectAtIndex:(NSUInteger)i] atIndex:i animated:NO];
    }
    if ([self.veranstaltungZumBearbeiten.veranstaltungsart isEqualToString:@"V"] || !self.veranstaltungZumBearbeiten)
    {
        [self.veranstaltungsart setSelectedSegmentIndex:0];
    }
    else if ([self.veranstaltungZumBearbeiten.veranstaltungsart isEqualToString:@"K"]) 
    {
        [self.veranstaltungsart setSelectedSegmentIndex:1];
    }
    else if ([self.veranstaltungZumBearbeiten.veranstaltungsart isEqualToString:@"S"]) 
    {
        [self.veranstaltungsart setSelectedSegmentIndex:2];
    }
    else if ([self.veranstaltungZumBearbeiten.veranstaltungsart isEqualToString:@"Ü"]) 
    {
        [self.veranstaltungsart setSelectedSegmentIndex:3];
    }
    
    self.artLabel.text = @"V = Vorlesung, K = Kurs, S = Seminar, Ü = Übung";
    self.artLabel.textColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1.0];   
    
    self.titel.delegate = self;
    self.titel.text = self.veranstaltungZumBearbeiten.titel;
    self.ort.delegate = self;
    self.ort.text = self.veranstaltungZumBearbeiten.ort;
    
    [self.wochentag removeAllSegments];
    NSArray *wItems = [NSArray arrayWithObjects:@"Mo", @"Di", @"Mi", @"Do", @"Fr", @"Sa", @"So", nil];
    for (int i = 0; i < wItems.count; i++) {
        [self.wochentag insertSegmentWithTitle:[wItems objectAtIndex:(NSUInteger)i] atIndex:i animated:NO];
    }
    
    self.anfangsdatum.layer.borderColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1.0].CGColor;
    self.anfangsdatum.layer.borderWidth = .4f;
    self.anfangsdatum.layer.cornerRadius = 10.0;
    UITapGestureRecognizer *adrgnzr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(anfangsDIsTouched:)];
    [self.anfangsdatum addGestureRecognizer:adrgnzr];
    self.anfangsdatum.layer.masksToBounds = YES;
    
    self.anfangszeit.layer.borderColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1.0].CGColor;
    self.anfangszeit.layer.borderWidth = .4f;
    self.anfangszeit.layer.cornerRadius = 10.0;
    UITapGestureRecognizer *azrgnzr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(anfangsZIsTouched:)];
    [self.anfangszeit addGestureRecognizer:azrgnzr];
    self.anfangszeit.layer.masksToBounds = YES;
    
    UITapGestureRecognizer *ezrgnzr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endzeitIsTouched:)];
    [self.endzeit addGestureRecognizer:ezrgnzr];
    self.endzeit.layer.borderColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1.0].CGColor;
    self.endzeit.layer.borderWidth = .4f;
    self.endzeit.layer.cornerRadius = 10.0;
    self.endzeit.layer.masksToBounds = YES;
    
    UITapGestureRecognizer *edrgnzr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enddatumIsTouched:)];
    [self.enddatum addGestureRecognizer:edrgnzr];
    self.enddatum.layer.borderColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1.0].CGColor;
    self.enddatum.layer.borderWidth = .4f;
    self.enddatum.layer.cornerRadius = 10.0;
    self.enddatum.layer.masksToBounds = YES;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"de_DE"]];
    
    NSDate *today = [NSDate date];
    NSDateComponents *time = [[NSCalendar currentCalendar]
                              components:NSHourCalendarUnit
                              fromDate:today];
    int hours = [time hour];
    if ((hours+1) > 23) {
        today = [NSDate dateWithTimeInterval:60*60*24 sinceDate:today];
    }
    else if ((hours+3) >= 22) {
        today = [NSDate dateWithTimeInterval:60*60*24 sinceDate:today];
    }
    //self.datePicker.date = today;
    if (!self.veranstaltungZumBearbeiten) 
    {
        [self.anfangsdatum.detailTextLabel setText:[NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:self.currentDate]]];
        [self.anfangszeit.detailTextLabel setText:[NSString stringWithFormat:@"%d:00", (hours+1)%24]];
        [self.endzeit.detailTextLabel setText:[NSString stringWithFormat:@"%d:00", (hours+3)%24]];
        [self.enddatum.detailTextLabel setText:[NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:self.currentDate]]];
    }
    else 
    {
        [self.anfangsdatum.detailTextLabel setText:[NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:self.veranstaltungZumBearbeiten.anfangsdatum]]];
        [self.anfangszeit.detailTextLabel setText:self.veranstaltungZumBearbeiten.anfangszeit];
        [self.endzeit.detailTextLabel setText:self.veranstaltungZumBearbeiten.endzeit];
        [self.enddatum.detailTextLabel setText:[NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:self.veranstaltungZumBearbeiten.enddatum]]];
    }
    
    self.scrollView.contentSize = CGSizeMake(320.0, 450.0);
    
    [self.datePicker addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.datePicker setHidden:YES];
    
    [dateFormatter setDateFormat:@"dd. MM yyyy"];
    
    if (!self.veranstaltungZumBearbeiten) 
    {
        NSDate *ad = [NSDate dateWithTimeInterval:0 sinceDate:[dateFormatter dateFromString:self.anfangsdatum.detailTextLabel.text]] ;
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:ad];
        int wd = [components weekday];
        
        switch (wd) {
            case 1: //Sonntag
                [self.wochentag setSelectedSegmentIndex:6];
                break;
            case 2: //Montag
                [self.wochentag setSelectedSegmentIndex:0];
                break;
            case 3: //Dienstag
                [self.wochentag setSelectedSegmentIndex:1];
                break;
            case 4: //Mittwoch
                [self.wochentag setSelectedSegmentIndex:2];
                break;
            case 5: //Donnerstag
                [self.wochentag setSelectedSegmentIndex:3];
                break;
            case 6: //Freitag
                [self.wochentag setSelectedSegmentIndex:4];
                break;
            case 7: //Samstag
                [self.wochentag setSelectedSegmentIndex:5];
                break;
            default:
                break;
        }
    }
    else 
    {
        if ([self.veranstaltungZumBearbeiten.wochentag isEqualToString:@"Montag"]) 
        {
            [self.wochentag setSelectedSegmentIndex:0];
        }
        else if ([self.veranstaltungZumBearbeiten.wochentag isEqualToString:@"Dienstag"]) 
        {
            [self.wochentag setSelectedSegmentIndex:1];
        }
        else if ([self.veranstaltungZumBearbeiten.wochentag isEqualToString:@"Mittwoch"]) 
        {
            [self.wochentag setSelectedSegmentIndex:2];
        }
        else if ([self.veranstaltungZumBearbeiten.wochentag isEqualToString:@"Donnerstag"]) 
        {
            [self.wochentag setSelectedSegmentIndex:3];
        }
        else if ([self.veranstaltungZumBearbeiten.wochentag isEqualToString:@"Freitag"]) 
        {
            [self.wochentag setSelectedSegmentIndex:4];
        }
        else if ([self.veranstaltungZumBearbeiten.wochentag isEqualToString:@"Samstag"]) 
        {
            [self.wochentag setSelectedSegmentIndex:5];
        }
        else
        {
            [self.wochentag setSelectedSegmentIndex:0];
        }
    }
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (IBAction)dismissNewCourseViewController:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (self.titel.text.length > 0) {
        [self.fertigButton setEnabled:YES];
    }
    
    else {
        [self.fertigButton setEnabled:NO];
    }
}

#pragma mark - tableViewCellsTouched 

- (IBAction)anfangsDIsTouched:(id)sender
{
    self.enddatum.highlighted = NO;
    self.endzeit.highlighted = NO;
    self.anfangszeit.highlighted = NO;
    self.anfangsdatum.highlighted = YES;    
    self.scrollView.contentSize = CGSizeMake(320.0, 664.0);
    
    [self.scrollView setContentOffset:CGPointMake(0.0, 235.0) animated:YES];
    
    [self.datePicker setHidden:NO];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    
    NSString *dateAndTime = [NSString stringWithFormat:@"%@", self.anfangsdatum.detailTextLabel.text];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"de_DE"]];
    [dateFormatter setDateFormat:@"dd. MM yyyy"];
    NSDate *date = [dateFormatter dateFromString:dateAndTime];
    self.datePicker.date = [NSDate dateWithTimeInterval:0 sinceDate:date];
}

- (IBAction)anfangsZIsTouched:(id)sender
{
    self.enddatum.highlighted = NO;
    self.endzeit.highlighted = NO;
    self.anfangsdatum.highlighted = NO;
    self.anfangszeit.highlighted = YES;
    self.scrollView.contentSize = CGSizeMake(320.0, 664.0);
    [self.scrollView setContentOffset:CGPointMake(0.0, 235.0) animated:YES];
    
    [self.datePicker setHidden:NO];
    self.datePicker.datePickerMode = UIDatePickerModeTime;
    
    NSString *time = [NSString stringWithFormat:@"%@", self.anfangszeit.detailTextLabel.text];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"de_DE"]];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSDate *date = [dateFormatter dateFromString:time];
    self.datePicker.date = [NSDate dateWithTimeInterval:0 sinceDate:date];
}

- (IBAction)endzeitIsTouched:(id)sender
{
    self.enddatum.highlighted = NO;
    self.endzeit.highlighted = YES;
    self.anfangszeit.highlighted = NO;
    self.anfangsdatum.highlighted = NO;
    self.scrollView.contentSize = CGSizeMake(320.0, 664.0);
    [self.scrollView setContentOffset:CGPointMake(0.0, 235.0) animated:YES];
        
    [self.datePicker setHidden:NO];
    self.datePicker.datePickerMode = UIDatePickerModeTime;
    
    NSString *time = [NSString stringWithFormat:@"%@", self.endzeit.detailTextLabel.text];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"de_DE"]];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSDate *date = [dateFormatter dateFromString:time];
    self.datePicker.date = [NSDate dateWithTimeInterval:0 sinceDate:date];
}

- (IBAction)enddatumIsTouched:(id)sender
{
    self.enddatum.highlighted = YES;
    self.endzeit.highlighted = NO;
    self.anfangszeit.highlighted = NO;
    self.anfangsdatum.highlighted = NO;
    self.scrollView.contentSize = CGSizeMake(320.0, 664.0);
    [self.scrollView setContentOffset:CGPointMake(0.0, 235.0) animated:YES];
        
    [self.datePicker setHidden:NO];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    
    NSString *dateS = [NSString stringWithFormat:@"%@", self.enddatum.detailTextLabel.text];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"de_DE"]];
    [dateFormatter setDateFormat:@"dd. MM yyyy"];
    NSDate *date = [dateFormatter dateFromString:dateS];
    self.datePicker.date = [NSDate dateWithTimeInterval:0 sinceDate:date];
}

#pragma mark UIDatePicker value changed

- (void)valueChanged:(id)sender
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    if ([self.anfangsdatum isHighlighted]) 
    {
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [dateFormatter setDateStyle:NSDateFormatterLongStyle];
        [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"de_DE"]];
        
        [self.anfangsdatum.detailTextLabel setText:[NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:self.datePicker.date]]];
    }
    
    else if ([self.anfangszeit isHighlighted]) 
    {
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateStyle:NSDateFormatterNoStyle];
        [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"de_DE"]];
        
        [self.anfangszeit.detailTextLabel setText:[NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:self.datePicker.date]]];
    }
    
    else if ([self.endzeit isHighlighted]) 
    {
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateStyle:NSDateFormatterNoStyle];
        [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"de_DE"]];
        
        [self.endzeit.detailTextLabel setText:[NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:self.datePicker.date]]];
    }
    
    else if ([self.enddatum isHighlighted]) 
    {
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [dateFormatter setDateStyle:NSDateFormatterLongStyle];
        [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"de_DE"]];
        
        [self.enddatum.detailTextLabel setText:[NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:self.datePicker.date]]];
    }
}

- (IBAction)fertigButtonIsTouched:(id)sender 
{    
    NSArray *va = [NSArray arrayWithObjects:@"V", @"K", @"S", @"Ü", nil];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"de_DE"]];
    [dateFormatter setDateFormat:@"dd. MM yyyy"];
    
    NSDate *ad = [NSDate dateWithTimeInterval:0 sinceDate:[dateFormatter dateFromString:self.anfangsdatum.detailTextLabel.text]];
    NSDate *ed = [NSDate dateWithTimeInterval:0 sinceDate:[dateFormatter dateFromString:self.enddatum.detailTextLabel.text]];
    
    NSString *weekday;
    switch ([self.wochentag selectedSegmentIndex]) {
        case 0:
            weekday = @"Montag";
            break;
        case 1:
            weekday = @"Dienstag";
            break;
        case 2:
            weekday = @"Mittwoch";
            break;
        case 3:
            weekday = @"Donnerstag";
            break;
        case 4:
            weekday = @"Freitag";
            break;
        case 5:
            weekday = @"Samstag";
            break;
        default:
            weekday = @"Sonntag";
            break;
    }
    
    if (!self.veranstaltungZumBearbeiten) 
    {
        [Veranstaltung veranstaltungWithTitle:self.titel.text 
                                          ort:self.ort.text
                                          art:[va objectAtIndex:self.veranstaltungsart.selectedSegmentIndex]
                                    wochentag:weekday
                                 anfangsdatum:ad
                                  anfangszeit:self.anfangszeit.detailTextLabel.text 
                                     enddatum:ed
                                      endzeit:self.endzeit.detailTextLabel.text
                                    inContext:self.stundenplanDataManager.managedDocument.managedObjectContext];
        
        [self.stundenplanDataManager.managedDocument saveToURL:self.stundenplanDataManager.managedDocument.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success)
        {
            [self dismissModalViewControllerAnimated:YES];
        }];
    }
    else 
    {
        self.veranstaltungZumBearbeiten.titel = self.titel.text;
        self.veranstaltungZumBearbeiten.ort = self.ort.text;
        self.veranstaltungZumBearbeiten.veranstaltungsart = [va objectAtIndex:self.veranstaltungsart.selectedSegmentIndex];
        self.veranstaltungZumBearbeiten.wochentag = weekday;
        self.veranstaltungZumBearbeiten.anfangsdatum = ad;
        self.veranstaltungZumBearbeiten.anfangszeit = self.anfangszeit.detailTextLabel.text;
        self.veranstaltungZumBearbeiten.enddatum = ed;
        self.veranstaltungZumBearbeiten.endzeit = self.endzeit.detailTextLabel.text;
        
        [self.stundenplanDataManager save];
        [self dismissModalViewControllerAnimated:YES];
        
    }
    
}

@end