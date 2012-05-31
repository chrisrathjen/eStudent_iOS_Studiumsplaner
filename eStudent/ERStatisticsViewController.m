//
//  ERStatisticsViewController.m
//  eStudent
//
//  Created by Christian Rathjen on 29.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ERStatisticsViewController.h"
#import "CMPopTipView.h"
#import "Course_ER.h"
#import "Choosable.h"
#import "DetailViewController.h"
#import "ModifyCriterionViewController.h"
#import "Criterion.h"
#import <QuartzCore/QuartzCore.h>

@interface ERStatisticsViewController() <ERDataManagerDelegate, CMPopTipViewDelegate>
@property (nonatomic, strong)ERDataManager *dataManager;
@property (nonatomic, strong)CMPopTipView *myPopTipView;
@property (nonatomic, strong)NSDictionary *dataSource;
@property (nonatomic, strong)NSArray *sectionNames;
@end
@implementation ERStatisticsViewController 
@synthesize aProgressBar;
@synthesize aTableView;
@synthesize aLabel;
@synthesize dataManager, aRegulation;
@synthesize myPopTipView;
@synthesize dataSource, sectionNames;


//Die folgende Methode erstellt einen PopTipView und fuegt diesen zu einem anderem View hinzu. Hier ist das die progress anzeige. Hier kann aber jede beliebige sichtbare View angegeben werden.
//Noch zu beachten: Im interface angeben das man das CMPopTipViewDelegate protokoll implementiert (hier in Zeile 11).  Sowie die property fuer die CMPopTipView in Zeile 13 und 20.

//In viewDidAppear wird dieser Poptipview eingeblendet. Dies sollte man auch immer in dieser methode starten. Da in viewDidLoad die geometrischen eigenschaften einer View noch nicht geladen sind. Hier kann es also zu fehlern kommen. Also einfach immer in viewDidAppear aufrufen dann gibt es keinen stress!

- (void)showPopTipView {
    NSString *message = @"Hier kannst du deinen Studiumsfortschritt einsehen";
    CMPopTipView *popTipView = [[CMPopTipView alloc] initWithMessage:message];
    popTipView.delegate = self;//delegate setzen nicht vergessen damit wir bescheidbekommen wenn der user auf den tip klickt
    popTipView.backgroundColor = [UIColor colorWithRed:.01 green:.47 blue:.94 alpha:.9];
    [popTipView presentPointingAtView:self.aProgressBar inView:self.view animated:YES]; //inView ist immer die View in der der poptip auftauchen soll. Dies sollte eigendlich immer self.view sein
    self.myPopTipView = popTipView;
}


//Dies ist die einzige Delegate Methode die implementiert werden muss. Hier koennte man zumbeispiel abspeichern das der User diese hilfe aktiv weggeklickt hat und sie nicht nur gesehen hat!
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView {
    // User can tap CMPopTipView to dismiss it
    self.myPopTipView = nil;
    NSUserDefaults *defaults = [NSUserDefaults  standardUserDefaults];
    [defaults setBool:YES forKey:@"BPOStatsBar"];
    [defaults synchronize];

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self getTableViewData];
    NSUserDefaults *defaults = [NSUserDefaults  standardUserDefaults];
    if (![defaults boolForKey:@"BPOStatsBar"]) {
            [self showPopTipView]; 
    }
}
 - (void)viewWillAppear:(BOOL)animated
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *backgroundImage = [userDefaults stringForKey:@"backgroundImage"];
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:backgroundImage]];
    
    self.aLabel.layer.cornerRadius = 10.0;
    self.aLabel.layer.opacity = 0.7;
}

- (void)viewDidDisappear:(BOOL)animated{
    [self.myPopTipView dismissAnimated:NO]; //Ist der View in einem Nav Controller un kommt spaeter wieder onScreen so wird ein 2. poptip hinzugefuegt falls der alte nicht vorher dismissed wurde wie hier! Da wir hier schon offScreen sind muss es nicht animiert werden!
}

- (void)viewDidUnload {
    [self setALabel:nil];
    [self setDataManager:nil];
    [self setARegulation:nil];
    [self setAProgressBar:nil];
    [self setATableView:nil];
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    self.dataManager = [[ERDataManager alloc] init];
    self.dataManager.delegate = self;
    [self.dataManager accessDatabase];
}
// Statistics from the datamanager loaded
- (void)ERDocumentIsReady:(ERDataManager *)sender{
    [self getTableViewData];
}


#pragma mark - tableview delegate

