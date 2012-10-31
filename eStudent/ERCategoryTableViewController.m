//
//  ERCategoryTableViewController.m
//  eStudent
//
//  Created by Christian Rathjen on 15.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ERCategoryTableViewController.h"
#import "Category.h"
#import "Optional.h"
#import "Course_ER.h"
#import "Choosable.h"
#import "ERCoursesTableViewController.h"
#import "ERStatisticsViewController.h"
#import "CMPopTipView.h"
#import "NewCategorieViewController.h"

@interface ERCategoryTableViewController() <CMPopTipViewDelegate, ERDataManagerDelegate>
@property (nonatomic, strong) CMPopTipView *statsTipView;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSArray *sectionNames;
@end

@implementation ERCategoryTableViewController

@synthesize Regulation = _Regulation;
@synthesize dataManager = _dataManager;
@synthesize statsButtom = _statsButtom;
@synthesize statsTipView, dataSource, sectionNames;

- (void)ERSavingComplete:(ERDataManager *)sender
{
    [self setupDataSource];
}

- (void)showPopTipView {
    NSLog(@"poptip");
    NSString *message = @"Hier erhältst du eine Übersicht über deine Kurse und Pflichten";
    CMPopTipView *popTipView = [[CMPopTipView alloc] initWithMessage:message];
    popTipView.delegate = self;
    popTipView.backgroundColor = [UIColor colorWithRed:.01 green:.47 blue:.94 alpha:.9];
    [popTipView presentPointingAtBarButtonItem:self.statsButtom animated:YES];
    self.statsTipView = popTipView;
}


//Dies ist die einzige Delegate Methode die implementiert werden muss. Hier koennte man zumbeispiel abspeichern das der User diese hilfe aktiv weggeklickt hat und sie nicht nur gesehen hat!
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView {
    self.statsTipView = nil;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"BPOStatsButtomTip"];
    [defaults synchronize];
}


#pragma mark - NSFetchedResultController
-(void)setupDataSource
{
    Category *importCat = nil;
    NSMutableArray *normalCats = [NSMutableArray array];
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    for (Category *aCat in self.Regulation.categories) {
        if ([aCat.name isEqualToString:@"Importierte Kurse"]) {
            if ([aCat.courses count] < 1) {
                [self.dataManager.document.managedObjectContext deleteObject:aCat];
            }else {
                importCat = aCat;
            }
            
        }else {
            [normalCats addObject:aCat];
        }
    }
    [normalCats sortUsingDescriptors:sortDescriptors];
    if (importCat) {
        self.dataSource = [NSArray arrayWithObjects:[NSArray arrayWithObject:importCat], normalCats, nil];
        self.sectionNames = [NSArray arrayWithObjects:@"Importierte Kurse", @"Kategorien",nil];
    }else {
        self.dataSource = [NSArray arrayWithObject:normalCats];
        self.sectionNames = [NSArray arrayWithObject:@"Kategorien"];
    }
    [self.tableView reloadData];
}


#pragma mark - View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *backgroundImage = [userDefaults stringForKey:@"backgroundImage"];
    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:backgroundImage]];
    self.tableView.backgroundView = image;
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setupDataSource];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:@"BPOStatsButtomTip"]) {
        [self showPopTipView];
    }
    if (!self.navigationController.toolbar.hidden) {
        NSLog(@"toolbar sichtbar");
    }
    self.dataManager.delegate = self;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.toolbar.tintColor = self.navigationController.navigationBar.tintColor;
    self.navigationController.toolbarHidden = NO;

    
}

- (void)setRegulation:(ExamRegulations *)Regulation
{
    _Regulation = Regulation;
    self.title = Regulation.subject;
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.statsTipView removeFromSuperview];
    self.statsTipView = nil;
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([[self.dataSource objectAtIndex:0] count] == 0) {
        return nil;
    }
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
    headerLabel.numberOfLines = 1;
    
    [headerView addSubview:headerLabel];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataSource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.dataSource objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CategoryCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Category *aCategory = [[self.dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.textLabel.text = aCategory.name;
    
    if ([aCategory.name isEqualToString:@"Importierte Kurse"]) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",[aCategory.courses count]];
    }else {
        cell.detailTextLabel.text = @"";
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
        Category *aCategory = [[self.dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        [self.dataManager deleteCategory:aCategory];
        [self setupDataSource];
    }
}

#pragma mark - Sague

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController respondsToSelector:@selector(setCategory:)]){
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        Category *aCategory = [[self.dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        [segue.destinationViewController setCategory:aCategory];
        [segue.destinationViewController setDataManager:self.dataManager];
    }
    if ([segue.identifier isEqualToString:@"ShowStats"] && [segue.destinationViewController respondsToSelector:@selector(setDataManager:)]){
        [segue.destinationViewController setARegulation:self.Regulation];
    }
    if ([segue.identifier isEqualToString:@"createNewCate"]){
        [segue.destinationViewController setDatamanager:self.dataManager];
        [segue.destinationViewController setARegulation:self.Regulation];
    }

}

- (void)viewDidUnload {
    [self setStatsButtom:nil];
    [super viewDidUnload];
}
@end
