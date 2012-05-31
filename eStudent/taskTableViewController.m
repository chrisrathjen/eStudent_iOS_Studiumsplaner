//
//  taskTableViewController.m
//  eStudent
//
//  Created by Georg Scharsich on 14.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "taskTableViewController.h"
#import "Task.h"
#import "TasksTableViewCell.h"
#import "modifyTaskViewController.h"
#import "CategoriesViewController.h"
#import "CMPopTipView.h"

@interface taskTableViewController () <tasksDelegate, CMPopTipViewDelegate>
- (void)useDocument;
-(void)setupDataSource;

@property (strong, nonatomic) UIManagedDocument *document; //"Verbindung" zur Datenbank
@property (strong, nonatomic) NSArray *dataSource; //Array mit den Daten die in der Tabelle auftauchen
@property (strong, nonatomic) NSArray *sectionNames; //Katekorien
@property (strong, nonatomic) Task *theTask; //unnötig, glaube ich...
@property (strong, nonatomic) CMPopTipView *tipView;

@end

@implementation taskTableViewController

@synthesize document = _document;
@synthesize dataSource, sectionNames, theTask, tipView;


- (void)showPopTipView {
    NSLog(@"poptip");
    NSString *message = @"Hier werden alle Aufgaben angezeigt, die du anlegst. Du kannst Aufgaben entfernen, indem du von rechts nach links über die Aufgabe wischst";
    CMPopTipView *popTipView = [[CMPopTipView alloc] initWithMessage:message];
    popTipView.delegate = self;
    popTipView.backgroundColor = [UIColor colorWithRed:.01 green:.47 blue:.94 alpha:.9];
    [popTipView presentPointingAtView:self.navigationController.navigationBar inView:self.view animated:YES];
    self.tipView = popTipView;
}


//Dies ist die einzige Delegate Methode die implementiert werden muss. Hier koennte man zumbeispiel abspeichern das der User diese hilfe aktiv weggeklickt hat und sie nicht nur gesehen hat!
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView {
    self.tipView = nil;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"TaskTip"];
    [defaults synchronize];
}




//Diese MEthode wird aufgerufen falls ein KindView etwas an der Datenbank geändert hat und diese fertig aktualisiert wurde(geschieht das zu früh werden neue Daten nicht angezeigt)
#pragma mark - delegate
- (void)savingFinished
{
    NSLog(@"Starte tableView nach speichern");
    [self setupDataSource];
    
}

#pragma mark - DatabaseStuff
- (void) setDocument:(UIManagedDocument *)document
{
    if (_document != document){
        _document = document;
        [self useDocument];//Verbindet das Datenbank objekt (self.document) mit der Datenbank im Speicher
    }
}

//Erstellt die beiden Arrays die dann vom TableView angezeigt werden
-(void)setupDataSource
{
    NSLog(@"setup Datasource");
    NSMutableArray *data = [[NSMutableArray alloc]init];
    NSMutableArray *names = [[NSMutableArray alloc]init];

    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Task"];
    request.sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"duedate" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)], [NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:NO selector:@selector(localizedCaseInsensitiveCompare:)],nil];
    NSArray *allTasks = [self.document.managedObjectContext executeFetchRequest:request error:nil];
    NSMutableArray *tasksWithoutCat = [[NSMutableArray alloc] init];
    for (Task *aTask in allTasks) {
        if (!aTask.category)
        {
            [tasksWithoutCat addObject:aTask];
        }
    }
    
    
    request = [NSFetchRequest fetchRequestWithEntityName:@"TaskCategory"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    NSArray *allCats = [self.document.managedObjectContext executeFetchRequest:request error:nil];
    for (TaskCategory *aCategory in allCats) {
        if ([aCategory.tasks anyObject]){
            [data addObject:[aCategory.tasks allObjects]];
            [names addObject:aCategory.name];
        }
    }
    if ([tasksWithoutCat lastObject])
    {
        [data addObject:tasksWithoutCat];
        [names addObject:@"Keine Kategorie"];
    }
    
    self.sectionNames = [names copy];
    self.dataSource = [data copy];
    data = nil;
    names = nil;
    [self.tableView reloadData];
}

