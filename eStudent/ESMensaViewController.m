//
//  ESMensaViewController.m
//  eStudent
//
//  Created by Nicolas Autzen on 21.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ESFlexibleView.h"
#import "ESMensaViewController.h"
#import "foodEntry.h"
#import <QuartzCore/QuartzCore.h> //muss importiert werden, damit man runde Ecken erzeugen kann
#import "CMPopTipView.h"

static NSUInteger kNumberOfPages = 5;

@interface ESMensaViewController() <CMPopTipViewDelegate>
@property (nonatomic, strong) CMPopTipView *mensaChooseTip;
@end

@implementation ESMensaViewController

@synthesize dataManager, dateLabel, scrollView, mensaTitle, activityIndicator, pageControl, currentPage, weekday, currentDate, mensaChooseTip, essensFarbenGesetzt, dateSchouldBeChanged;


- (void)showPopTipView {
    NSString *message = @"Hier kannst du zwischen den verfügbaren Mensen wechseln";
    CMPopTipView *popTipView = [[CMPopTipView alloc] initWithMessage:message];
    popTipView.delegate = self;//delegate setzen nicht vergessen damit wir bescheidbekommen wenn der user auf den tip klickt
    popTipView.backgroundColor = [UIColor colorWithRed:.01 green:.47 blue:.94 alpha:.9];
    [popTipView presentPointingAtBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES]; //inView ist immer die View in der der poptip auftauchen soll. Dies sollte eigendlich immer self.view sein
    self.mensaChooseTip = popTipView;
}

- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView {
// User can tap CMPopTipView to dismiss it
    self.mensaChooseTip = nil;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"chooseMensaTipDisabled"];
    [defaults synchronize];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //Fuer testzwecke zuruecksetzbar
    /*
    [defaults setBool:NO forKey:@"chooseMensaTipDisabled"];
    [defaults synchronize];
     */
    if (![defaults boolForKey:@"chooseMensaTipDisabled"]){
        [self showPopTipView];
    }
    defaults = nil;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (IS_IPHONE_5) {
        self.scrollView.frame = CGRectMake(0.0, 35.0, 320.0, 449.0);
        self.pageControl.frame = CGRectMake(self.pageControl.frame.origin.x, 475.0, self.pageControl.frame.size.width, self.pageControl.frame.size.height);
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //setzt das Background Image
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *backgroundImage = [defaults stringForKey:@"backgroundImage"];
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:backgroundImage]];
    self.essensFarbenGesetzt = [defaults boolForKey:@"essensFarben"];
    self.dateSchouldBeChanged = YES;

    NSDate *today = [NSDate date];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:today];
    self.weekday = [components weekday];
    self.currentDate = today;
    
    [self.activityIndicator startAnimating];
    
    if (![self isWeekend]) //prüft ob Wochenende ist, wenn nein werden die Essen geladen
    {           
        self.dataManager = [[MensaDataManager alloc] init];
        [self.dataManager setDelegate:self];
        
        //Lade default Mensa aus den UserDefaults und hole die aktuellen Daten für diese
        NSString *defaultMensa = @"uni";
        //Setze Default Mensa falls diese nicht gesetzt ist...
        if (![defaults objectForKey:@"defaultMensa"]) {
            [defaults setObject:defaultMensa forKey:@"defaultMensa"];
            [defaults synchronize];
        }
        defaultMensa = [defaults objectForKey:@"defaultMensa"];
        [self.dataManager getXMLDataFromServer:defaultMensa];
        if ([defaultMensa isEqualToString:@"uni"]) {
            [self.mensaTitle setTitle:@"Uni Boulevard"];
        } else if([defaultMensa isEqualToString:@"gw2"]) {
            [self.mensaTitle setTitle:@"GW2"];
        } else if([defaultMensa isEqualToString:@"air"]) {
            [self.mensaTitle setTitle:@"Airport"];
        }  else if([defaultMensa isEqualToString:@"bhv"]) {
            [self.mensaTitle setTitle:@"Bremerhaven"];
        } else if([defaultMensa isEqualToString:@"hsb"]) {
            [self.mensaTitle setTitle:@"Neustadtwall"];
        } else if([defaultMensa isEqualToString:@"wer"]) {
            [self.mensaTitle setTitle:@"Werderstraße"];
        } 
    }
    
    else {
        [self.activityIndicator removeFromSuperview];
        //hier das einfügen, was am Wochenende angezeigt werden soll
        self.dateLabel.text = @"";
        UILabel *weekend = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 20.0, 280.0, 70.0)];
        weekend.textAlignment = UITextAlignmentCenter;
        weekend.text = @"Wochenende";
        [weekend.layer setMasksToBounds:YES];
        weekend.layer.cornerRadius = 10.0;
        weekend.layer.opacity = .9;
        [self.scrollView addSubview:weekend];
        return;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - MensaDataManagerDelegate

