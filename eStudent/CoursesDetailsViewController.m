//
//  CoursesDetailsViewController.m
//  eStudent
//
//  Created by Jalyna on 11.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CoursesDetailsViewController.h"
#import "CourseCourse.h"
#import "CourseStaff.h"
#import "CourseDate.h"
#import "ExamRegulations.h"
#import "Veranstaltung.h"
#import "Veranstaltung+Create.h"

@interface CoursesDetailsViewController ()
@property (nonatomic, strong) NSArray *regulations;
@property (nonatomic, strong) NSArray *regulationsHaveCourse;
@property BOOL readyStundenplan;

@end

@implementation CoursesDetailsViewController

@synthesize tv = _tv;
@synthesize dataManager = _dataManager;
@synthesize course = _course;
@synthesize regulations = _regulations;
@synthesize stundenplanDataManager = _stundenplanDataManager;
@synthesize readyStundenplan = _readyStundenplan;
@synthesize regulationsHaveCourse = _regulationsHaveCourse;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

// Der Datamanager des Studiumplaners ist bereits
- (void)ERDocumentIsReady:(ERDataManager *)sender
{
    [self.dataManager getAllRegulations];
    [self.dataManager RegulationsContainingCourse:self.course.title orVak:self.course.vak];
}

- (void)ERNoDataStored:(ERDataManager *)sender {
}

// Alle Regulations des Stusiumsplaner wurden geladen und als Attribut gespeichert. Die Tabelle wird aktualisiert.
- (void)ERAllRegulations:(NSArray *)allRegulations 
{
    self.regulations = allRegulations;
    [self.tv reloadData];
}

// Der Stundenplan ist bereit
- (void)documentIsReady {
    self.readyStundenplan = YES;
    [self.tv reloadData];
}

// Gibt alle Regulations zurück, die den aktuellen Kurs eingetragen haben.
- (void)ERCourseAlreadyInRegulation:(NSArray *)regulationsContainenCourse
{
    self.regulationsHaveCourse = regulationsContainenCourse;
    [self.tv reloadData];
}

// Wird aufgerufen wenn ein Kurs erfolgreich eingetragen wurde. Refresht die Tabelle.
- (void)ERCourseCreatedSuccessfully {
    [self.dataManager getAllRegulations];
    [self.dataManager RegulationsContainingCourse:self.course.title orVak:self.course.vak];
}

// Initialisiert die View und initialisiert die einzelnen Schnittstellen
- (void)viewDidLoad
{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *backgroundImage = [userDefaults stringForKey:@"backgroundImage"];
    if (!backgroundImage) 
    {
        backgroundImage = @"background_1.jpg";
        [userDefaults setObject:backgroundImage forKey:@"backgroundImage"];
        [userDefaults synchronize];
    }
    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:backgroundImage]];
    self.tv.backgroundView = image;
    
    [super viewDidLoad];
	
    self.dataManager = [[ERDataManager alloc] init];
    [self.dataManager setDelegate:self];
    [self.dataManager accessDatabase];
	
    self.readyStundenplan = NO;
    self.stundenplanDataManager = [[ESStundenplanDataManager alloc] init];
    [self.stundenplanDataManager setDelegate:self];
    [self.stundenplanDataManager openDocument];
}

- (void)viewDidUnload
{
    [self setTv:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// Anzahl der Sections 3 (Allgemein, Aktionen, Termine)
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 40.0)];
	UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.backgroundColor = [UIColor clearColor];
	headerLabel.opaque = NO;
	headerLabel.textColor = [UIColor whiteColor];
    headerLabel.shadowColor = [UIColor blackColor];
	headerLabel.highlightedTextColor = [UIColor whiteColor];
	headerLabel.font = [UIFont boldSystemFontOfSize:18];
	headerLabel.frame = CGRectMake(10.0, 0.0, 300.0, 40.0);
    
	if(section == 0) headerLabel.text = @"Allgemein"; 
	else if(section == 1) headerLabel.text = @"Aktionen"; 
	else if(section == 2) headerLabel.text = @"Termine"; 
	[customView addSubview:headerLabel];
    
	return customView;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0) return @"Allgemein"; 
    if(section == 1) return @"Aktionen"; 
    if(section == 2) return @"Termine"; 
    return @"";
}

