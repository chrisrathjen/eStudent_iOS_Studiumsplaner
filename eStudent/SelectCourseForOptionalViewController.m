//
//  SelectCourseForOptionalViewController.m
//  eStudent
//
//  Created by Christian Rathjen on 26.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SelectCourseForOptionalViewController.h"

@interface SelectCourseForOptionalViewController ()
@property (nonatomic, strong)NSArray *ExistingCourses;
@end

@implementation SelectCourseForOptionalViewController
@synthesize delegate, courses, anOptional, ExistingCourses;

- (void)viewDidLoad
{
    self.ExistingCourses = [self.anOptional.courses allObjects];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[userDefaults stringForKey:@"backgroundImage"]]];
}

#pragma mark - Table view data source


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.backgroundColor = [UIColor clearColor];
    
	//headerLabel.backgroundColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0.0];
	headerLabel.opaque = NO;
	headerLabel.textColor = [UIColor whiteColor];
    headerLabel.shadowColor = [UIColor blackColor];
	headerLabel.highlightedTextColor = [UIColor whiteColor];
	headerLabel.font = [UIFont boldSystemFontOfSize:18];
	headerLabel.frame = CGRectMake(10.0, 0.0, 300.0, 40.0);
    if (section == 1) {
        headerLabel.text = @"Bereits gewählte Kurse";
    } else if (section == 0) {
        headerLabel.text = @"Verfügbare Kurse";
    }
    
    [headerView addSubview:headerLabel];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        return [self.anOptional.courses count];
    }else if (section == 0) {
        return [self.courses count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"selectCourse";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (indexPath.section == 0) {
        Course_ER *aCourse = [self.courses objectAtIndex:indexPath.row];
        cell.textLabel.text = aCourse.name;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@CP", aCourse.cp];
    }
    if (indexPath.section == 1) {
        Course_ER *aCourse = [ExistingCourses objectAtIndex:indexPath.row];
        cell.textLabel.text = aCourse.name;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@CP", aCourse.cp];
    }
     
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
       [self.delegate selectedCourse:[self.courses objectAtIndex:indexPath.row] inOptional:self.anOptional]; 
    } else if (indexPath.section == 1) {
        [self.delegate removeCourse:[self.ExistingCourses objectAtIndex:indexPath.row] fromOptional:self.anOptional];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
