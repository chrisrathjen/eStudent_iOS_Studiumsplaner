//
//  NewCategorieViewController.m
//  eStudent
//
//  Created by Christian Rathjen on 16.08.12.
//
//

#import "NewCategorieViewController.h"

@interface NewCategorieViewController () <UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *catTitle;

@end

@implementation NewCategorieViewController
@synthesize catTitle, datamanager, aRegulation;

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
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:backgroundImage]];
}

- (IBAction)backgroundTouched:(id)sender {
    [self.catTitle resignFirstResponder];
}

- (IBAction)createNewCategorie:(id)sender {
    if (![self.catTitle.text isEqualToString:@""]) {
        [self.datamanager createNewCategorie:self.catTitle.text inRegulation:self.aRegulation];
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Achtung" message:@"Bitte geben sie einen Namen ein!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)viewDidUnload {
    [self setCatTitle:nil];
    [super viewDidUnload];
}
@end
