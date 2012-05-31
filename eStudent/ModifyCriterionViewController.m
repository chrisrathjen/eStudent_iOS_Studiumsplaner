//
//  ModifyCriterionViewController.m
//  eStudent
//
//  Created by Christian Rathjen on 10.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ModifyCriterionViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ModifyCriterionViewController ()
@property (nonatomic, assign)BOOL updated;
@end

@implementation ModifyCriterionViewController
@synthesize titleLabel;
@synthesize descLabel;
@synthesize segmentedControl;
@synthesize updated;
@synthesize aDataManager, aCriterion;


- (void)viewDidLoad
{
    [super viewDidLoad];
	self.updated = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *backgroundImage = [userDefaults stringForKey:@"backgroundImage"];
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:backgroundImage]];
    
    if ([self.aCriterion.passed boolValue]){
        [self.segmentedControl setSelectedSegmentIndex:0];
    } else {
        [self.segmentedControl setSelectedSegmentIndex:1];
    }
    self.titleLabel.text = self.aCriterion.name;
    self.descLabel.text = self.aCriterion.note;
    self.titleLabel.layer.opacity = 0.9;
    self.titleLabel.layer.cornerRadius = 10.0;
    self.descLabel.layer.opacity = 0.9;
    self.descLabel.layer.cornerRadius = 10.0;
}

- (void)viewDidDisappear:(BOOL)animated{
    if (self.updated){
        if (self.segmentedControl.selectedSegmentIndex == 0){
            self.aCriterion.passed = [NSNumber numberWithBool:YES];
        }else {
            self.aCriterion.passed = [NSNumber numberWithBool:NO];
        }
        [self.aDataManager.document saveToURL:self.aDataManager.document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
            NSLog(@"saved Criterion");
        }];
    }
    
    self.updated = NO;
}

- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setDescLabel:nil];
    [self setSegmentedControl:nil];
    [self setUpdated:NO];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)valueChanged:(id)sender {
    self.updated = YES;
}
@end
