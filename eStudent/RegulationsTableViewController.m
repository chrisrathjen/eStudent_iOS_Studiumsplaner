//
//  RegulationsTableViewController.m
//  eStudent
//
//  Created by Christian Rathjen on 15.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "ERCategoryTableViewController.h"
#import "RegulationsTableViewController.h"
#import "ExamRegulations.h"
#import "CMPopTipView.h"

@interface RegulationsTableViewController() <ERDataManagerDelegate, CMPopTipViewDelegate>
@property (nonatomic, strong)CMPopTipView *importTipView;
@end

@implementation RegulationsTableViewController
@synthesize dataManager = _dataManager;
@synthesize addButtom;
@synthesize importTipView;
#pragma mark - CMPopTip delegate

- (void)showPopTipView {
    NSLog(@"poptip");
    NSString *message = @"Hier kannst du weitere Prüfungsordnungen importieren";
    CMPopTipView *popTipView = [[CMPopTipView alloc] initWithMessage:message];
    popTipView.delegate = self;
    popTipView.backgroundColor = [UIColor colorWithRed:.01 green:.47 blue:.94 alpha:.9];
    [popTipView presentPointingAtBarButtonItem:self.addButtom animated:YES];
    self.importTipView = popTipView;
}


//Dies ist die einzige Delegate Methode die implementiert werden muss. Hier koennte man zumbeispiel abspeichern das der User diese hilfe aktiv weggeklickt hat und sie nicht nur gesehen hat!
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView {
    self.importTipView = nil;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"BPOImportTip"];
    [defaults synchronize];
}


#pragma mark - NSFetchedResultController
-(void)setupFetchedResultController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ExamRegulations"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"subject" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.dataManager.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    NSLog(@"init fetched result controller");
}



#pragma mark - Datamanager delegate calls
- (void) ERDocumentIsReady:(ERDataManager *)sender
{
    [self setupFetchedResultController];
}

- (void) ERSavingComplete:(ERDataManager *)sender
{
    if (!self.fetchedResultsController) [self setupFetchedResultController];
}

- (void) ERNoDataStored:(ERDataManager *)sender
{
    NSLog(@"There is no Data to Display pls import some Regulations");
    
}

-(void)viewDidAppear:(BOOL)animated{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:@"BPOImportTip"]){
        [self showPopTipView];
    }
        [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];    
    NSLog(@"appeared");
    if (!self.dataManager){
        NSLog(@"starting datamanager and setting delegate");
        self.dataManager = [[ERDataManager alloc] init];
        self.dataManager.delegate = self;
        [self.dataManager accessDatabase];
        NSLog(@"kein stufff");
    }else {
        [self setupFetchedResultController];
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.importTipView removeFromSuperview];
    self.importTipView = nil;
}


#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ExamRegulationCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    ExamRegulations *aRegulation = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = aRegulation.subject;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ -  %@CP - FB%@ - %@", aRegulation.degree, aRegulation.cp, aRegulation.facultyNr, aRegulation.regulationdate];
    
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self.dataManager deleteRegulation:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    }
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    ExamRegulations *aRegulation = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([segue.destinationViewController respondsToSelector:@selector(setRegulation:)]){
        [segue.destinationViewController setRegulation:aRegulation];
        [segue.destinationViewController setDataManager:self.dataManager];
    }
     
}

- (void)viewDidUnload {
    [self setAddButtom:nil];
    [super viewDidUnload];
}
@end
