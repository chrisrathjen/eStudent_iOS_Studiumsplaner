//
//  CoursesDataManager.h
//  eStudent
//
//  Created by Jalyna on 06.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CourseSubject.h"

@class CoursesDataManager;
@protocol CoursesDataManagerDelegate
@optional
// Wird ausgeführt wenn alle Kurse geladen wurden und gib Kurse und Fach zurück
- (void)coursesDataManager:(CoursesDataManager *)sender loadedCourses:(NSArray *)courses loadedSubject:(CourseSubject *)subject;
// Wird aufgerufen, wenn keine Daten vorhanden sind
- (void)noDataToParse:(CoursesDataManager *)sender;
// Wird aufgerufen, wenn es keine Internetverbindung gibt
- (void)noNetworkConnection:(CoursesDataManager *)sender localizedError:(NSString *)errorString;
@end

@interface CoursesDataManager : NSObject <NSXMLParserDelegate>

// Diese Methode muss aufgerufen werden, um Daten vom Server zu parsen, Als Parameter muss der Filename des Subjects angegeben werden
- (void)getXMLDataFromServer:(NSString *)Subject; 

@property (nonatomic, weak) id <CoursesDataManagerDelegate> delegate; //Delegate gibt Auskunft wann die Daten zur verfügung stehen
@property (nonatomic, strong) UIManagedDocument *coursesDatabase; // Enthält die Verbindung zur Datenbank

@end