- (void)noDataToParse:(MensaDataManager *)sender
{
    [self.activityIndicator removeFromSuperview];
    self.dateLabel.text = @"";
    self.scrollView.contentSize = self.scrollView.frame.size;
    self.scrollView.contentOffset = CGPointMake(0, 0);
    
    //hier das einfügen, was angezeigt werden soll, wenn keine Daten zum Parsen vorhanden sind
    self.dateLabel.text = @"";
    [self.scrollView setUserInteractionEnabled:NO];
    UITextView *noData = [[UITextView alloc] initWithFrame:CGRectMake(20.0, 20.0, 280.0, 110.0)];
    noData.text = @"\nEs liegen momentan keine Mensa-Daten vor, bitte versuche es zu einem späteren Zeitpunkt noch einmal.";
    noData.font = [UIFont fontWithName:@"Helvetica" size:15.0f];
    noData.textAlignment = UITextAlignmentCenter;
    [noData setScrollEnabled:NO];
    [noData setEditable:NO];
    [noData.layer setMasksToBounds:YES];
    noData.layer.cornerRadius = 10.0;
    noData.layer.opacity = .9;
    [self.scrollView addSubview:noData];
    return;
}
//wird aufgerufen, wenn keine Internetverbindung vorhanden ist
- (void)noNetworkConnection:(MensaDataManager *)sender localizedError:(NSString *)errorString
{
    [self.activityIndicator removeFromSuperview];
    self.dateLabel.text = @"";
    self.scrollView.contentSize = self.scrollView.frame.size;
    self.scrollView.contentOffset = CGPointMake(0, 0);
    
    //hier das einfügen, was angezeigt werden soll, wenn keine Daten zum Parsen vorhanden sind
    self.dateLabel.text = @"";
    [self.scrollView setUserInteractionEnabled:NO];
    
    UITextView *noNetworkConnection = [[UITextView alloc] initWithFrame:CGRectMake(20.0, 20.0, 280.0, 120.0)];
    noNetworkConnection.text = @"\nDie Verbindung zu unseren Servern ist fehlgeschlagen, bitte überprüfe deine Internetverbindung und versuche es dann noch einmal.";
    noNetworkConnection.font = [UIFont fontWithName:@"Helvetica" size:14.0f];
    noNetworkConnection.textAlignment = UITextAlignmentCenter;
    [noNetworkConnection setScrollEnabled:NO];
    [noNetworkConnection setEditable:NO];
    [noNetworkConnection.layer setMasksToBounds:YES];
    noNetworkConnection.layer.cornerRadius = 10.0;
    
    [self.scrollView addSubview:noNetworkConnection];
    return;
}

