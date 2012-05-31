//
//  ESStundenplanViewController.m
//  eStudent
//
//  Created by Nicolas Autzen on 05.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ESStundenplanViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ESFlexibleView.h"
#import "Veranstaltung.h"
#import "ESStundenplanDataManager.h"

static NSUInteger kNumberOfPages = 3;
static BOOL viewReady = NO;

@implementation ESStundenplanViewController

@synthesize bearbeitenButton, heuteButton, toolbar, createCourseViewController, addButton, flexibleSpace, dateLabel, scrollview, weekday, weekdays, currentDate, currentPage, blocker, veranstaltungen, left, middle, right, activityIndicator, addCourseTip, veranstaltungZumBearbeiten, timer, stundenplanDataManager, isLeftBlocked, isMiddleBlocked, isRightBlocked, coursesReadyToDelete;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.weekdays = [NSArray arrayWithObjects:@"Sonntag", @"Montag", @"Dienstag", @"Mittwoch", @"Donnerstag", @"Freitag", @"Samstag", nil];
    
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *backgroundImage = [userDefaults stringForKey:@"backgroundImage"];
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:backgroundImage]];
    [self.navigationItem setLeftBarButtonItem:nil];
    viewReady = NO;
    [self setToday];
    
    self.isLeftBlocked = NO;
    self.isMiddleBlocked = NO;
    self.isRightBlocked = NO;
    
    //Fuer testzwecke zuruecksetzbar
    /*
     [userDefaults setBool:NO forKey:@"addCourseTipDisabled"];
     [userDefaults synchronize];
     */
    if (![userDefaults boolForKey:@"addCourseTipDisabled"]){
        [self showPopTipView];
    }
    userDefaults = nil;
    self.stundenplanDataManager = [[ESStundenplanDataManager alloc] init];
    self.stundenplanDataManager.delegate = self;
    
    self.scrollview.contentSize = CGSizeMake(scrollview.frame.size.width * 3, scrollview.frame.size.height);
    [self.scrollview setContentOffset:CGPointMake(320.0, 0)];
    [self.scrollview setScrollEnabled:NO];
    self.bearbeitenButton.enabled = NO;
    self.addButton.enabled = NO;
    self.heuteButton.enabled = NO;
    self.blocker = NO;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(setStundenplan) userInfo:nil repeats:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.middle addSubview:self.activityIndicator];

    if (!self.stundenplanDataManager.isDocumentReady) 
    {
        [self.stundenplanDataManager openDocument];
    }
    else 
    {
        [self getStundenplanData];
    }
    
    [self.navigationItem setRightBarButtonItem:self.bearbeitenButton animated:YES];
    self.veranstaltungZumBearbeiten = nil;
    [self.stundenplanDataManager save];
    
}

- (void)documentIsReady
{
    [self getStundenplanData];
}

#pragma mark - bearbeiten

- (IBAction)bearbeiten:(id)sender 
{
    NSMutableArray *middleSubviews = [self.middle.subviews mutableCopy];
    NSLog(@"anzahl an objekten: %i", middleSubviews.count);
    NSString *className = NSStringFromClass([[middleSubviews lastObject] class]);
    if ([className isEqualToString:@"UILabel"]) 
    {
        UIView *lastObject = [middleSubviews lastObject];
        [middleSubviews removeObject:lastObject];
        [lastObject removeFromSuperview];
    }
    
    UIBarButtonItem *abbrechenButton = [[UIBarButtonItem alloc] initWithTitle:@"Fertig" style:UIBarButtonItemStylePlain target:self action:@selector(abbrechen:)];
    [self.navigationItem setRightBarButtonItem:abbrechenButton animated:YES];
    [self.timer invalidate];
    self.scrollview.scrollEnabled = NO;
    
    float mainSize = 0.0;
    for (ESFlexibleView *v in middleSubviews) 
    {
        mainSize += v.frame.size.height +10;
        if (!v.unsichtbar) 
        {
            UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(veranstaltungBearbeiten:)];
            [v addGestureRecognizer:tgr];
            UIImageView *arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]];
            arrow.frame = CGRectMake(250.0, 14.0, 10.5, 14.0);
            [v addSubview:arrow];
            
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(10.3, (v.frame.size.height/2 - 18), 25.0, 25.0)];
            view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"visible_img.png"]];
            UITapGestureRecognizer *vrcn = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setVisibility:)];
            [view addGestureRecognizer:vrcn];
            [v addSubview:view];
        }
        else 
        {
            [v setHidden:NO];
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(9.4, (v.frame.size.height/2 - 18), 25.0, 25.0)];
            view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"invisible_img.png"]];
            UITapGestureRecognizer *vrcn = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setInvisibility:)];
            [view addGestureRecognizer:vrcn];
            [v addSubview:view];
        }
        
        UIView *viewD = [[UIView alloc] initWithFrame:CGRectMake(9.4, (v.frame.size.height/2 + 11), 24.0, 25.0)];
        viewD.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"delete_img.png"]];
        UITapGestureRecognizer *drcn = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteCourse:)];
        [viewD addGestureRecognizer:drcn];
        [v addSubview:viewD];
    }
    //ESFlexibleView *view = [middleSubviews lastObject];
    CGSize size = CGSizeMake(self.middle.frame.size.width, mainSize + 20.0);
    self.middle.contentSize = size;
    
    [self.addButton setEnabled:NO];
    [self.heuteButton setEnabled:NO];
}

