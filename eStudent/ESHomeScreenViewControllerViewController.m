//
//  ESHomeScreenViewControllerViewController.m
//  eStudent
//
//  Created by Nicolas Autzen on 01.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ESHomeScreenViewControllerViewController.h"

@interface ESHomeScreenViewControllerViewController ()
@property (weak, nonatomic) IBOutlet UIToolbar *theToolbar;

@end

@implementation ESHomeScreenViewControllerViewController
@synthesize theToolbar;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *backgroundImage = [userDefaults stringForKey:@"backgroundImage"];
    if (!backgroundImage && !IS_IPHONE_5)
    {
        backgroundImage = @"background_1.jpg";
        [userDefaults setObject:backgroundImage forKey:@"backgroundImage"];
        [userDefaults synchronize];
    } else if (!backgroundImage && IS_IPHONE_5) {
        backgroundImage = @"background_1-568h.jpg";
        [userDefaults setObject:backgroundImage forKey:@"backgroundImage"];
        [userDefaults synchronize];
    }
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:backgroundImage]];
    self.navigationItem.hidesBackButton = YES;
    if (self.navigationController.toolbar.hidden) {
        [self.theToolbar setHidden:NO];
    }
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setToolbarHidden:YES animated:NO];//Die Toolbar wird nur vom Aufgabenplaner verwendet und muss deaktiviert werden sobald der User diese View verlaesst
    [self.theToolbar setHidden:NO];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.theToolbar setHidden:YES];
}

- (void)viewDidUnload
{
    [self setTheToolbar:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
