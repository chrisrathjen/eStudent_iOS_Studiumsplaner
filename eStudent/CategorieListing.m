//
//  CategorieListing.m
//  eStudent
//
//  Created by Christian Rathjen on 22.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CategorieListing.h"
#import "Category.h"
#import "Course_ER.h"
#import "Criterion.h"

@interface CategorieListing ()

@end

@implementation CategorieListing
@synthesize objectsToMove, dataSource, dataManager;

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *backgroundImage = [userDefaults stringForKey:@"backgroundImage"];
    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:backgroundImage]];
    self.tableView.backgroundView = image;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CategorieCellForMoving";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    Category *aCat = [self.dataSource objectAtIndex:indexPath.row];
    cell.textLabel.text = aCat.name;
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Category *aCat = [self.dataSource objectAtIndex:indexPath.row];
    for (int i = 0; i < [self.objectsToMove count]; i++) {
        if ([[objectsToMove objectAtIndex:i] isKindOfClass:[Course_ER class]]) {
            Course_ER *aCourse = [objectsToMove objectAtIndex:i];
            aCourse.category = aCat;
        }
        if ([[objectsToMove objectAtIndex:i] isKindOfClass:[Criterion class]]) {
            Criterion *aCriterion = [objectsToMove objectAtIndex:i];
            aCriterion.category = aCat;
        }
    }
    [self.dataManager.document saveToURL:self.dataManager.document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
        if (success) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

@end