//Wird Aufgerufen wenn der MensaDatenManager bescheid gibt das der Datensatz zur Verfuegung steht!
- (void)mensaDataManager:(MensaDataManager *)sender loadedMenu:(NSMutableDictionary *)menu 
{
    NSArray *days = [[NSArray alloc] initWithObjects:@"Montag", @"Dienstag", @"Mittwoch", @"Donnerstag", @"Freitag", nil];
    self.dateLabel.text = [NSString stringWithFormat:@"%@, %@", [days objectAtIndex:self.weekday-2], [self date:self.currentDate]];
    [self.pageControl setNumberOfPages:kNumberOfPages];
    
    //setzt den View auf den richtigen Tag
    self.scrollView.delegate = nil;
    self.scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * kNumberOfPages, scrollView.frame.size.height);
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width * (self.weekday-2), 0)];
    [self.scrollView setUserInteractionEnabled:YES];
    self.pageControl.currentPage = self.weekday-2;
    self.currentPage = self.weekday-2;
    
    NSMutableString *day_;
    NSEnumerator *dayEnumerator = [menu keyEnumerator];
    while (day_ = [dayEnumerator nextObject])
    {
        int positionOnScreen = 0;
        if ([day_ isEqualToString:@"Monday"]){
            positionOnScreen = 0;
        } else if ([day_ isEqualToString:@"Tuesday"]){
            positionOnScreen = 1;
        } else if ([day_ isEqualToString:@"Wednesday"]){
            positionOnScreen = 2;
        } else if ([day_ isEqualToString:@"Thursday"]){
            positionOnScreen = 3;
        } else if ([day_ isEqualToString:@"Friday"]){
            positionOnScreen = 4;
        }
        
        NSMutableArray *meals = [[NSMutableArray alloc] init];
        
        NSMutableDictionary *menuOfTheDay = [menu objectForKey:day_];
        NSMutableString *meal;
        NSEnumerator *mealEnumerator = [menuOfTheDay keyEnumerator];
        while (meal = [mealEnumerator nextObject]) 
        {
            [meals addObject:[menuOfTheDay objectForKey:meal]];
        }
        
        NSSortDescriptor *order = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
        NSArray *sortedMeals = [meals sortedArrayUsingDescriptors:[NSArray arrayWithObject:order]];
        
        [self addMealsToView:sortedMeals atPosition:positionOnScreen];
        self.scrollView.delegate = self;
        [self.activityIndicator stopAnimating];
        [self.activityIndicator removeFromSuperview];
    }
}

