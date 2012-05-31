//
//  ESHomeScreenViewControllerViewController.m
//  eStudent
//
//  Created by Nicolas Autzen on 01.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ESHomeScreenViewControllerViewController.h"

@interface ESHomeScreenViewControllerViewController ()

@end

@implementation ESHomeScreenViewControllerViewController

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
    if (!backgroundImage) 
    {
        backgroundImage = @"background_1.jpg";
        [userDefaults setObject:backgroundImage forKey:@"backgroundImage"];
        [userDefaults synchronize];
    }
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:backgroundImage]];
    self.navigationItem.hidesBackButton = YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
