//
//  CategoriesViewController.m
//  eStudent
//
//  Created by Georg Scharsich on 25.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CategoriesViewController.h"
#import <CoreData/CoreData.h>
#import "TaskCategory+Create.h"

@interface CategoriesViewController () <UIAlertViewDelegate>
- (void)useDocument;
- (void)getCategories;


@property (nonatomic, strong) NSMutableArray *categories;
@property (nonatomic, strong) NSString *aNewCat;

@end

@implementation CategoriesViewController
@synthesize theTextField;
@synthesize delegate;

@synthesize document = _document;
@synthesize categories, tableView, aNewCat;

#pragma mark - getDataFromModel


-(void)getCategories
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TaskCategory"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    NSError *error = nil;
    self.categories = [[self.document.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    [self.tableView reloadData];
}

- (void) setDocument:(UIManagedDocument *)document
{
    if (_document != document){
        _document = document;
        [self useDocument];
    }
}

- (void)useDocument
{    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.document.fileURL path]]) {
        NSLog(@"There is no Database pls create a Task");
        [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:[self.document.fileURL path]]) NSLog(@"there is now a Database stored");
            [self getCategories];
        }];
    } else if (self.document.documentState == UIDocumentStateClosed) {
        [self.document openWithCompletionHandler:^(BOOL success) {
            NSLog(@"opened existing Database");
            [self getCategories];
        }];
    } else if (self.document.documentState == UIDocumentStateNormal) {
        NSLog(@"Database is already open");
        [self getCategories];
    } 
}



#pragma mark - VC lifecycle

- (void)viewDidAppear:(BOOL)animated
{
    if (self.document.documentState == UIDocumentStateNormal)
    {
        [self getCategories];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!self.document) {
        NSURL *filePath = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        filePath = [filePath URLByAppendingPathComponent:@"Tasks"];
        self.document = [[UIManagedDocument alloc] initWithFileURL:filePath];
        NSLog(@"nutze eigenes Doc");
    }else {
        [self getCategories];
        NSLog(@"nutze uebergebenes document");
    }
    
    
    //Background
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *backgroundImage = [defaults stringForKey:@"backgroundImage"];
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:backgroundImage]];
    
    //BackButtom for following viewcontrollers
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"OK";
    self.navigationItem.backBarButtonItem = barButton;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.categories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"catCellShow";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if ([[self.categories objectAtIndex:[indexPath row]] isKindOfClass:[TaskCategory class]])
    {
        TaskCategory *aCategorie = [self.categories objectAtIndex:[indexPath row]];
        cell.textLabel.text = aCategorie.name;
    }
    return cell;
}



- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        TaskCategory *aCategorie = [self.categories objectAtIndex:[indexPath row]];
        if ([aCategorie.tasks count] > 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fehler" message:@"Kategorie enthält noch Aufgaben, diese müssen zunächst entfernt werden!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }else {
            [self.document.managedObjectContext deleteObject:aCategorie];
            [self getCategories];
        }
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    if ([[self.categories objectAtIndex:[indexPath row]] isKindOfClass:[TaskCategory class]]) {
        if (self.delegate){
            [self.delegate categorieFromUserSelection:[self.categories objectAtIndex:[indexPath row]]];
        }
        [self.navigationController popViewControllerAnimated:YES];        //set Categorie
    }
}


- (void)viewDidUnload {
    [self setTheTextField:nil];
    [super viewDidUnload];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
}

- (IBAction)createNewCategorie:(id)sender {
    if (self.theTextField.text) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TaskCategory"];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        NSError *error = nil;
        NSArray *cats = [[self.document.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
        BOOL containsCat = NO;
        for (TaskCategory *aCat in cats) {
            if ([aCat.name isEqualToString:self.theTextField.text]){
                containsCat = YES;
            }
        }
        if (!containsCat) {
            [TaskCategory TaskCategoryFromUserInput:self.theTextField.text inManagedContext:self.document.managedObjectContext];
            [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:nil];
            NSLog(@"New Categorie saved");
        }
        self.theTextField.text = nil;
        [self getCategories];
        [self.theTextField resignFirstResponder];
    }
}
@end