- (void) addMealsToView:(id)meals atPosition:(int)positionOnScreen
{    
    if (positionOnScreen > kNumberOfPages || positionOnScreen < 0) 
    {
        return;
    }
    
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * (positionOnScreen) + 20.0;
    frame.origin.y = 5.0;
    frame.size.width -= 40.0;
    
    UIScrollView *mealsView = [[UIScrollView alloc] initWithFrame:frame];
    [mealsView setPagingEnabled:NO];
    [mealsView setScrollEnabled:YES];
    [mealsView setShowsVerticalScrollIndicator:NO];
    
    float mealPositionY = 0.0; //hier wird die Position des Essens angezeigt
    
    for (foodEntry *aFoodEntry in meals) 
    {
        NSString *foodType; //hier wird der Essenstyp gespeichert
        
        UIColor *backgroundColor = [UIColor whiteColor];
        
        switch ([aFoodEntry.type intValue]) 
        {
            case 86:
                foodType = @"Vegetarisch";
                if (!self.essensFarbenGesetzt) 
                {
                    backgroundColor = [UIColor colorWithRed:.81 green:1.0 blue:.694 alpha:1.0];
                }
                break;
            case 80:
                foodType = @"Vegan";
                if (!self.essensFarbenGesetzt) 
                {
                    backgroundColor = [UIColor colorWithRed:.588 green:.749 blue:.533 alpha:1.0];
                }
                break;
            case 87:
                foodType = @"Wild";
                if (!self.essensFarbenGesetzt) 
                {
                    backgroundColor = [UIColor colorWithRed:.909 green:.698 blue:.501 alpha:1.0];
                }                
                break;
            case 83:
                foodType = @"Schwein";
                if (!self.essensFarbenGesetzt) 
                {
                    backgroundColor = [UIColor colorWithRed:1.0 green:.87 blue:.862 alpha:1.0];
                }
                break;
            case 70:
                foodType = @"Fisch";
                if (!self.essensFarbenGesetzt) 
                {
                    backgroundColor = [UIColor colorWithRed:.898 green:.87 blue:.866 alpha:1.0];
                }
                break;
            case 82:
                foodType = @"Rind";
                if (!self.essensFarbenGesetzt) 
                {
                    backgroundColor = [UIColor colorWithRed:.749 green:.635 blue:.501 alpha:1.0];
                }
                break;
            case 71:
                foodType = @"Geflügel";
                if (!self.essensFarbenGesetzt) 
                {
                    backgroundColor = [UIColor colorWithRed:1.0 green:.874 blue:.592 alpha:1.0];
                }
                break;
            case 76:
                foodType = @"Lamm";
                break;
            default:
                foodType = @"Undefiniert";
                break;
        }
        
        NSString *extra; //gibt es etwas extra, wird es ebenfalls hinzugefügt
        switch ([aFoodEntry.extra intValue]) 
        {
            case 44:
                extra = @" + Dessert";
                break;
            case 84:
                extra = @" + Tagessuppe";
                break;
            default:
                extra = @"";
                break;
        }
        
        // ESFlexibleView erzeugt ein UIView-Objekt, bei dem die Höhe sich flexibel an den Inhalt anpassen lässt
        ESFlexibleView *foodEntry = [[ESFlexibleView alloc] initWithX:0.0 Y:mealPositionY andWidth:280.0];
        [foodEntry.layer setMasksToBounds:YES];
        foodEntry.layer.cornerRadius = 10.0; //hiermit werden runde Ecken erzeugt.
        foodEntry.layer.opacity = .9; //hier kann die Durchsichtigkeit der Essensanzeigen gesteuert werden
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 280.0, 40.0)];
        [label setText:[NSString stringWithFormat:@"   %@", aFoodEntry.name]];
        //label.textColor = [UIColor colorWithRed:.2 green:.2 blue:.8 alpha:1.0];
        label.backgroundColor = backgroundColor;
        label.font = [UIFont fontWithName:@"Helvetica-Bold" size:18.0f];
                
        UITextView *text = [[UITextView alloc] initWithFrame:CGRectMake(35.0, 40.0, 245.0, 0.0)];
        text.backgroundColor = backgroundColor;
        [text setText:[NSString stringWithFormat:@"%@ \n\n%@%@ \n\nStudenten: %@  Mitarbeiter: %@\n",aFoodEntry.foodDescription, foodType, extra ,aFoodEntry.studentPrice, aFoodEntry.staffPrice]];

        text.font = [UIFont fontWithName:@"Helvetica" size:14.0f];
        
        [text setScrollEnabled:NO];
        [text setEditable:NO];
        
        
        [foodEntry addSubview:label];
        [foodEntry addSubview:text];
        
        //der Teil passt die Höhe des TextViews an die Menge des Inhaltes an
        CGRect frame = text.frame;
        frame.size.height = [text contentSize].height;
        text.frame = frame;
        
        //dient nur als Einrückung des Textes auf der linken Seite (der dritte Parameter müsste für die breite angepasst werden, dementsprechend aber auch der dritte Parameter des Essenstextes)
        UITextView *textIndent = [[UITextView alloc] initWithFrame:CGRectMake(0.0, 40.0, (280.0 - text.contentSize.width), text.contentSize.height)];
        textIndent.scrollEnabled = NO;
        textIndent.editable = NO;
        textIndent.backgroundColor = backgroundColor;
        [foodEntry addSubview:textIndent];
        
        [foodEntry sizeToFit]; //sizeToFit skaliert die Höhe des Views auf die Höhe des gesamten Inhaltes
        
        //sorgt dafür, dass ein Essen wieder die korrekte Höhe hat, nachdem der Abstand an der linken Seite eingefügt wurde
        float height = foodEntry.frame.size.height - textIndent.frame.size.height;
        foodEntry.frame = CGRectMake(foodEntry.frame.origin.x, foodEntry.frame.origin.y, 280.0, height);
        
        [mealsView addSubview:foodEntry];
        mealPositionY += foodEntry.frame.size.height + 10.0;
    }
    [self.scrollView addSubview:mealsView];
    mealsView.contentSize = CGSizeMake(280.0, mealPositionY);
}

#pragma mark - choose mensa

