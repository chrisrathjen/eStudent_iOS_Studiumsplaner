//
//  ERCoursesTableViewController.m
//  eStudent
//
//  Created by Christian Rathjen on 15.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ERCoursesTableViewController.h"
#import "DetailViewController.h"
#import "ModifyCriterionViewController.h"
#import "SelectCourseForOptionalViewController.h"
#import "CategorieListing.h"
#import "Course_ER.h"
#import "Criterion.h"
#import "Choosable.h"
#import "Optional.h"
#import "CMPopTipView.h"

@interface ERCoursesTableViewController() <CMPopTipViewDelegate, SelectCoursesDelegate>
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSMutableArray *sectionNames;
@property (nonatomic, strong)CMPopTipView *editTipView;

@end

@implementation ERCoursesTableViewController
@synthesize dataManager, category, dataSource, sectionNames, editTipView;



- (void)showPopTipView {
    NSLog(@"poptip");
    NSString *message = @"Im Bearbeiten-Modus kannst du mehrere Kurse aufeinmal in andere Kategorien sortieren oder löschen";
    CMPopTipView *popTipView = [[CMPopTipView alloc] initWithMessage:message];
    popTipView.delegate = self;
    popTipView.backgroundColor = [UIColor colorWithRed:.01 green:.47 blue:.94 alpha:.9];
    [popTipView presentPointingAtBarButtonItem:self.editButtonItem animated:YES];
    self.editTipView = popTipView;
}


//Dies ist die einzige Delegate Methode die implementiert werden muss. Hier koennte man zumbeispiel abspeichern das der User diese hilfe aktiv weggeklickt hat und sie nicht nur gesehen hat!
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView {
    self.editTipView = nil;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"BPOEditMode"];
    [defaults synchronize];
}



#pragma mark - Compile Data

- (void)setupDataSource
{
    NSMutableArray *content = [[NSMutableArray alloc] init];
    NSMutableArray *names = [[NSMutableArray alloc]init];
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    if ([self.category.courses count] > 0 ) {
        NSArray *array = [NSArray arrayWithArray:[self.category.courses sortedArrayUsingDescriptors:sortDescriptors]];
        [content addObject:[array copy]];
        [names addObject:@"Kurse"];
    }
    if ([self.category.hasChoice count] > 0 ) {
        for (Choosable *aChoice in [self.category.hasChoice sortedArrayUsingDescriptors:sortDescriptors]) {
            NSArray *array = [NSArray arrayWithArray:[aChoice.choices sortedArrayUsingDescriptors:sortDescriptors]];
            [content addObject:[array copy]];
            NSString *aString = [NSString stringWithFormat:@"Auswahlmöglichkeit - %@CP in %@ Semestern - %@", aChoice.cp, aChoice.duration, aChoice.name];
            [names addObject:aString];
        }
    }
    if ([self.category.criteria count] > 0) {
        NSArray *array = [NSArray arrayWithArray:[self.category.criteria sortedArrayUsingDescriptors:sortDescriptors]];
        [content addObject:[array copy]];
        [names addObject:@"Kriterien"];
    }
    if ([self.category.optional count] > 0) {
        NSArray *array = [NSArray arrayWithArray:[self.category.optional sortedArrayUsingDescriptors:sortDescriptors]];
        [content addObject:[array copy]];
        [names addObject:@"Wahlpflicht"];
    }
    
    self.dataSource = content;
    self.sectionNames = names;
    [self.tableView reloadData];
}


#pragma mark - View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[userDefaults stringForKey:@"backgroundImage"]]];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView setAllowsMultipleSelectionDuringEditing:YES];



    UIBarButtonItem *moveBtm = [[UIBarButtonItem alloc] initWithTitle:@"Verschieben" style:UIBarButtonItemStyleBordered target:self action:@selector(moveCourses:)];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *addBtm = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addCourse:)];
    addBtm.style = UIBarButtonItemStyleBordered;
    UIBarButtonItem *deleteBtm = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteSelectedCourses:)];
    deleteBtm.style = UIBarButtonItemStyleBordered;
    UIBarButtonItem *passBtm = [[UIBarButtonItem alloc] initWithTitle:@"Bestanden" style:UIBarButtonItemStyleBordered target:self action:@selector(passCourses:)];
    self.toolbarItems = [NSArray arrayWithObjects:moveBtm, passBtm,flexSpace, addBtm,deleteBtm, nil];
    self.navigationController.toolbar.tintColor = self.navigationController.navigationBar.tintColor;
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.title = self.category.name;
    [self setupDataSource];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:@"BPOEditMode"]) {
        [self showPopTipView];
    }
    self.navigationController.toolbarHidden = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.editTipView removeFromSuperview];
    self.editTipView = nil;
    self.navigationController.toolbarHidden = YES;
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    if (editing) {
        self.navigationController.toolbarHidden = NO;
    }else {
        self.navigationController.toolbarHidden = YES;
    }
}


