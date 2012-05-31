//
//  CoursesViewController.m
//  eStudent
//
//  Created by Jalyna on 02.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CoursesViewController.h"
#import "SubjectViewController.h"

@interface CoursesViewController () <SemesterListLoaderDelegate>
@property (nonatomic, strong) id sems;
@property (weak, nonatomic) IBOutlet UITableView *tv;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end


@implementation CoursesViewController

@synthesize downloader = _downloader;
@synthesize activityIndicator = _activityIndicator;
@synthesize sems = _sems;
@synthesize tv = _tv;

// Wird aufgerufen, wenn die Semester geparst werden. Aktualisiert dann die Tableview
- (void)SemesterListParsed:(NSDictionary *)semesters {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *subject = [userDefaults stringForKey:@"savedSubject"];
    if(subject) return;
    
    [self.activityIndicator stopAnimating];
    NSArray *stuff = [semesters objectForKey:@"semesters"];
    self.sems = [stuff copy]; 
    [self.tv reloadData];
}

// Wird aufgerufen, wenn es einen Netzwerkfehler gibt und lädt dann lokale Fächer
- (void)SemesterListParsedError {
    [self.activityIndicator startAnimating];
    // Save text of the selected cell:
    NSLog(@"Push to SubjectView");
    SubjectViewController *nextView = [self.storyboard instantiateViewControllerWithIdentifier:@"SubjectViewController"];
    nextView.title = @"Alle Semester";
    [self.navigationController pushViewController:nextView animated:NO]; 
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

// Prüft, ob weitergeleitet werden soll, da bereits ein Subject gewählt wurde und leitet ggf. weiter
- (void)viewDidAppear:(BOOL)animated {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *subject = [userDefaults stringForKey:@"savedSubject"];
    
    
    if(subject) {
        SubjectViewController *nextView = [self.storyboard instantiateViewControllerWithIdentifier:@"SubjectViewController"];
        nextView.title = [userDefaults stringForKey:@"savedSemester"];
        self.title = @"Auswahl";
        [super viewDidAppear:NO];
        nextView.forced = true;
        [self.navigationController pushViewController:nextView animated:NO]; 
        return;
    }

    if (!self.downloader){
        [self.activityIndicator startAnimating];
        self.downloader = [[SemesterListLoader alloc] init];
        self.downloader.delegate = self;
        [self.activityIndicator startAnimating];
        [self.downloader getJSONListing];
    }
    
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

// Initialisiert die View
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
    

}

- (void)viewDidUnload
{
    [self setTv:nil];
    [self setActivityIndicator:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sems count];
}

// Gibt den Inhalt einer aktuellen Zelle zurück
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SemesterListingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSDictionary *details = [self.sems objectAtIndex:indexPath.row];
    cell.textLabel.text = [details objectForKey:@"title"];
    return cell;
}

// Wird aufgerufen, wenn eine Zelle selektiert wird und ruft dann die Subject-Übersicht des gewählten Semesters auf.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.activityIndicator startAnimating];
    // Save text of the selected cell:
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"choose Semester %@", cell.textLabel.text);
    SubjectViewController *nextView = [self.storyboard instantiateViewControllerWithIdentifier:@"SubjectViewController"];
    nextView.title = cell.textLabel.text;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.activityIndicator stopAnimating];
    [self.navigationController pushViewController:nextView animated:YES]; 
}

@end