- (void)setVisibility:(UITapGestureRecognizer *)sender
{
    sender.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"invisible_img.png"]];
    UITapGestureRecognizer *vrcn = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setInvisibility:)];
    [sender.view addGestureRecognizer:vrcn];
    
    NSArray *subviews = sender.view.superview.subviews;
    UITextView *text = (UITextView *)[subviews objectAtIndex:1];
    UILabel *label = (UILabel *)[subviews objectAtIndex:0];
    
    for (Veranstaltung *v in self.veranstaltungen) 
    {
        if ([[self.weekdays objectAtIndex:self.weekday-1] isEqualToString:v.wochentag]) 
        {
            if (([label.text isEqualToString:[NSString stringWithFormat:@"   %@ - %@ Uhr", v.anfangszeit, v.endzeit]]) 
                && (([text.text isEqualToString:[NSString stringWithFormat:@"%@ (%@)\n%@\n",v.titel, v.veranstaltungsart, v.ort]]) || ([text.text isEqualToString:[NSString stringWithFormat:@"%@ (%@)\n",v.titel, v.veranstaltungsart]])) )
            {
                if ((([[self normalizeDate:v.anfangsdatum] compare:[self normalizeDate:self.currentDate]] == NSOrderedAscending) || [[self normalizeDate:v.anfangsdatum] compare:[self normalizeDate:self.currentDate]] == NSOrderedSame) 
                    && (([[self normalizeDate:v.enddatum] compare:[self normalizeDate:self.currentDate]] == NSOrderedDescending)
                        || [[self normalizeDate:v.enddatum] compare:[self normalizeDate:self.currentDate]] == NSOrderedSame)) 
                {
                    v.hidden = [NSNumber numberWithBool:YES];
                    [self.stundenplanDataManager save];
                }
            }
        }
    }
}

- (void)setInvisibility:(UITapGestureRecognizer *)sender
{
    sender.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"visible_img.png"]];
    UITapGestureRecognizer *vrcn = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setVisibility:)];
    [sender.view addGestureRecognizer:vrcn];
    
    NSArray *subviews = sender.view.superview.subviews;
    UITextView *text = (UITextView *)[subviews objectAtIndex:1];
    UILabel *label = (UILabel *)[subviews objectAtIndex:0];
    
    for (Veranstaltung *v in self.veranstaltungen) 
    {
        if ([[self.weekdays objectAtIndex:self.weekday-1] isEqualToString:v.wochentag])
        {
            if (([label.text isEqualToString:[NSString stringWithFormat:@"   %@ - %@ Uhr", v.anfangszeit, v.endzeit]]) 
                && (([text.text isEqualToString:[NSString stringWithFormat:@"%@ (%@)\n%@\n",v.titel, v.veranstaltungsart, v.ort]]) || ([text.text isEqualToString:[NSString stringWithFormat:@"%@ (%@)\n",v.titel, v.veranstaltungsart]])) )
            {
                if ((([[self normalizeDate:v.anfangsdatum] compare:[self normalizeDate:self.currentDate]] == NSOrderedAscending) || [[self normalizeDate:v.anfangsdatum] compare:[self normalizeDate:self.currentDate]] == NSOrderedSame) 
                    && (([[self normalizeDate:v.enddatum] compare:[self normalizeDate:self.currentDate]] == NSOrderedDescending)
                    || [[self normalizeDate:v.enddatum] compare:[self normalizeDate:self.currentDate]] == NSOrderedSame)) 
                {
                    v.hidden = [NSNumber numberWithBool:NO];
                    [self.stundenplanDataManager save];
                }
            }
        }
    }
}