- (IBAction) chooseMensa:(id)sender
{
    UIActionSheet *chooseMensa = [[UIActionSheet alloc] initWithTitle:@"Wähle Mensa" delegate:self cancelButtonTitle:@"Abbrechen" destructiveButtonTitle:nil otherButtonTitles:@"Uni Boulevard", @"GW2", @"Airport", @"Bremerhaven", @"Neustadtwall", @"Werderstraße", nil];
    [chooseMensa showFromBarButtonItem:sender animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{         
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *defaultMensa = [NSString stringWithString:[actionSheet buttonTitleAtIndex:buttonIndex]];
    if ([defaultMensa isEqualToString:@"Uni Boulevard"]) {
        [defaults setObject:@"uni" forKey:@"defaultMensa"];
        [self.mensaTitle setTitle:@"Uni Boulevard"];
    } else if([defaultMensa isEqualToString:@"GW2"]) {
        [defaults setObject:@"gw2" forKey:@"defaultMensa"];
        [self.mensaTitle setTitle:@"GW2"];
    } else if([defaultMensa isEqualToString:@"Airport"]) {
        [defaults setObject:@"air" forKey:@"defaultMensa"];
        [self.mensaTitle setTitle:@"Airport"];
    }  else if([defaultMensa isEqualToString:@"Bremerhaven"]) {
        [defaults setObject:@"bhv" forKey:@"defaultMensa"];
        [self.mensaTitle setTitle:@"Bremerhaven"];
    } else if([defaultMensa isEqualToString:@"Neustadtwall"]) {
        [defaults setObject:@"hsb" forKey:@"defaultMensa"];
        [self.mensaTitle setTitle:@"Neustadtwall"];
    } else if([defaultMensa isEqualToString:@"Werderstraße"]) {
        [defaults setObject:@"wer" forKey:@"defaultMensa"];
        [self.mensaTitle setTitle:@"Werderstraße"];
    } 
    [defaults synchronize];
    
    if (![self isWeekend])
    {        
        NSArray *subviews = [self.scrollView subviews];
        for (UIView *view in subviews ) {
            [view removeFromSuperview];
        }
        
        [self.pageControl setNumberOfPages:1];
        subviews = nil;
        self.currentDate = [NSDate date];
        self.dateSchouldBeChanged = NO;
        [self.scrollView addSubview:self.activityIndicator];
        [self.scrollView setContentOffset:CGPointMake(0, 0)];
        [self.dateLabel setText:@""];
        [self.activityIndicator startAnimating];
        
        self.dataManager = nil;
        self.dataManager = [[MensaDataManager alloc] init];
        self.dataManager.delegate = self;
        [self.dataManager getXMLDataFromServer:[defaults objectForKey:@"defaultMensa"]];
    }
}

#pragma mark - UIScrollViewDelegate

- (void) scrollViewDidScroll:(UIScrollView *)sender
{
    // prüft ob mehr als 50% der vorigen/nächsten Seite sichtbar sind und wechselt dann entsprechend
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    //will man ueber Freitag hinaus nach rechts scrollen, einfach beenden, sonst stuerzt das App ab.
    if (page >= kNumberOfPages) {
        return;
    }
    
    self.pageControl.currentPage = page;
    int tmp = self.currentPage;
    self.currentPage = page;
    
    if (tmp > self.currentPage) 
    {
        if (self.dateSchouldBeChanged)
        {
            //setzt das Datum einen Tag zurück
            self.currentDate = [NSDate dateWithTimeInterval:-86400 sinceDate:self.currentDate];
        }
        else
        {
            self.dateSchouldBeChanged = YES;
        }
    }
    else if (tmp < self.currentPage)
    {
        //setzt das Datum einen Tag weiter
        self.currentDate = [NSDate dateWithTimeInterval:86400 sinceDate:self.currentDate];
    }
    
    NSArray *days = [[NSArray alloc] initWithObjects:@"Montag", @"Dienstag", @"Mittwoch", @"Donnerstag", @"Freitag", nil];
    self.dateLabel.text = [NSString stringWithFormat:@"%@, %@", [days objectAtIndex:page], [self date:self.currentDate]];
}

#pragma mark - is Weekend

- (BOOL) isWeekend
{
    if (self.weekday > 1 && self.weekday < 7) // 1 und 7 steht für Sonntag und Samstag
    {
        return NO;
    }
    else 
    {
        return YES;
    }
}

#pragma mark - Formatting the date

- (NSString *) date:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"de_DE"]];
    
    return [dateFormatter stringFromDate:date];
}

#pragma mark - dealloc

- (void)dealloc
{
    self.dataManager.delegate = nil;
    self.scrollView.delegate = nil;
}

@end
