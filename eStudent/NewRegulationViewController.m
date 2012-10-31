//
//  NewRegulationViewController.m
//  eStudent
//
//  Created by Christian Rathjen on 16.08.12.
//
//

#import "NewRegulationViewController.h"

@interface NewRegulationViewController () <ERDataManagerDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *regTitle;
@property (weak, nonatomic) IBOutlet UITextField *regFaculty;
@property (weak, nonatomic) IBOutlet UITextField *regDegree;
@property (weak, nonatomic) IBOutlet UITextField *regCP;
@property (weak, nonatomic) IBOutlet UIButton *regCreateButton;
@property (weak, nonatomic) IBOutlet UITextField *regDate;
- (IBAction)regCreate:(id)sender;

@end

@implementation NewRegulationViewController
@synthesize regTitle;
@synthesize regFaculty;
@synthesize regDegree;
@synthesize regCP;
@synthesize regCreateButton;
@synthesize regDate;

- (void)viewDidUnload {
    [self setRegTitle:nil];
    [self setRegFaculty:nil];
    [self setRegDegree:nil];
    [self setRegCP:nil];
    [self setRegDate:nil];
    [self setRegCreateButton:nil];
    [super viewDidUnload];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.dataManager = [[ERDataManager alloc] init];
    self.dataManager.delegate = self;
    [self.dataManager accessDatabase];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *backgroundImage = [userDefaults stringForKey:@"backgroundImage"];
    if (!backgroundImage)
    {
        backgroundImage = @"background_1.jpg";
        [userDefaults setObject:backgroundImage forKey:@"backgroundImage"];
        [userDefaults synchronize];
    }
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:backgroundImage]];
}

- (IBAction)touchDownBackground:(id)sender {
    [self.regCP resignFirstResponder];
    [self.regFaculty resignFirstResponder];
    [self.regTitle resignFirstResponder];
    [self.regDate resignFirstResponder];
    [self.regDegree resignFirstResponder];
    NSLog(@"touched");
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)ERDocumentIsReady:(ERDataManager *)sender
{
    NSLog(@"Datamanager bereit, Knopf aktiviert");
    [self.regCreateButton setUserInteractionEnabled:YES];
}

- (void)ERSavingComplete:(ERDataManager *)sender
{
    self.dataManager = nil;
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)cancel:(id)sender {
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)regCreate:(id)sender {
    //check all textfields for information
    if (![self.regTitle.text isEqualToString:@""] && ![self.regFaculty.text isEqualToString:@""] && ![self.regDegree.text isEqualToString:@""] && ![self.regDate.text isEqualToString:@""] && ![self.regCP.text isEqualToString:@""]) {
        NSLog(@"Alle Felder ausgefuellt");
        [self.dataManager saveEmptyRegulation:self.regTitle.text date:self.regDate.text degree:self.regDegree.text cp:self.regCP.text faculty:self.regFaculty.text];
    }else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Achtung" message:@"Bitte füllen sie alle Felder aus!" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alertView show];
        [self resignFirstResponder];
    }
}

@end