- (void)deleteCourse:(UITapGestureRecognizer *)sender
{
    sender.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"no_delete_img.png"]];
    UITapGestureRecognizer *udrcn = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(undeleteCourse:)];
    [sender.view addGestureRecognizer:udrcn];
    
    NSArray *subviews = sender.view.superview.subviews;
    [sender.view.superview removeGestureRecognizer:[sender.view.superview.gestureRecognizers objectAtIndex:0]];
    
    UITextView *text = (UITextView *)[subviews objectAtIndex:1];
    UILabel *label = (UILabel *)[subviews objectAtIndex:0];
    text.textColor = [UIColor whiteColor];
    label.textColor = [UIColor whiteColor];
    for (UIView *view in subviews) 
    {
        view.layer.opacity = .7;
    }
    
    label.backgroundColor = [UIColor colorWithRed:.8 green:.333 blue:.278 alpha:1.0];
    text.backgroundColor = [UIColor colorWithRed:.8 green:.333 blue:.278 alpha:1.0];
    
    UIView *tmp = [subviews objectAtIndex:2];
    tmp.backgroundColor = [UIColor colorWithRed:.8 green:.333 blue:.278 alpha:1.0];
    
    ESFlexibleView *fv = (ESFlexibleView *)sender.view.superview;
    UIView *rtmp = [subviews objectAtIndex:3];
    rtmp.hidden = YES;
    if (!fv.unsichtbar) 
    {
        rtmp = [subviews objectAtIndex:4];
        rtmp.hidden = YES;
    }
    fv.readyForDeletion = YES;
}

- (void)undeleteCourse:(UITapGestureRecognizer *)sender
{
    sender.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"delete_img.png"]];
    UITapGestureRecognizer *drcn = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteCourse:)];
    [sender.view addGestureRecognizer:drcn];
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(veranstaltungBearbeiten:)];
    [sender.view.superview addGestureRecognizer:tgr];
    
    NSArray *subviews = sender.view.superview.subviews;
    UITextView *text = (UITextView *)[subviews objectAtIndex:1];
    UILabel *label = (UILabel *)[subviews objectAtIndex:0];
    text.textColor = [UIColor blackColor];
    label.textColor = [UIColor blackColor];
    for (UIView *view in subviews) 
    {
        view.layer.opacity = 1.0;
    }
    
    label.backgroundColor = [UIColor whiteColor];
    text.backgroundColor = [UIColor whiteColor];
    
    UIView *tmp = [subviews objectAtIndex:2];
    tmp.backgroundColor = [UIColor whiteColor];
    
    ESFlexibleView *fv = (ESFlexibleView *)sender.view.superview;
    UIView *rtmp = [subviews objectAtIndex:3];
    rtmp.hidden = NO;
    if (!fv.unsichtbar) 
    {
        rtmp = [subviews objectAtIndex:4];
        rtmp.hidden = NO;
    }
    fv.readyForDeletion = NO;
}

- (void)veranstaltungBearbeiten:(UITapGestureRecognizer *)sender
{
    NSArray *subviews = sender.view.subviews;
    UITextView *text = (UITextView *)[subviews objectAtIndex:1];
    UILabel *label = (UILabel *)[subviews objectAtIndex:0];
    
    for (UIView *view in subviews) 
    {
        view.layer.opacity = .7;
    }
    
    for (Veranstaltung *v in self.veranstaltungen) 
    {
        if (([label.text isEqualToString:[NSString stringWithFormat:@"   %@ - %@ Uhr", v.anfangszeit, v.endzeit]]) 
            && (([text.text isEqualToString:[NSString stringWithFormat:@"%@ (%@)\n%@\n",v.titel, v.veranstaltungsart, v.ort]]) || ([text.text isEqualToString:[NSString stringWithFormat:@"%@ (%@)\n",v.titel, v.veranstaltungsart]])) )
        {
            if ((([[self normalizeDate:v.anfangsdatum] compare:[self normalizeDate:self.currentDate]] == NSOrderedAscending) || [[self normalizeDate:v.anfangsdatum] compare:[self normalizeDate:self.currentDate]] == NSOrderedSame) 
                && (([[self normalizeDate:v.enddatum] compare:[self normalizeDate:self.currentDate]] == NSOrderedDescending)
                    || [[self normalizeDate:v.enddatum] compare:[self normalizeDate:self.currentDate]] == NSOrderedSame)) 
            {
                
                self.veranstaltungZumBearbeiten = v;
                ESNewCourseViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"neueVeranstaltung"];
                vc.currentDate = self.currentDate;
                vc.stundenplanDataManager = self.stundenplanDataManager;
                vc.veranstaltungZumBearbeiten = self.veranstaltungZumBearbeiten;
                [self presentModalViewController:vc animated:YES];
            }
        }
    }
}

