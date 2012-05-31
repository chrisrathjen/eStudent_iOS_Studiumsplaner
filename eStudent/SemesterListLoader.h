//
//  SemesterListLoader.h
//  eStudent
//
//  Created by Jalyna on 28.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SemesterListLoader;
@protocol SemesterListLoaderDelegate
@optional
// Gibt all Semester zurück, die gelesen wurden
- (void)SemesterListParsed:(NSDictionary *)semesters;
// Wird ausgeführt sobald es einen Fehler beim Parsen gab
- (void)SemesterListParsedError;
@end


@interface SemesterListLoader : NSObject
// Muss aufgerufen werden um den Parsing-Prozess zu starten
- (void) getJSONListing;
// Als Delegate sollte ein ViewController gewählt werden
@property (nonatomic, weak) id <SemesterListLoaderDelegate> delegate;

@end
