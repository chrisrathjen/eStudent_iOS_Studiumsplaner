//
//  ESSettingsViewController.m
//  eStudent
//
//  Created by Nicolas Autzen on 23.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ESSettingsViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ESSettingsViewController ()

@end

@implementation ESSettingsViewController

@synthesize essensFarbenGesetzt, essensSwitchCell, essensFarbenSwitch;

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *backgroundImage = [userDefaults stringForKey:@"backgroundImage"];
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:backgroundImage]];
    
    self.essensFarbenGesetzt = [userDefaults boolForKey:@"essensFarben"];
    if (!self.essensFarbenGesetzt) 
    {
        [self.essensFarbenSwitch setOn:YES];
    }
    
    self.essensSwitchCell.layer.borderColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1.0].CGColor;
    self.essensSwitchCell.layer.borderWidth = .4f;
    self.essensSwitchCell.layer.backgroundColor = [UIColor whiteColor].CGColor;
    self.essensSwitchCell.layer.cornerRadius = 10.0;
    self.essensSwitchCell.layer.masksToBounds = YES;
}

- (IBAction)essensSwitchgeswitched:(id)sender
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (self.essensFarbenGesetzt) 
    {
        [userDefaults setBool:NO forKey:@"essensFarben"];
        [userDefaults synchronize];
        self.essensFarbenGesetzt = NO;
        [self.essensFarbenSwitch setOn:NO];
    }
    else 
    {
        [userDefaults setBool:YES forKey:@"essensFarben"];
        [userDefaults synchronize];
        self.essensFarbenGesetzt = YES;
        [self.essensFarbenSwitch setOn:YES];
    }
}


- (IBAction)deleteAllDatabases:(id)sender
{
    UIActionSheet *deleteV = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Abbrechen" destructiveButtonTitle:@"Bestätigen" otherButtonTitles: nil];
    [deleteV showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{         
    if (actionSheet.destructiveButtonIndex == buttonIndex) 
    {
        NSURL *filePath = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/Stundenplan_Database",[filePath path]] error:nil];//Stundenplan
        //[[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/Tasks",[filePath path]] error:nil];//TaskPlaner
        
    } 
}

- (IBAction)resetTips:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults removeObjectForKey:@"addCourseTipDisabled"];//stundenplan
    [defaults removeObjectForKey:@"chooseMensaTipDisabled"];//Mensa
    [defaults removeObjectForKey:@"BPOImportTip"];
    [defaults removeObjectForKey:@"BPOStatsButtomTip"];
    [defaults removeObjectForKey:@"BPOEditMode"];
    [defaults removeObjectForKey:@"BPOStatsBar"];
    [defaults removeObjectForKey:@"TaskTip"];
    
    [defaults synchronize];
}

@end