#pragma mark - viewcontroller button

- (IBAction)abbrechen:(id)sender
{
    [self.navigationItem setHidesBackButton:NO animated:YES];
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    [self.navigationItem setRightBarButtonItem:self.bearbeitenButton animated:YES];
    [self.toolbar setItems:[NSArray arrayWithObjects:self.heuteButton, self.flexibleSpace, self.addButton, nil] animated:YES];
    self.scrollview.scrollEnabled = YES;
    NSArray *subviews = self.middle.subviews;
    
    NSMutableArray *viewsForDeletion = [NSMutableArray array];
    
    for (ESFlexibleView *v in subviews) 
    {
        if (v.readyForDeletion) 
        {
            [viewsForDeletion addObject:v];
        }
        if (v.unsichtbar) 
        {
            [v setHidden:YES];
        }
        else 
        {
            [v removeGestureRecognizer:[v.gestureRecognizers lastObject]];
            [[v.subviews lastObject] removeFromSuperview];
            [[v.subviews lastObject] removeFromSuperview];
            v.layer.opacity = .9;
        }
    }
    
    if (viewsForDeletion.count > 0) 
    {
        self.coursesReadyToDelete = nil;
        self.coursesReadyToDelete = [NSMutableArray array];
        
        for (ESFlexibleView *ver in viewsForDeletion) 
        {   
            UITextView *text = (UITextView *)[ver.subviews objectAtIndex:1];
            UILabel *label = (UILabel *)[ver.subviews objectAtIndex:0];
            for (Veranstaltung *v in self.veranstaltungen) 
            {
                if (([label.text isEqualToString:[NSString stringWithFormat:@"   %@ - %@ Uhr", v.anfangszeit, v.endzeit]]) 
                    && (([text.text isEqualToString:[NSString stringWithFormat:@"%@ (%@)\n%@\n",v.titel, v.veranstaltungsart, v.ort]]) || ([text.text isEqualToString:[NSString stringWithFormat:@"%@ (%@)\n",v.titel, v.veranstaltungsart]])) )
                {
                    NSLog(@"%@ soll gelöscht werden", v.titel);
                    if ((([[self normalizeDate:v.anfangsdatum] compare:[self normalizeDate:self.currentDate]] == NSOrderedAscending) || [[self normalizeDate:v.anfangsdatum] compare:[self normalizeDate:self.currentDate]] == NSOrderedSame) 
                        && (([[self normalizeDate:v.enddatum] compare:[self normalizeDate:self.currentDate]] == NSOrderedDescending)
                            || [[self normalizeDate:v.enddatum] compare:[self normalizeDate:self.currentDate]] == NSOrderedSame)) 
                    {
                        [self.coursesReadyToDelete addObject:v];
                    }
                }
            }
        }
        NSLog(@"%d veranstaltungen sollen gelöscht werden", self.coursesReadyToDelete.count);
        UIActionSheet *deleteV = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"%d ausgewählte Veranstaltung(en)", self.coursesReadyToDelete.count] delegate:self cancelButtonTitle:@"Abbrechen" destructiveButtonTitle:@"Löschen" otherButtonTitles: nil];
        [deleteV showInView:self.view];
    }
    else 
    {
        [self.addButton setEnabled:YES];
        [self.heuteButton setEnabled:YES];
        self.veranstaltungZumBearbeiten = nil;
        [self setStundenplan];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(setStundenplan) userInfo:nil repeats:YES];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{         
    if (actionSheet.destructiveButtonIndex == buttonIndex) 
    {
        for (Veranstaltung *v in self.coursesReadyToDelete) 
        {
            [self.stundenplanDataManager.managedDocument.managedObjectContext deleteObject:v];
        }
        [self.stundenplanDataManager.managedDocument.managedObjectContext save:NULL];
    } 
    
    [self.addButton setEnabled:YES];
    [self.heuteButton setEnabled:YES];
    self.veranstaltungZumBearbeiten = nil;
    [self setStundenplan];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(setStundenplan) userInfo:nil repeats:YES];
}

- (IBAction)heuteButtonPressed:(id)sender
{
    [self setToday];
    self.dateLabel.text = [self date:self.currentDate];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"NeueVeranstaltung"])
    {
        [segue.destinationViewController setStundenplanDataManager:self.stundenplanDataManager];
        [segue.destinationViewController setCurrentDate:self.currentDate];
    }
}