// Gibt die Anzahl der Zeilen pro Section zurück
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0) return 3;
    if(section == 1) {
        if(self.regulations != nil) {
            NSLog(@"found regulations");
            return (self.readyStundenplan ? 1 : 0)+[self.regulations count];
        }
        return (self.readyStundenplan ? 1 : 0);
    }
    if(section == 2) return [_course.hasDate count];
    return 0;
}

// Gibt die einzelnen Zellen zurück
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DetailCell";
    static NSString *CellIdentifier2 = @"DetailCellSubtitle";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if(indexPath.section == 0) {
    if(indexPath.row == 0) {
        cell.textLabel.text = _course.title;
    } else if(indexPath.row == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
        if(_course.ects != @"undefined") {
            cell.textLabel.text  = [NSString stringWithFormat:@"%@ | %@ ECTS", _course.vak, _course.ects];
        } else {
             cell.textLabel.text  = _course.vak;
        }
        cell.detailTextLabel.text = _course.course_description;
    } else if(indexPath.row == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
        cell.textLabel.text = @"Dozent/In";
        NSMutableArray * result = [[NSMutableArray alloc] init];
        for(CourseStaff *obj in _course.hasStaff) {
            [result addObject:obj.name];
        }
        cell.detailTextLabel.text = [result componentsJoinedByString:@" | "];
    } 
    } else if(indexPath.section == 2) {
        int i = 0;
        CourseDate *date;
        
        for(CourseDate *obj in _course.hasDate) {
            if(indexPath.row == i) {
                date = obj;
                break;
            }
            i++;
        }
        
        if(date != nil) {
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
            NSString *prefix = [date.prefix copy];
            if(prefix == nil) prefix = @"";
            
            NSString *weekDay = [[date.weekDay copy] uppercaseString];
            if(weekDay == nil) weekDay = @"";
            
            NSString *dayStart = [date.dayStart copy];
            if(dayStart == nil) dayStart = @"";
            
            NSString *dayEnd = [date.dayEnd copy];
            if(dayEnd == nil) dayEnd = @"";
            
            if([date.dayStart isEqualToString:date.dayEnd] && date.dayEnd != nil) {
                cell.textLabel.text  = [NSString stringWithFormat:@"(%@) %@ | %@ - %@", prefix, weekDay, dayStart, dayEnd];
            } else {
                cell.textLabel.text  = [NSString stringWithFormat:@"(%@) %@ | %@", prefix, weekDay, dayStart];          
            }
            
            if(date.room != nil) {
                cell.detailTextLabel.text  = [NSString stringWithFormat:@"%@ - %@ (%@)", date.startRange, date.endRange, date.room];
            } else if(date.startRange != nil) {
                cell.detailTextLabel.text  = [NSString stringWithFormat:@"%@ - %@", date.startRange, date.endRange];
            } else {
                cell.detailTextLabel.text  = @"";
            }
            
        }
    } else if(indexPath.section == 1) {
        cell.textLabel.textColor = [UIColor whiteColor];
        if(indexPath.row == 0 && self.readyStundenplan) {
            cell.backgroundColor = [UIColor lightGrayColor];
            cell.textLabel.text = @"In Stundenplan eintragen";
            cell.accessoryType = UITableViewCellAccessoryNone;
            if(self.readyStundenplan) {
                NSArray *allCourses = [self.stundenplanDataManager getAllVeranstaltungen];
                for(Veranstaltung *v in allCourses) {
                    if([v.titel isEqualToString:self.course.title]) {
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        cell.textLabel.text = @"Bereits im Stundenplan";
                        break;
                    }
                }
            }
        } else {
            cell.backgroundColor = [UIColor blueColor];
            ExamRegulations *reg = [_regulations objectAtIndex: (indexPath.row-(self.readyStundenplan ? 1 : 0))];
            if(reg != nil) {
                cell.textLabel.text = [NSString stringWithFormat:@"In %@ eintragen", reg.subject];  
                
                cell.accessoryType = UITableViewCellAccessoryNone;
                
                if(self.regulationsHaveCourse != nil && [self.regulationsHaveCourse containsObject:reg]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    cell.textLabel.text = [NSString stringWithFormat:@"Bereits in %@", reg.subject];  
                    
                }
            }
            
        }
    }

    
    return cell;
}