- (void)useDocument
{
    NSLog(@"Opening DatabaseConnection");
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.document.fileURL path]]) {
        NSLog(@"There is no Database pls create a Task");
        [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:[self.document.fileURL path]]) NSLog(@"there is now a Database stored");
        }];
    } else if (self.document.documentState == UIDocumentStateClosed) {
        [self.document openWithCompletionHandler:^(BOOL success) {
            NSLog(@"opened existing Database");
            [self setupDataSource];
        }];
    } else if (self.document.documentState == UIDocumentStateNormal) {
        NSLog(@"Database is already open");
        [self setupDataSource];
    } 
}

#pragma mark - ViewController lifecycle

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:NO];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:@"TaskTip"]){
        [self showPopTipView];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"modifyTasks"]){
        [segue.destinationViewController setDelegate:self];
        [segue.destinationViewController setDocument:self.document];
    }
    if ([segue.identifier isEqualToString:@"setCategorie"]){
        [segue.destinationViewController setDocument:self.document];
    }
    
    
    
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSURL *filePath = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    filePath = [filePath URLByAppendingPathComponent:@"Tasks"];
    self.document = [[UIManagedDocument alloc] initWithFileURL:filePath];
    
    //Background
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *backgroundImage = [userDefaults stringForKey:@"backgroundImage"];
    if (!backgroundImage) 
    {
        backgroundImage = @"background_1.jpg";
        [userDefaults setObject:backgroundImage forKey:@"backgroundImage"];
        [userDefaults synchronize];
    }
    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:backgroundImage]];
    self.tableView.backgroundView = image;
    
    //BackButtom for following viewcontrollers
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"OK";
    self.navigationItem.backBarButtonItem = barButton;
    self.navigationController.toolbar.tintColor = self.navigationController.navigationBar.tintColor;
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.tipView dismissAnimated:NO];
    [self.navigationController setToolbarHidden:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
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
    NSArray *tasks = [self.dataSource objectAtIndex:[indexPath section]];
    Task *aTask = [tasks objectAtIndex:[indexPath row]];
    static NSString *CellIdentifier = @"taskcell";
    TasksTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell) {
        cell.imageView.image = nil;
    }else {
        cell.imageView.image = nil;
    }
    if ([aTask.priority intValue] == 1) {
        cell.imageView.image = [UIImage imageNamed:@"highpriority.png"];
    }
    tasks = nil;
    cell.textLabel.text = aTask.name;
    if (aTask.duedate) {
        NSDate *aDate = [NSDate dateWithTimeIntervalSince1970:[aTask.duedate doubleValue]];
        NSDateFormatter *aDateFormatter = [[NSDateFormatter alloc] init];
        [aDateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"de_DE"]];
        [aDateFormatter setDateFormat:@"dd.MM.yyyy HH:mm"];
        cell.dateLabel.text = [aDateFormatter stringFromDate:aDate];
        
        NSDate *laterDate = [aDate laterDate:[NSDate date]];
        if (![laterDate isEqualToDate:aDate]){
            cell.imageView.image = [UIImage imageNamed:@"overdue.png"];
        }
        
    }else {
        cell.dateLabel.text = @"ohne Datum";
    }


    
    
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSArray *tasks = [self.dataSource objectAtIndex:[indexPath section]];
        [self.document.managedObjectContext deleteObject:[tasks objectAtIndex:[indexPath row]]];
        tasks = nil;
        [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
            NSLog(@"completing delete request");
        }];
        [self setupDataSource];
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *tasks = [self.dataSource objectAtIndex:[indexPath section]];
    modifyTaskViewController *aModifyTaskViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"modifyExistingTask"];
    aModifyTaskViewController.delegate = self;
    aModifyTaskViewController.document = self.document;
    aModifyTaskViewController.aTask = [tasks objectAtIndex:[indexPath row]];
    [self.navigationController pushViewController:aModifyTaskViewController animated:YES];
}

@end
