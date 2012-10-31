//
//  SubjectListLoader.m
//  eStudent
//
//  Created by Jalyna on 30.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SubjectListLoader.h"
#import "CourseSubject.h"

@interface SubjectListLoader()

// Buffer, der den JSON-String speichert
@property (nonatomic, strong) NSMutableData *dataStorage; 

@end

@implementation SubjectListLoader

@synthesize dataStorage = _dataStorage;
@synthesize delegate = _delegate;
@synthesize coursesDatabase = _coursesDatabase;

// Versucht anhand des Semester eine Verbindung zum Server aufzubauen.
- (void)getJSONListing:(NSString *)semester {
    NSString *url = [CATALOG_SUBJECTS stringByAppendingString:semester];
    NSURLRequest *dataRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    NSURLConnection *dataConnection = [[NSURLConnection alloc] initWithRequest:dataRequest delegate:self];
    
    if (dataConnection) {
        self.dataStorage = [NSMutableData data];
    } else {
        [self.delegate SubjectListParsedError];
    }
    
}

// Öffnet die Kursdatenbank.
- (void)getDatabaseListing {
    NSURL *filePath = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask]lastObject];
    filePath = [filePath URLByAppendingPathComponent:@"courses"];
    self.coursesDatabase = [[UIManagedDocument alloc] initWithFileURL:filePath];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    self.coursesDatabase.persistentStoreOptions = options;
    
    [self useDocument];
    
}

// Öffnet die bestehende Courses-Datenbank bzw. erstellt sie
-(void)useDocument {
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.coursesDatabase.fileURL path]]){
        //Falls die Datei nicht existiert wird sie erstellt
        [self.coursesDatabase saveToURL:self.coursesDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success){
            if ([[NSFileManager defaultManager] fileExistsAtPath:[self.coursesDatabase.fileURL path]]) NSLog(@"there is now a Databased stored");
        }];
        return;
    } 
    
    NSArray *results;
    if (self.coursesDatabase.documentState == UIDocumentStateClosed){
        NSLog(@"oeffne bestehende DB in SubjectListLoader");
        [self.coursesDatabase openWithCompletionHandler:^(BOOL success){
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CourseSubject"];
            request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"file" ascending:YES]];
            NSError *error = nil;
            NSArray *results = [self.coursesDatabase.managedObjectContext executeFetchRequest:request error:&error];
            NSLog(@"Es befinden sich %d Subjects in der DB", [results count]);
            [self saveResults:results];
        }];
        return;
    }
    
    if (self.coursesDatabase.documentState == UIDocumentStateNormal) {
        NSLog(@"Nutze bestehende Db in SubjectListLoader");
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CourseSubject"];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"file" ascending:YES]];
        NSError *error = nil;
        NSArray *results = [self.coursesDatabase.managedObjectContext executeFetchRequest:request error:&error];
        
        [self saveResults:results];
        return;
    }
    [self saveResults:results];
    return;
}

// Speichert die Fächer aus der geöffneten Datenbank in einen Array.
-(void)saveResults:(NSArray *) results {
    NSMutableArray *rows = [[NSMutableArray alloc] init];
    
    for(CourseSubject *subject in results) {
        NSMutableDictionary *row = [[NSMutableDictionary alloc] init];
        [row setObject:subject.file forKey:@"file"];
        [row setObject:subject.title forKey:@"title"];
        [rows addObject:row];
    }
    
    NSDictionary *subjects = [NSDictionary dictionaryWithObjectsAndKeys:rows, @"subjects", nil];
    
    [self.delegate SubjectListParsed:subjects];
}


// Wird aufgerufen, wenn eine Verbindung zum Server existiert und initialisiert den Buffer.
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.dataStorage setLength:0];
}

// Hängt Daten an den Puffer.
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (self.dataStorage) {
        // Daten anhängen
        [self.dataStorage appendData:data];
    } else {
        // Sonst initialisieren
        self.dataStorage = [self.dataStorage initWithData:data];
    }
}

// Wird aufgerufen, wenn ein Fehler aufgetreten ist
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{
    NSLog(@"Connection failed: %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    [self.delegate SubjectListParsedError];
}

// Wird aufgerufen, wenn das Parsen der Serverdaten beendet ist und wandelt den JSON-String in ein Dictionary um.
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSDictionary *listing = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:self.dataStorage options:kNilOptions error:nil];
    if (listing) [self.delegate SubjectListParsed:listing];
}


@end
