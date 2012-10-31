//
//  SubjectCoursesViewController.m
//  eStudent
//
//  Created by Jalyna on 06.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SubjectCoursesViewController.h"
#import "CourseCourse.h"
#import "CoursesDetailsViewController.h"

@interface SubjectCoursesViewController () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSArray *subjectCourses;
@property (nonatomic, strong) NSArray *filteredCourses;

@end

@implementation SubjectCoursesViewController

@synthesize activityIndicator = _activityIndicator;
@synthesize tv = _tv;
@synthesize sb = _sb;
@synthesize toolbar = _toolbar;
@synthesize fileName = _fileName;
@synthesize semester = _semester;
@synthesize dataManager = _dataManager;
@synthesize subject = _subject;
@synthesize subjectCourses = _subjectCourses;
@synthesize filteredCourses = _filteredCourses;

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];    return self;
}

// Initialisiert die View und lädt dann die Daten
- (void)viewDidLoad
{
    self.subject = nil;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *backgroundImage = [userDefaults stringForKey:@"backgroundImage"];
    
    
    if (!backgroundImage) 
    {
        backgroundImage = @"background_1.jpg";
        [userDefaults setObject:backgroundImage forKey:@"backgroundImage"];
        [userDefaults synchronize];
    }
    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:backgroundImage]];
    self.tv.backgroundView = image;
    
    [super viewDidLoad];
    
    [self.activityIndicator startAnimating];
    
    self.dataManager = [[CoursesDataManager alloc] init];
    [self.dataManager setDelegate:self];
    
    // Setze default Verzeichnis aus den UserDefaults und hole die aktuellen Daten für diese
    [userDefaults setObject:self.fileName forKey:@"defaultSubject"];
    [userDefaults synchronize];
    
    [self.dataManager getXMLDataFromServer:self.fileName];
    
}

- (void)viewDidUnload
{
    
    [self setTv:nil];
    [self setActivityIndicator:nil];
    [super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// Anzahl der Zellen
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.subject = nil) return 0;
    return [self.filteredCourses count];
}

// Gibt in der Zelle den Fachnamen zurück
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CourseCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(self.subject = nil) {
        cell.textLabel.text = @"not loaded";
        cell.detailTextLabel.text  = @"not loaded";
    } else {
        CourseCourse *tempCourse = [self.filteredCourses objectAtIndex:indexPath.row];
        cell.textLabel.text = tempCourse.title;
        cell.detailTextLabel.text  = tempCourse.vak;
    }
    return cell;
}

// Leitet weiter, wenn ein Kurs gewählt wurde
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.activityIndicator startAnimating];
    CourseCourse *course = [self.filteredCourses objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"choose Course %@", cell.textLabel.text);
    
    CoursesDetailsViewController *nextView = [self.storyboard instantiateViewControllerWithIdentifier:@"CoursesDetailsView"];
    nextView.title = cell.textLabel.text;
    nextView.course = course;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController pushViewController:nextView animated:YES]; 
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    self.tv.allowsSelection = NO;
    self.tv.scrollEnabled = NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text=@"";
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    self.tv.allowsSelection = YES;
    self.tv.scrollEnabled = YES;
}

// Sucht durch anhand der Kurstitel
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	NSMutableArray  *stuff = [[NSMutableArray alloc] initWithCapacity:0];
    NSString *string;
    
    for (CourseCourse *row in self.subjectCourses) {
        string = row.title;
        
        if ([[string lowercaseString] rangeOfString:[searchBar.text lowercaseString]].location != NSNotFound || [searchBar.text length] == 0) {
            [stuff addObject: row];
        }
    }
    
    self.filteredCourses = stuff;
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    self.tv.allowsSelection = YES;
    self.tv.scrollEnabled = YES;
    [self.tv reloadData];
}

// Wird aufgerufen, falls es keine zu parsierenden Daten gibt
- (void)noDataToParse:(CoursesDataManager *)sender
{
    [self.activityIndicator removeFromSuperview];
    UITextView *noData = [[UITextView alloc] initWithFrame:CGRectMake(20.0, 5.0, 280.0, 80.0)];
    noData.text = @"Es liegen momentan keine Daten vor, bitte versuche es zu einem späteren Zeitpunkt noch einmal.";
    noData.textAlignment = UITextAlignmentCenter;
    [noData setScrollEnabled:NO];
    [noData setEditable:NO];
    NSLog(@"No Data to parse");
    return;
}

// Wird aufgerufen, falls es keine Verbindung gibt
- (void)noNetworkConnection:(CoursesDataManager *)sender localizedError:(NSString *)errorString
{
    [self.activityIndicator removeFromSuperview];
    UIAlertView *networkAlert = [[UIAlertView alloc] initWithTitle:@"Keine Verbindung" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [networkAlert show];
    return;
}

// Die Methode wird aufgerufen, wenn durch das Delegate alle Kurse geladen wurden. Speichert dann die Daten und lädt die Tableview neu.
- (void)coursesDataManager:(CoursesDataManager *)sender loadedCourses:(NSArray *)courses  loadedSubject:(CourseSubject *)subject 
{
    [subject setFile: self.fileName];
    [subject setTitle: self.title];
    [subject setSemester: self.semester];
    self.subject = subject;
    self.subjectCourses = courses;
    self.filteredCourses = courses;
    [self.tv reloadData];
    [self.activityIndicator stopAnimating];
    [self.activityIndicator removeFromSuperview];
    
    
    // Save as Default
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.fileName forKey:@"savedSubject"];
    [userDefaults setObject:subject.title forKey:@"savedSubjectTitle"];
    [userDefaults setObject:self.semester forKey:@"savedSemester"];
    [userDefaults synchronize];
    NSLog(@"Found defaults: %@",[userDefaults stringForKey:@"savedSubject"]);
}


- (void)dealloc
{
    self.dataManager.delegate = nil;
}

- (IBAction)switchToHome:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