- (void)getStundenplanData
{
    
    self.veranstaltungen = [self.stundenplanDataManager getAllVeranstaltungen];
    viewReady = YES;
    [self.scrollview setScrollEnabled:YES];
    self.blocker = YES;
    self.bearbeitenButton.enabled = YES;
    self.addButton.enabled = YES;
    self.heuteButton.enabled = YES;
    [self setStundenplan];
}

#pragma mark - UIScrollViewDelegate

- (void) scrollViewDidScroll:(UIScrollView *)sender
{        
    // prüft ob mehr als 50% der vorigen/nächsten Seite sichtbar sind und wechselt dann entsprechend
    CGFloat pageWidth = self.scrollview.frame.size.width;
    int page = floor((self.scrollview.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    //will man ueber Freitag hinaus nach rechts scrollen, einfach beenden, sonst stuerzt das App ab.
    if (page >= kNumberOfPages) {
        return;
    }
    
    int tmp = self.currentPage;
    self.currentPage = page;
    
    if (tmp > self.currentPage && self.blocker) 
    {
        //setzt das Datum einen Tag zurück - nach links gescrollt
        self.currentDate = [NSDate dateWithTimeInterval:-86400 sinceDate:self.currentDate];
        self.weekday--;
        if (self.weekday < 1) {
            self.weekday = 7;
        }
    }
    else if (tmp < self.currentPage && self.blocker)
    {
        //setzt das Datum einen Tag weiter - nach rechts gescrollt
        self.currentDate = [NSDate dateWithTimeInterval:86400 sinceDate:self.currentDate];
        self.weekday++;
        if (self.weekday > 7) {
            self.weekday = 1;
        }
    }
    
    self.dateLabel.text = [self date:self.currentDate];
    
    
    if (sender.contentOffset.x == 0.0) {
        self.blocker = NO;  
        for (UIView *v in self.right.subviews) 
        {
            [v removeFromSuperview];
        }
        for (UIView *v in self.middle.subviews) 
        {
            [self.right addSubview:v];
            self.right.contentSize = self.middle.contentSize;
        }
        for (UIView *v in self.left.subviews) 
        {
            [self.middle addSubview:v];
            self.middle.contentSize = self.left.contentSize;
        }
        self.isRightBlocked = YES;
        self.isMiddleBlocked = YES;
        [self setStundenplan];
        sender.contentOffset = CGPointMake(320.0, 0);
        if (![NSStringFromClass([[self.middle.subviews objectAtIndex:0] class]) isEqualToString:@"UILabel"]) 
        {
            self.bearbeitenButton.enabled = YES;
        }
        else 
        {
            self.bearbeitenButton.enabled = NO;
        }
        self.blocker = YES;
    }
    if (sender.contentOffset.x == 640.0) {
        self.blocker = NO;
        for (UIView *v in self.left.subviews) 
        {
            [v removeFromSuperview];
        }
        for (UIView *v in self.middle.subviews) 
        {
            [self.left addSubview:v];
            self.left.contentSize = self.middle.contentSize;
        }
        for (UIView *v in self.right.subviews) 
        {
            [self.middle addSubview:v];
            self.middle.contentSize = self.right.contentSize;
        }
        self.isLeftBlocked = YES;
        self.isMiddleBlocked = YES;
        [self setStundenplan];
        sender.contentOffset = CGPointMake(320.0, 0);
        if (![NSStringFromClass([[self.middle.subviews objectAtIndex:0] class]) isEqualToString:@"UILabel"]) 
        {
            self.bearbeitenButton.enabled = YES;
        }
        else 
        {
            self.bearbeitenButton.enabled = NO;
        }
        self.blocker = YES;
    }
}

- (void)setStundenplan
{
    NSMutableArray *heute = [[NSMutableArray alloc] init];
    NSMutableArray *gestern = [[NSMutableArray alloc] init];
    NSMutableArray *morgen = [[NSMutableArray alloc] init];
    
    int d1 = self.weekday-2;
    if (d1 < 0) {
        d1 = 6;
    }
    
    int d2 = self.weekday;
    if (d2 > 6) {
        d2 = 0;
    }
    NSDate *g = [NSDate dateWithTimeInterval:-86400 sinceDate:self.currentDate]; //gestern
    NSDate *m = [NSDate dateWithTimeInterval:86400 sinceDate:self.currentDate]; //morgen
    
    for (Veranstaltung *v in self.veranstaltungen) 
    {   
        if (!self.isMiddleBlocked && [v.wochentag isEqualToString:[self.weekdays objectAtIndex:self.weekday-1]]) 
        {
            if ((([[self normalizeDate:v.anfangsdatum] compare:[self normalizeDate:self.currentDate]] == NSOrderedAscending) || [[self normalizeDate:v.anfangsdatum] compare:[self normalizeDate:self.currentDate]] == NSOrderedSame) 
                && (([[self normalizeDate:v.enddatum] compare:[self normalizeDate:self.currentDate]] == NSOrderedDescending)
                || [[self normalizeDate:v.enddatum] compare:[self normalizeDate:self.currentDate]] == NSOrderedSame)) 
            {
                    
                [heute addObject:v];
            }
        }
        
        else if (!self.isLeftBlocked && [v.wochentag isEqualToString:[self.weekdays objectAtIndex:d1]]) 
        {
            if ((([[self normalizeDate:v.anfangsdatum] compare:[self normalizeDate:g]] == NSOrderedAscending) || [[self normalizeDate:v.anfangsdatum] compare:[self normalizeDate:g]] == NSOrderedSame) 
                && (([[self normalizeDate:v.enddatum] compare:[self normalizeDate:g]] == NSOrderedDescending)
                    || [[self normalizeDate:v.enddatum] compare:[self normalizeDate:g]] == NSOrderedSame)) 
            {
                    
                [gestern addObject:v];
            }
        }
        else if (!self.isRightBlocked && [v.wochentag isEqualToString:[self.weekdays objectAtIndex:d2]]) 
        {
            if ((([[self normalizeDate:v.anfangsdatum] compare:[self normalizeDate:m]] == NSOrderedAscending) || [[self normalizeDate:v.anfangsdatum] compare:[self normalizeDate:m]] == NSOrderedSame) 
                && (([[self normalizeDate:v.enddatum] compare:[self normalizeDate:m]] == NSOrderedDescending)
                    || [[self normalizeDate:v.enddatum] compare:[self normalizeDate:m]] == NSOrderedSame)) 
            {
                [morgen addObject:v];
            }
        }
    }
    if (!self.isMiddleBlocked) 
    {
        [self setVeranstaltungsAnzeige:self.middle mitDaten:heute];
    }
    if (!self.isLeftBlocked) 
    {
        [self setVeranstaltungsAnzeige:self.left mitDaten:gestern];
    }
    if (!self.isRightBlocked) 
    {
        [self setVeranstaltungsAnzeige:self.right mitDaten:morgen];
    }
    self.isLeftBlocked = NO;
    self.isMiddleBlocked = NO;
    self.isRightBlocked = NO;
    [self.middle setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
}

- (NSDate *)normalizeDate:(NSDate *)date
{
    unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:flags fromDate:date];
    return [calendar dateFromComponents:components];
}

- (void)setVeranstaltungsAnzeige:(UIScrollView *)position mitDaten:(NSMutableArray *)vs
{
    NSArray *subviews = position.subviews;
    for (UIView *s in subviews) {
        [s removeFromSuperview];
    }
    float vPositionY = 20.0; //hier wird die Position des Essens angezeigt
    
    if ([vs count] > 0) 
    {
        if (position == self.middle) 
        {
            [self.bearbeitenButton setEnabled:YES];
        } 
        int visibilityCounter = 0;
        for (Veranstaltung *v in vs) 
        {
            // ESFlexibleView erzeugt ein UIView-Objekt, bei dem die Höhe sich flexibel an den Inhalt anpassen lässt
            ESFlexibleView *veranstaltung = [[ESFlexibleView alloc] initWithX:0.0 Y:vPositionY andWidth:280.0];
            [veranstaltung.layer setMasksToBounds:YES];
            if ([v.hidden boolValue]) 
            {
                veranstaltung.layer.opacity = .6;
            }
            else 
            {
                veranstaltung.layer.opacity = .9; //hier kann die Durchsichtigkeit der Essensanzeigen gesteuert werden
                visibilityCounter++;
            }
            veranstaltung.layer.cornerRadius = 10.0; //hiermit werden runde Ecken erzeugt.
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 280.0, 40.0)];
            [label setText:[NSString stringWithFormat:@"   %@ - %@ Uhr", v.anfangszeit, v.endzeit]];
            //label.textColor = [UIColor colorWithRed:.2 green:.2 blue:.8 alpha:1.0];
            label.font = [UIFont fontWithName:@"Helvetica-Bold" size:18.0f];
            
            UITextView *text = [[UITextView alloc] initWithFrame:CGRectMake(35.0, 40.0, 245.0, 0.0)];
            if (v.ort) 
            {
                [text setText:[NSString stringWithFormat:@"%@ (%@)\n%@\n",v.titel, v.veranstaltungsart, v.ort]];
            }
            else 
            {
                [text setText:[NSString stringWithFormat:@"%@ (%@)\n",v.titel, v.veranstaltungsart]];
            }
            
            text.font = [UIFont fontWithName:@"Helvetica" size:14.0f];
            
            [text setScrollEnabled:NO];
            [text setEditable:NO];
            UIColor *bgColor = [UIColor colorWithRed:.01 green:.47 blue:.94 alpha:.9]; //Die Hintergrundfarbe für einen aktuellen Kurs
            UIColor *whiteColor = [UIColor whiteColor];
            if ([self isTheCourseRightNow:v]) 
            {
                label.backgroundColor = bgColor;
                label.textColor = whiteColor;
                text.backgroundColor = bgColor;
                text.textColor = whiteColor;
                veranstaltung.backgroundColor = bgColor;
            }
            
            [veranstaltung addSubview:label];
            [veranstaltung addSubview:text];
            
            //der Teil passt die Höhe des TextViews an die Menge des Inhaltes an
            CGRect frame = text.frame;
            frame.size.height = [text contentSize].height;
            text.frame = frame;
            
            //dient nur als Einrückung des Textes auf der linken Seite (der dritte Parameter müsste für die breite angepasst werden, dementsprechend aber auch der dritte Parameter des Essenstextes)
            UITextView *textIndent = [[UITextView alloc] initWithFrame:CGRectMake(0.0, 40.0, (280.0 - text.contentSize.width), text.contentSize.height)];
            textIndent.scrollEnabled = NO;
            textIndent.editable = NO;
            if ([self isTheCourseRightNow:v]) 
            {
                textIndent.backgroundColor = bgColor;
            }
            [veranstaltung addSubview:textIndent];
            
            [veranstaltung sizeToFit]; //sizeToFit skaliert die Höhe des Views auf die Höhe des gesamten Inhaltes
            
            //sorgt dafür, dass ein Essen wieder die korrekte Höhe hat, nachdem der Abstand an der linken Seite eingefügt wurde
            float height = veranstaltung.frame.size.height - textIndent.frame.size.height;
            veranstaltung.frame = CGRectMake(veranstaltung.frame.origin.x, veranstaltung.frame.origin.y, 280.0, height);
            if ([v.hidden boolValue]) 
            {
                veranstaltung.unsichtbar = YES;
                [veranstaltung setHidden:YES];
            }
            
            vPositionY += veranstaltung.frame.size.height + 10;
            [position addSubview:veranstaltung];
        }
        
        CGRect offsetFrame = CGRectMake(0, 0, 0, 0);
        
        float cSize = 0.0;
        if (visibilityCounter > 0) 
        {
            subviews = [position subviews];
            for (int i = 1; i < subviews.count; i++) 
            {
                ESFlexibleView *previousView = [subviews objectAtIndex:i-1];
                ESFlexibleView *view = [subviews objectAtIndex:i];
                int j = i-1;
                if (previousView.unsichtbar) 
                {
                    while (previousView.unsichtbar) 
                    {
                        if (!view.unsichtbar) 
                        {
                            CGRect pFrame = CGRectMake(previousView.frame.origin.x, previousView.frame.origin.y, 280.0, view.frame.size.height);
                            view.frame = pFrame;
                            offsetFrame = pFrame;
                        }
                        
                        j--;
                        if (j >= 0) 
                        {
                            previousView = [subviews objectAtIndex:j];
                        }
                        else 
                        {
                            break;
                        }
                    }
                }
                else 
                {
                    CGRect newFrame = CGRectMake(previousView.frame.origin.x, previousView.frame.origin.y + previousView.frame.size.height + 10.0, 280.0, view.frame.size.height);
                    view.frame = newFrame;
                    offsetFrame = newFrame;
                }
                if (!view.unsichtbar) 
                {
                    cSize = view.frame.origin.y + view.frame.size.height + 10.0;
                }
            }
            ESFlexibleView *lastView = [subviews lastObject];
            if (!lastView.unsichtbar) 
            {
                offsetFrame = CGRectMake(lastView.frame.origin.x, lastView.frame.origin.y + lastView.frame.size.height + 10.0, 280.0, lastView.frame.size.height);
            }
        }
        else 
        {
            UILabel *noCourses = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 20.0, 280.0, 70.0)];
            noCourses.textAlignment = UITextAlignmentCenter;
            noCourses.text = @"Alle Eintragungen ausgeblendet";
            [noCourses.layer setMasksToBounds:YES];
            noCourses.layer.cornerRadius = 10.0;
            noCourses.layer.opacity = .9;
            [position addSubview:noCourses];
        }
        
        if (offsetFrame.size.height > 0.0) 
        {
            subviews = [position subviews];
            for (ESFlexibleView *view in subviews) 
            {
                if (view.unsichtbar) 
                {
                    view.frame = CGRectMake(offsetFrame.origin.x, offsetFrame.origin.y, 280.0, view.frame.size.height);
                    offsetFrame = CGRectMake(offsetFrame.origin.x, offsetFrame.origin.y + view.frame.size.height+10, 280.0, view.frame.size.height);
                }
            }
        }
        
        if (cSize > 337.0) 
        {
            position.contentSize = CGSizeMake(280.0, cSize);
        }
        else 
        {
            position.contentSize = CGSizeMake(280.0, 337.0);
        }
    }
    
    else
    {
        if (position == self.middle) 
        {
            [self.bearbeitenButton setEnabled:NO];
        }
        // hier wird die Anzeige auf "Keine Veranstaltungen" gesetzt, wenn keine Veranstaltungen an dem Tag sind
        UILabel *noCourses = [[UILabel alloc] initWithFrame:CGRectMake(0.0, vPositionY, 280.0, 70.0)];
        noCourses.textAlignment = UITextAlignmentCenter;
        noCourses.text = @"Keine Eintragungen heute";
        [noCourses.layer setMasksToBounds:YES];
        noCourses.layer.cornerRadius = 10.0;
        noCourses.layer.opacity = .9;
        [position addSubview:noCourses];
        position.contentSize = CGSizeMake(280.0, 337.0);
        return;
    }
    
}

