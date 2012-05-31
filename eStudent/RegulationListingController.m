//
//  RegulationListingController.m
//  eStudent
//
//  Created by Christian Rathjen on 24.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RegulationListingController.h"

@interface RegulationListingController () <ERRegulationListingDownloaderDelegate, ERDataManagerDelegate>
@property (nonatomic, strong) id regs;
@property (weak, nonatomic) IBOutlet UITableView *tv;
@property (nonatomic, strong) ERDataManager *dataManager;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end

@implementation RegulationListingController


@synthesize downloader = _downloader;
@synthesize dataManager = _dataManager;
@synthesize activityIndicator = _activityIndicator;
@synthesize regs = _regs;
@synthesize tv = _tv;


- (void)ERRegulationAlreadyPersistent
{
    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidden = YES;
    UIAlertView *anAlertView = [[UIAlertView alloc] initWithTitle:@"Achtung" message:@"Diese Prüfungsordnung ist bereits in der Datenbank! Bitte lösche zunächst die lokale Version." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [anAlertView show];
    
}

- (void)ERSavingComplete:(ERDataManager *)sender //ERDataManer
{
    NSLog(@"neue Ordnung gespeichert");
    self.dataManager = nil;
    [self.activityIndicator stopAnimating];
    [self.navigationController popViewControllerAnimated:YES]; //uses the Backbottom once
}

- (void)ERListingParsed:(NSDictionary *)regulations //ListingDownloader
{
    NSLog(@"delegate erfolgreich");
    [self.activityIndicator stopAnimating];
    NSArray *stuff = [regulations objectForKey:@"names"];
    //self.downloader = nil; //Downloader wird nicht mehr benoetigt!
    NSLog(@"last Name %@", [[stuff objectAtIndex:0] objectForKey:@"Name"]);
    self.regs = [stuff copy]; 
    NSLog(@"last Name %@", [[self.regs objectAtIndex:0] objectForKey:@"Name"]);
    [self.tv reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Import";
    NSLog(@"View geladen");
    if (!self.downloader){
        self.downloader = [[ERRegulationListingDownloader alloc] init];
        self.downloader.delegate = self;
        [self.activityIndicator startAnimating];
        [self.downloader getJSONRegulationListing];
    }
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
    return [self.regs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ExamListingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSDictionary *details = [self.regs objectAtIndex:indexPath.row];
    cell.textLabel.text = [details objectForKey:@"Name"];
    cell.detailTextLabel.text = [details objectForKey:@"Date"];
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Hier den Namen der Ordnung zu einer entsprechenden url zusammenbauen und dann den ERDatamanager nutzen um eine Regulation hinzuzufuegen
    //danach entweder in diesem View bleiben oder zur auswahl wechseln oder in die gerade herruntergeladene Ordnung...
    NSDictionary *details = [self.regs objectAtIndex:indexPath.row];
    self.dataManager = [[ERDataManager alloc] init];
    self.dataManager.delegate = self;
    [self.activityIndicator startAnimating];
    [self.dataManager saveExamRegulation:[details objectForKey:@"Name"] address:[details objectForKey:@"XML"]];
}

@end
