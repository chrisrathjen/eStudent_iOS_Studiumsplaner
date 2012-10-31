//
//  SubjectViewController.m
//  eStudent
//
//  Created by Jalyna on 29.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SubjectViewController.h"
#import "SubjectCoursesViewController.h"

@interface SubjectViewController () <SubjectListLoaderDelegate>
@property (nonatomic, strong) id subs;
@property (nonatomic, strong) NSMutableArray *allSubjects;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end

@implementation SubjectViewController

@synthesize downloader = _downloader;
@synthesize activityIndicator = _activityIndicator;
@synthesize subs = _subs;
@synthesize tv = _tv;
@synthesize sb = _sb;
@synthesize allSubjects = _allSubjects;
@synthesize forced = _forced;

// Wurd aufgerufen, wenn alle Subjects geparsed wurden
- (void)SubjectListParsed:(NSDictionary *)subjects {
    [self.activityIndicator stopAnimating];
    self.allSubjects = [subjects objectForKey:@"subjects"];
    self.subs = [self.allSubjects copy]; 
    [self.tv reloadData];
}

// Wird aufgerufen, wenn es einen Fehler gab
- (void)SubjectListParsedError {
    [self.downloader getDatabaseListing];
}

// Prüft ob ein Fach bereits gewählt wurde und leitet dann weiter
- (void)viewDidAppear:(BOOL)animated {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *subject = [userDefaults stringForKey:@"savedSubject"];
    
    if(subject && self.forced) {
        self.forced = false;
        SubjectCoursesViewController *nextView = [self.storyboard instantiateViewControllerWithIdentifier:@"SubjectCoursesViewController"];
        nextView.title = [userDefaults stringForKey:@"savedSubjectTitle"];
        
        nextView.fileName = subject;
        nextView.semester = [userDefaults stringForKey:@"savedSemester"];
        self.title = nextView.semester;
        [super viewDidAppear:NO];
        [self.navigationController pushViewController:nextView animated:NO]; 
        return;
    } else {
        self.forced = false;
        [userDefaults removeObjectForKey:@"savedSubject"];
        [userDefaults synchronize];
    }
    
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

// Initialisiert View
- (void)viewDidLoad
{
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
    
    
    if (!self.downloader){
        self.downloader = [[SubjectListLoader alloc] init];
        self.downloader.delegate = self;
        [self.activityIndicator startAnimating];
        if(self.title != @"Alle Semester") [self.downloader getJSONListing:self.title];
        else {
            NSLog(@"Loaded from SubjectView");
            [self.downloader getDatabaseListing];
        }
    }
}


- (void)viewDidUnload
{
    [self setTv:nil];
    [self setActivityIndicator:nil];
    [super viewDidUnload];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.subs count];
}


// Lädt einzelne Zelle
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SubjectCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSDictionary *details = [self.subs objectAtIndex:indexPath.row];
    cell.textLabel.text = [details objectForKey:@"title"];
    return cell;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// Wird aufgerufen, wenn eine Zelle berührt wurde und leitet dann zum gewählten Fach weiter
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.activityIndicator startAnimating];
    // Save text of the selected cell:
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"choose Subject %@", cell.textLabel.text);
    SubjectCoursesViewController *nextView = [self.storyboard instantiateViewControllerWithIdentifier:@"SubjectCoursesViewController"];
    
    nextView.title = cell.textLabel.text;
    nextView.fileName = [[self.subs objectAtIndex:indexPath.row] objectForKey:@"file"];
    nextView.semester = self.title;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.activityIndicator stopAnimating];
    [self.navigationController pushViewController:nextView animated:YES]; 
}

// Wird aufgerufen, wenn das Eingeben in der Searchbar beginnt
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    self.tv.allowsSelection = NO;
    self.tv.scrollEnabled = NO;
}

// Wird aufgerufen, wenn Cancel in der Searchbar geklickt wurde. Dann wird der Text zurückgestzt
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text=@"";
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    self.tv.allowsSelection = YES;
    self.tv.scrollEnabled = YES;
}

// Startet die Suche und sucht unabhängig von Groß- und Kleinschreibung im Titel der Fächer.
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"search Subject %@", searchBar.text);
	NSMutableArray  *stuff = [[NSMutableArray alloc] initWithCapacity:0];
    NSString *string;
    
    for (NSDictionary *row in self.allSubjects) {
        string = [row objectForKey:@"title"];
        if ([[string lowercaseString] rangeOfString:[searchBar.text lowercaseString]].location != NSNotFound || [searchBar.text length] == 0) {
            [stuff addObject: row];
        }
    }
    
    self.subs = stuff;
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    self.tv.allowsSelection = YES;
    self.tv.scrollEnabled = YES;
    [self.tv reloadData];
}




@end