#pragma mark - Table view data source

// Da die default Sectionsbezeicher nicht schoen mit unseren Hintergruenden funktionieren werden hier eigene headerViews erstellt.
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
    headerLabel.numberOfLines = 3;
    
    [headerView addSubview:headerLabel];
    
    return headerView;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataSource count];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.sectionNames objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.dataSource objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CourseCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    id rowContent = [[self.dataSource objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
    if ([rowContent isKindOfClass:[Course_ER class]]) {
        Course_ER *rowCourse = rowContent;
        cell.textLabel.text = rowCourse.name;
        cell.detailTextLabel.text = rowCourse.vak;
        if (rowCourse.passed == [NSNumber numberWithInt:1]){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    if ([rowContent isKindOfClass:[Criterion class]]) {
        Criterion *rowCriteron = rowContent;
        cell.textLabel.text = rowCriteron.name;
        cell.detailTextLabel.text = rowCriteron.note;
        cell.userInteractionEnabled = YES;
        if ([rowCriteron.passed boolValue]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    if ([rowContent isKindOfClass:[Optional class]]) {
        Optional *anOptional = rowContent;
        cell.userInteractionEnabled = YES;
        int cp = 0;
        for (Course_ER *aCourse in anOptional.courses) {
            if ([aCourse.passed boolValue]) {
                cp += [aCourse.cp intValue];
            }
        }
        cell.textLabel.text = [NSString stringWithFormat:@"%d/%@CP erreicht in %@", cp, anOptional.cp, anOptional.vak];
        cell.detailTextLabel.text = anOptional.name;
    }
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.tableView.editing) {
        if ([[[self.dataSource objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]] isKindOfClass:[Course_ER class]]) {
            Course_ER *aCourse = [[self.dataSource objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
            DetailViewController *detailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"showCourse"];
            detailVC.dataManager = self.dataManager;
            detailVC.course = aCourse;
            [self.navigationController pushViewController:detailVC animated:YES];
        }
        if ([[[self.dataSource objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]] isKindOfClass:[Criterion class]]) {
            Criterion *aCriterion = [[self.dataSource objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
            ModifyCriterionViewController *modifyVC = [self.storyboard instantiateViewControllerWithIdentifier:@"modifyCriterion"];
            modifyVC.aDataManager = self.dataManager;
            modifyVC.aCriterion = aCriterion;
            [self.navigationController pushViewController:modifyVC animated:YES];
        }
        if ([[[self.dataSource objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]] isKindOfClass:[Optional class]]) {
            Optional *anOpional = [[self.dataSource objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
            SelectCourseForOptionalViewController *selectCourseVC = [self.storyboard instantiateViewControllerWithIdentifier:@"selectCoursesForAnOptional"];
            selectCourseVC.delegate = self;
            selectCourseVC.anOptional = anOpional;
            NSMutableArray *courses = [[self.category.courses allObjects] mutableCopy];
            for (Course_ER *aCourse in [courses copy]) {
                if ([anOpional.courses containsObject:aCourse]) {
                    [courses removeObject:aCourse];
                }
            }
            selectCourseVC.courses = [courses copy];
            [self.navigationController pushViewController:selectCourseVC animated:YES];
            
        }
    }
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        if ([[[self.dataSource objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]] isKindOfClass:[Course_ER class]]) {
            Course_ER *aCourse = [[self.dataSource objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
            [self.dataManager.document.managedObjectContext deleteObject:aCourse];
        }
        if ([[[self.dataSource objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]] isKindOfClass:[Criterion class]]) {
            Criterion *aCriterion = [[self.dataSource objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
            [self.dataManager.document.managedObjectContext deleteObject:aCriterion];
        }
        [self.dataManager.document saveToURL:self.dataManager.document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL succes){
            [self  setupDataSource];
        }];
    }
}


#pragma mark - segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"newCourse"]){
        [segue.destinationViewController setDataManager:self.dataManager];
        Course_ER *aCourse = [Course_ER courseWithParsedData:nil withDuration:nil name:nil necCP:nil vakNumber:nil inCategory:self.category isChoosbale:nil inManagedContext:self.dataManager.document.managedObjectContext];
        [segue.destinationViewController setCourse:aCourse];
    }

}

- (void)viewDidUnload {
    [super viewDidUnload];
}


#pragma mark - SelectedCoursesForOptionalDelegate

- (void)selectedCourse:(Course_ER *)aCourse inOptional:(Optional *)anOptional
{
    NSMutableSet *currentCourses = [anOptional.courses mutableCopy];
    [currentCourses addObject:aCourse];
    anOptional.courses = [currentCourses copy];
    [self.dataManager.document saveToURL:self.dataManager.document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
        if (success) {
            NSLog(@"added Course to Optional");
            [self setupDataSource];
        }  
    }];
}

- (void)removeCourse:(Course_ER *)aCourse fromOptional:(Optional *)anOptional
{
    NSMutableSet *currentCourses = [anOptional.courses mutableCopy];
    [currentCourses removeObject:aCourse];
    anOptional.courses = [currentCourses copy];
    [self.dataManager.document saveToURL:self.dataManager.document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
        if (success) {
            NSLog(@"Course removed from Optional");
            [self setupDataSource];
        }  
    }];
}

#pragma mark - actions

- (IBAction)moveCourses:(id)sender {
    NSArray *PathsToMove = [self.tableView indexPathsForSelectedRows];
    NSMutableArray *objectsToMove = [NSMutableArray array];
    for (NSIndexPath *aPath in PathsToMove) {
        if ([[[self.dataSource objectAtIndex:[aPath section]] objectAtIndex:[aPath row]] isKindOfClass:[Course_ER class]]) {
            [objectsToMove addObject:[[self.dataSource objectAtIndex:[aPath section]] objectAtIndex:[aPath row]]];
        }
        if ([[[self.dataSource objectAtIndex:[aPath section]] objectAtIndex:[aPath row]] isKindOfClass:[Criterion class]]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warnung" message:@"Wahlpflichten und Auswahlen können nicht verschoben werden" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [objectsToMove addObject:[[self.dataSource objectAtIndex:[aPath section]] objectAtIndex:[aPath row]]];
        }
        if ([[[self.dataSource objectAtIndex:[aPath section]] objectAtIndex:[aPath row]] isKindOfClass:[Optional class]]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warnung" message:@"Wahlpflichten und Auswahlen können nicht verschoben werden" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }

    }
    NSSet *allCategories = self.category.examReg.categories;
    CategorieListing *aCatListingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"showCatsToMove"];
    aCatListingVC.dataManager = self.dataManager;
    aCatListingVC.objectsToMove = objectsToMove;
    aCatListingVC.dataSource = [[allCategories allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]];
    [self setEditing:NO animated:NO];
    if ([objectsToMove count]> 0) {
        [self.navigationController pushViewController:aCatListingVC animated:YES];

    }

        
    
}

- (IBAction)deleteSelectedCourses:(id)sender {
    NSLog(@"loesche stuff");
    NSArray *coursesToDelete = [self.tableView indexPathsForSelectedRows];
    for (NSIndexPath *aPath in coursesToDelete) {
        if ([[[self.dataSource objectAtIndex:[aPath section]] objectAtIndex:[aPath row]] isKindOfClass:[Course_ER class]]) {
            Course_ER *aCourse = [[self.dataSource objectAtIndex:[aPath section]] objectAtIndex:[aPath row]];
            [self.dataManager.document.managedObjectContext deleteObject:aCourse];
        }
        if ([[[self.dataSource objectAtIndex:[aPath section]] objectAtIndex:[aPath row]] isKindOfClass:[Optional class]]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warnung" message:@"Wahlpflichten können nicht gelöscht werden" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
    
    
    
    [self.dataManager.document saveToURL:self.dataManager.document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL succes){
        [self  setupDataSource];
    }];
}

- (IBAction)addCourse:(id)sender
{
    DetailViewController *aDeatailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"showCourse"];
    aDeatailVC.dataManager =  self.dataManager;
    Course_ER *aCourse = [Course_ER courseWithParsedData:nil withDuration:nil name:nil necCP:nil vakNumber:nil inCategory:self.category isChoosbale:nil inManagedContext:self.dataManager.document.managedObjectContext];
    [aDeatailVC setCourse:aCourse];
    [self.navigationController pushViewController:aDeatailVC animated:YES];
}

- (IBAction)passCourses:(id)sender
{
    NSLog(@"loesche stuff");
    NSArray *coursesToDelete = [self.tableView indexPathsForSelectedRows];
    for (NSIndexPath *aPath in coursesToDelete) {
        if ([[[self.dataSource objectAtIndex:[aPath section]] objectAtIndex:[aPath row]] isKindOfClass:[Course_ER class]]) {
            Course_ER *aCourse = [[self.dataSource objectAtIndex:[aPath section]] objectAtIndex:[aPath row]];
            aCourse.passed = [NSNumber numberWithBool:YES];
        }
        if ([[[self.dataSource objectAtIndex:[aPath section]] objectAtIndex:[aPath row]] isKindOfClass:[Criterion class]]) {
            Criterion *aCriterion = [[self.dataSource objectAtIndex:[aPath section]] objectAtIndex:[aPath row]];
            aCriterion.passed = [NSNumber numberWithBool:YES];
        }
    }
    [self.dataManager.document saveToURL:self.dataManager.document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
        if (success) {
            NSLog(@"changed Courses to passed");
            [self setupDataSource];
            self.editing = NO;
        }
    }];
}
@end