- (BOOL)isTheCourseRightNow:(Veranstaltung *)v
{
    if (![v.hidden boolValue]) 
    {
        NSDate *today = [NSDate date];
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:today];
        int wd = [components weekday];
        
        NSDate *yesterday = [NSDate dateWithTimeInterval:-86400 sinceDate:self.currentDate];
        NSDate *tomorrow = [NSDate dateWithTimeInterval:86400 sinceDate:self.currentDate];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateStyle:NSDateFormatterNoStyle];
        [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"de_DE"]];
        
        if (([[self normalizeDate:self.currentDate] compare:[self normalizeDate:today]] == NSOrderedSame) ||
            ([[self normalizeDate:tomorrow] compare:[self normalizeDate:today]] == NSOrderedSame) ||
            ([[self normalizeDate:yesterday] compare:[self normalizeDate:today]] == NSOrderedSame))
        {
            if ([v.wochentag isEqualToString:[self.weekdays objectAtIndex:wd-1]]) 
            {
                if (([v.anfangszeit compare:[dateFormatter stringFromDate:today]] == NSOrderedAscending || 
                     [v.anfangszeit compare:[dateFormatter stringFromDate:today]] == NSOrderedSame) && 
                    ([v.endzeit compare:[dateFormatter stringFromDate:today]] == NSOrderedDescending)) 
                {
                    return YES;
                }
            }
        }
        return NO;
    }   
    return NO;
}

