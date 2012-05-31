//
//  DetailViewController.m
//  eStudent
//
//  Created by Christian Rathjen on 09.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController() <UIScrollViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *VAKTextField;
@property (weak, nonatomic) IBOutlet UITextField *CPTextField;
@property (weak, nonatomic) IBOutlet UITextField *MarkTextField;
@property (weak, nonatomic) IBOutlet UISwitch *passedSwitch;

@end

@implementation DetailViewController
@synthesize nameTextField;
@synthesize VAKTextField;
@synthesize CPTextField;
@synthesize MarkTextField;
@synthesize passedSwitch;
@synthesize dataManager;
@synthesize course;



#pragma mark - View lifecycle
- (void)viewDidAppear:(BOOL)animated
{
    self.nameTextField.text = course.name;
    self.VAKTextField.text = course.vak;
    self.CPTextField.text = [course.cp stringValue];
    self.MarkTextField.text = [course.mark stringValue];
    
    
    
    if ([course.passed boolValue]){
        self.passedSwitch.on = YES;
    }else{
        self.passedSwitch.on = NO;
    }
}



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

- (void)viewWillDisappear:(BOOL)animated
{
    course.name = self.nameTextField.text;
    course.vak = self.VAKTextField.text;
    course.cp = [NSNumber numberWithInt:[self.CPTextField.text intValue]];
    course.mark = [NSNumber numberWithFloat:[self.MarkTextField.text floatValue]];
    if (self.passedSwitch.on) {
        course.passed = [NSNumber numberWithBool:YES];
    } else {
        course.passed = [NSNumber numberWithBool:NO];
    }
    if ((!course.name || [course.name isEqualToString:@""]) && !course.vak) {
        [self.dataManager.document.managedObjectContext deleteObject:course];
    }
    [self.dataManager.document saveToURL:self.dataManager.document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
        NSLog(@"saving changes to course");
    }];
}


- (void)viewDidUnload
{
    [self setNameTextField:nil];
    [self setVAKTextField:nil];
    [self setCPTextField:nil];
    [self setMarkTextField:nil];
    [self setPassedSwitch:nil];
    [super viewDidUnload];

}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - scrollView

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self resignFirstResponder];
}

#pragma mark - textfield


@end
