//
//  modifyTaskViewController.m
//  eStudent
//
//  Created by Georg Scharsich on 14.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "modifyTaskViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CategoriesViewController.h"

@interface modifyTaskViewController () <UITextFieldDelegate, CategoriesViewControllerDelegate>


@property (nonatomic, assign, getter=isUpdated) BOOL updated;
@property (weak, nonatomic) IBOutlet UITableViewCell *duaDateCellView;
@property (weak, nonatomic) IBOutlet UITableViewCell *priorityCellView;
@property (strong, nonatomic) TaskCategory *theCategorie;

@end

@implementation modifyTaskViewController
@synthesize dueDateLabel;
@synthesize segControl;
@synthesize datePicker;
@synthesize textField;
@synthesize catButton;
@synthesize document = _document;
@synthesize aTask, delegate;
@synthesize updated;
@synthesize duaDateCellView;
@synthesize priorityCellView;
@synthesize theCategorie;


-(void)categorieFromUserSelection:(TaskCategory *)aTaskCategorie{
    self.theCategorie = aTaskCategorie;
    self.updated = YES;
    NSLog(@"Kategorie: %@ gesetzt", self.theCategorie.name);
    self.catButton.titleLabel.text = [NSString stringWithFormat:@"Kategorie: %@", self.theCategorie.name];
}


- (void)viewWillDisappear:(BOOL)animated
{
    if (self.updated && ![self.textField.text isEqualToString:@""]) 
    {
        if (self.document.documentState == UIDocumentStateNormal){
            NSString *aDateString = [NSString stringWithFormat:@"%@",[NSNumber numberWithDouble:[self.datePicker.date timeIntervalSince1970]]];
            if (self.aTask){
                self.aTask.name = self.textField.text;
                if ([self.dueDateLabel.text isEqualToString:@"ohne Datum"]) {
                    self.aTask.duedate = nil;
                    NSLog(@"set Date to nil");
                }else {
                    NSLog(@"set Date");
                    self.aTask.duedate = aDateString;
                }
                
                self.aTask.priority = [NSNumber numberWithInt:[self.segControl selectedSegmentIndex]];
                if (self.theCategorie) {
                    NSLog(@"Kategorie %@ gesetzt!", self.theCategorie.name);
                    aTask.category = theCategorie;
                }
            } else {
                if ([self.dueDateLabel.text isEqualToString:@"ohne Datum"]) {
                    aDateString = nil;
                }
               aTask = [Task TaskFromUserInput:self.textField.text date:aDateString priority:[NSNumber numberWithInt:[self.segControl selectedSegmentIndex]] inCategory:nil inManagedContext:self.document.managedObjectContext];
                NSLog(@"segment number vor prio:%@", aTask.priority);
                if (self.theCategorie) {
                    NSLog(@"Kategorie %@ gesetzt!", self.theCategorie.name);
                    aTask.category = theCategorie;
                }
            }
            [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
                NSLog(@"saving changes");
                [self.delegate savingFinished];
            }];
        } else {
            NSLog(@"Document war nicht bereit, aenderungen wurden nicht gespeichert");
        }
    }
    //self.textField.text = nil;
    
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.textField.text = self.aTask.name;
    
    
    NSLog(@"%@",self.aTask.duedate);
    int time = [self.aTask.duedate intValue];
    if (self.aTask.category) {
        self.catButton.titleLabel.text = [NSString stringWithFormat:@"Kategorie: %@", self.aTask.category.name];
    }
    if (time){
        NSDateFormatter *aDateFormatter = [[NSDateFormatter alloc] init];
        [aDateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"de_DE"]];
        [aDateFormatter setDateFormat:@"dd.MM.yyyy HH:mm"];
        self.dueDateLabel.text = [aDateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:time]];
    }
    if (!time) {
        self.datePicker.date = [NSDate date];
    }else{
        self.datePicker.date = [NSDate dateWithTimeIntervalSince1970:time];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.textField.delegate = self;
    
    //Background
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *backgroundImage = [defaults stringForKey:@"backgroundImage"];
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:backgroundImage]];
    
    
    //Setup TableViewCells
    
    //dueDateCell
    self.duaDateCellView.layer.borderColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1.0].CGColor;
    self.duaDateCellView.layer.borderWidth = .4f;
    self.duaDateCellView.layer.cornerRadius = 10.0;
    UITapGestureRecognizer *dueDateTapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(duaDateCellisTouched:)];
    [self.dueDateLabel addGestureRecognizer:dueDateTapRec];
    self.duaDateCellView.layer.masksToBounds = YES;
    
    //priorityCell //vlt ganz rausnehmen??
    self.priorityCellView.layer.borderColor =[UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1.0].CGColor;
    self.priorityCellView.layer.borderWidth = .4f;
    self.priorityCellView.layer.cornerRadius = 10.0;
    self.priorityCellView.layer.masksToBounds = YES;
    
    
    //setup segmentedControl to previous State if there was one
    if ([self.aTask.priority intValue] == 1) {
        [self.segControl setSelectedSegmentIndex:1];
    }else{
        [self.segControl setSelectedSegmentIndex:0];
    }

}

- (IBAction)duaDateCellisTouched:(id)sender
{
    [self.textField resignFirstResponder];
    self.datePicker.hidden = NO;
    if (self.duaDateCellView.highlighted) {
        self.duaDateCellView.highlighted = NO;
    }else {
        self.duaDateCellView.highlighted = YES;
    }
    self.priorityCellView.highlighted = NO;
    self.datePicker.hidden = NO;
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidUnload {
    [self setDatePicker:nil];
    [self setTextField:nil];
    [self setSegControl:nil];
    [self setDueDateLabel:nil];
    [self setDuaDateCellView:nil];
    [self setPriorityCellView:nil];
    [self setCatButton:nil];
    [super viewDidUnload];
}

#pragma mark TextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    self.updated = YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.textField resignFirstResponder];
    if (self.textField.text && !self.aTask) {
        self.updated = YES;
    }
    if (self.aTask && ([self.aTask.name isEqualToString:self.textField.text])) {
        self.updated = YES;
    }
    return YES;
}
#pragma mark CoreData


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"chooseCat"]){
        if ([segue.destinationViewController respondsToSelector:@selector(setDelegate:)]){
            [segue.destinationViewController setDelegate:self];
            [segue.destinationViewController setDocument:self.document];
        }
    }
}


- (IBAction)segmentValueChanged:(id)sender {
    self.updated = YES;
    [self resignFirstResponder];
    [self.textField resignFirstResponder];
    NSLog(@"prio changed");
}

- (IBAction)dateChanged:(id)sender {
    NSDateFormatter *aDateFormatter = [[NSDateFormatter alloc] init];
    [aDateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"de_DE"]];
    [aDateFormatter setDateFormat:@"dd.MM.yyyy HH:mm"];
    self.dueDateLabel.text = [aDateFormatter stringFromDate:self.datePicker.date];
    self.updated = YES;
}

- (IBAction)removeDueDate:(id)sender {
    self.dueDateLabel.text = @"ohne Datum";
    self.datePicker.hidden = YES;
    self.updated = YES;
}
@end