- (void)getTableViewData
{
    NSMutableArray *passedCourses = [NSMutableArray array];
    NSMutableArray *awaitingCourses = [NSMutableArray array];
    NSMutableArray *awaitingCriterion = [NSMutableArray array];
    NSMutableArray *passedCriterion = [NSMutableArray array];
    //normaleCourses
    int accCP = 0;
    for (Category *aCategory in self.aRegulation.categories) {
        for (Course_ER *aCourse in aCategory.courses) {
            if ([aCourse.passed boolValue]) {
                [passedCourses addObject:aCourse];
                accCP += [aCourse.cp intValue];
            }else {
                [awaitingCourses addObject:aCourse];
            }
        }
        //If there is a Choosable with at least one passed course the passed cpourse is added to the passedArray. If no course is passed all of the choices are added to the awaitingArray
        for (Choosable *aChoosable in aCategory.hasChoice) {
            BOOL hasChoosen = NO;
            for (Course_ER *aCourse in aChoosable.choices) {
                if ([aCourse.passed boolValue]) {
                    hasChoosen = YES;
                    [passedCourses addObject:aCourse];
                    accCP += [aCourse.cp intValue];
                }
            }
            if (!hasChoosen) {
                for (Course_ER *aCourse in aChoosable.choices) {
                    [awaitingCourses addObject:aCourse];
                }
            }
            
        }
        for (Criterion *aCriterion in aCategory.criteria) {
            if (![aCriterion.passed boolValue]) {
                [awaitingCriterion addObject:aCriterion];
            }else {
                [passedCriterion addObject:aCriterion];
            }
        }
        
    }    
    
    self.aProgressBar.progress = accCP / [aRegulation.cp floatValue];
    self.aLabel.text = [NSString stringWithFormat:@"Sie haben %d CP von insgesamt %@ CP erreicht!", accCP,aRegulation.cp];
    
    
    [passedCourses sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]];
    [awaitingCourses sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]];
    [passedCriterion sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]];
    [awaitingCriterion sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]];

    NSMutableDictionary *aDataSource = [NSMutableDictionary dictionary];
    NSMutableArray *theSectionNames = [NSMutableArray array];
    
    if ([passedCourses count] > 0) {
        [aDataSource setObject:[passedCourses copy] forKey:@"Bestandene Kurse"];
        [theSectionNames addObject:@"Bestandene Kurse"];
    }
    if ([passedCriterion count] > 0) {
        [aDataSource setObject:[passedCriterion copy] forKey:@"Erfüllte Kriterien"];
        [theSectionNames addObject:@"Erfüllte Kriterien"];
    }
    if ([awaitingCriterion count] > 0) {
        [aDataSource setObject:[awaitingCriterion copy] forKey:@"Offene Kriterien"];
        [theSectionNames addObject:@"Offene Kriterien"];
    }
    if ([awaitingCourses count] > 0) {
        [aDataSource setObject:[awaitingCourses copy] forKey:@"Verbleibende Kurse"];
        [theSectionNames addObject:@"Verbleibende Kurse"];
    }
    
    self.dataSource = [aDataSource copy];
    self.sectionNames = [theSectionNames copy];
    
    [self.aTableView reloadData];
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.backgroundColor = [UIColor clearColor];
    
	//headerLabel.backgroundColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0.0];
	headerLabel.opaque = NO;
	headerLabel.textColor = [UIColor whiteColor];
    headerLabel.shadowColor = [UIColor blackColor];
	headerLabel.highlightedTextColor = [UIColor whiteColor];
	headerLabel.font = [UIFont boldSystemFontOfSize:18];
	headerLabel.frame = CGRectMake(10.0, 0.0, 300.0, 40.0);
    headerLabel.text = [self.sectionNames objectAtIndex:section];
    
    [headerView addSubview:headerLabel];
    return headerView;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sectionNames count];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.sectionNames objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.dataSource objectForKey:[self.sectionNames objectAtIndex:section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"statsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if ([[[self.dataSource objectForKey:[self.sectionNames objectAtIndex:[indexPath section]]] objectAtIndex:[indexPath row]] isKindOfClass:[Criterion class]]) {
        Criterion *aCriterion = [[self.dataSource objectForKey:[self.sectionNames objectAtIndex:[indexPath section]]] objectAtIndex:[indexPath row]];
        cell.textLabel.text = aCriterion.name;
    }
    if ([[[self.dataSource objectForKey:[self.sectionNames objectAtIndex:[indexPath section]]] objectAtIndex:[indexPath row]] isKindOfClass:[Course_ER class]]) {
        Course_ER *aCourse = [[self.dataSource objectForKey:[self.sectionNames objectAtIndex:[indexPath section]]] objectAtIndex:[indexPath row]];
        cell.textLabel.text = aCourse.name;
    }
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[[self.dataSource objectForKey:[self.sectionNames objectAtIndex:[indexPath section]]] objectAtIndex:[indexPath row]] isKindOfClass:[Course_ER class]]){
        DetailViewController *aDetailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"showCourse"];
        aDetailViewController.course = [[self.dataSource objectForKey:[self.sectionNames objectAtIndex:[indexPath section]]] objectAtIndex:[indexPath row]];
        [aDetailViewController setDataManager:self.dataManager];
        [self.navigationController pushViewController:aDetailViewController animated:YES];
    }
    if ([[[self.dataSource objectForKey:[self.sectionNames objectAtIndex:[indexPath section]]] objectAtIndex:[indexPath row]] isKindOfClass:[Criterion class]]){
        ModifyCriterionViewController *modifyVC = [self.storyboard instantiateViewControllerWithIdentifier:@"modifyCriterion"];
        modifyVC.aCriterion = [[self.dataSource objectForKey:[self.sectionNames objectAtIndex:[indexPath section]]] objectAtIndex:[indexPath row]];
        [modifyVC setADataManager:self.dataManager];
        [self.navigationController pushViewController:modifyVC animated:YES];
    }
    //modifyCriterion
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{

}


@end
