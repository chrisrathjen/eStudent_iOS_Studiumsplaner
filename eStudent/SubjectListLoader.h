//
//  SubjectListLoader.h
//  eStudent
//
//  Created by Jalyna on 30.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SubjectListLoader;
@protocol SubjectListLoaderDelegate
@optional
// Sendet alle geparsten Fächer
- (void)SubjectListParsed:(NSDictionary *)subjects;
// Wird aufgerufen, wenn ein Verbindungsfehler aufgetreten ist
- (void)SubjectListParsedError;
@end

@interface SubjectListLoader : NSObject

// Beginnt das Parsen der Daten vom Server
- (void) getJSONListing:(NSString *) semester;
// Gibt eine Liste von Fächern anhand der Datenbank zurück
- (void) getDatabaseListing;
@property (nonatomic, weak) id <SubjectListLoaderDelegate> delegate;
//Enthält die Verbindung zur Datenbank
@property (nonatomic, strong) UIManagedDocument *coursesDatabase; 


@end