- (NSString *) date:(NSDate *)date
{    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"de_DE"]];
    
    return [NSString stringWithFormat:@"◁ %@, %@ ▷", [self.weekdays objectAtIndex:self.weekday-1], [dateFormatter stringFromDate:date]];
}

- (void)setToday
{
    NSDate *today = [NSDate date];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:today];
    self.weekday = [components weekday];
    self.currentDate = today;
    self.currentPage = 1;
    if (viewReady) 
    {
        [self setStundenplan];
    }
}

#pragma mark - CMPopTipViewDelegate

- (void)showPopTipView
{
    NSString *message = @"Hier kannst du manuell eine Veranstaltung anlegen";
    CMPopTipView *popTipView = [[CMPopTipView alloc] initWithMessage:message];
    popTipView.delegate = self;//delegate setzen nicht vergessen damit wir bescheidbekommen wenn der user auf den tip klickt
    popTipView.backgroundColor = [UIColor colorWithRed:.01 green:.47 blue:.94 alpha:.9];
    [popTipView presentPointingAtBarButtonItem:self.addButton animated:YES]; //inView ist immer die View in der der poptip auftauchen soll. Dies sollte eigendlich immer self.view sein
    self.addCourseTip = popTipView;
}

- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView 
{
    // User can tap CMPopTipView to dismiss it
    self.addCourseTip = nil;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"addCourseTipDisabled"];
    [defaults synchronize];
}

@end