// Falls Aktions-Zelle berührt wurde, führe Aktion aus.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.section == 1) {
        if(indexPath.row == 0 && self.readyStundenplan) {
            NSArray *allCourses = [self.stundenplanDataManager getAllVeranstaltungen];
            for(Veranstaltung *v in allCourses) {
                if(v.titel == self.course.title) {
                    return;
                    break;
                }
            }
            // Eintragen!
            for(CourseDate *date in self.course.hasDate) {
                [NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"de_DE"]];
                [dateFormatter setDateFormat:@"dd.MM.yy"];
                NSDate *dateStart = [[NSDate alloc] init];
                dateStart = [dateFormatter dateFromString:date.dayStart];
                NSDate *dateEnd = [[NSDate alloc] init];
                dateEnd = [dateFormatter dateFromString:date.dayEnd];
                
                NSString *weekDay;
                
                if([date.weekDay isEqualToString:@"mo"]) {
                    weekDay = @"Montag";
                } else if([date.weekDay isEqualToString:@"di"]) {
                    weekDay = @"Dienstag";
                } else if([date.weekDay isEqualToString:@"mi"]) {
                    weekDay = @"Mittwoch";
                } else if([date.weekDay isEqualToString:@"do"]) {
                    weekDay = @"Donnerstag";
                } else if([date.weekDay isEqualToString:@"fr"]) {
                    weekDay = @"Freitag";
                } else if([date.weekDay isEqualToString:@"sa"]) {
                    weekDay = @"Samstag";
                } else if([date.weekDay isEqualToString:@"so"]) {
                    weekDay = @"Sonntag";
                } else {
                    weekDay = @"Montag";
                }
                
                if(date.startRange == nil || date.endRange == nil || date.weekDay == nil) continue;
                [Veranstaltung veranstaltungWithTitle:self.course.title ort:date.room art:date.prefix wochentag:weekDay        anfangsdatum:dateStart anfangszeit:date.startRange 
                    enddatum:dateEnd endzeit:date.endRange
                    inContext:self.stundenplanDataManager.managedDocument.managedObjectContext];
                NSLog(@"Saved in Stundenplan %@",weekDay);
            }
            [self.stundenplanDataManager save];
            [self.tv reloadData];
            return;
        }
        
        ExamRegulations *reg = [_regulations objectAtIndex: (indexPath.row-(self.readyStundenplan ? 1 : 0))];
        
        if(self.regulationsHaveCourse != nil && [self.regulationsHaveCourse containsObject:reg]) {
            
            // Austragen
            
        } else {
        
            NSNumber *ects = [NSNumber numberWithInt:0];
            if(self.course.ects != @"undefined") {
                NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
                [f setNumberStyle:NSNumberFormatterDecimalStyle];
                ects = [f numberFromString:self.course.ects];
            }
        
            [self.dataManager createCourse: self.course.title withVak:self.course.vak withCP:ects inRegulation:[self.regulations objectAtIndex:(indexPath.row-(self.readyStundenplan ? 1 : 0))]];
        
            return;
        }
    }
}


@end
