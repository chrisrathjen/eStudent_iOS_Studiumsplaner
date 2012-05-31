//
//  SemesterListLoader.m
//  eStudent
//
//  Created by Jalyna on 28.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SemesterListLoader.h"


@interface SemesterListLoader()

@property (nonatomic, strong) NSMutableData *dataStorage; // Buffer für das geparste JSON

@end



@implementation SemesterListLoader

@synthesize dataStorage = _dataStorage;
@synthesize delegate = _delegate;

// Prüft zuerst ob die Semester-Liste erreichbar ist und beginnt dann das parsen. Bei keiner Verbindung wird die Fehlermethode ausgeführt.
- (void)getJSONListing {
    NSURLRequest *dataRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:CATALOG_SEMESTERS]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    NSURLConnection *dataConnection = [[NSURLConnection alloc] initWithRequest:dataRequest delegate:self];
    
    if (dataConnection) {
        self.dataStorage = [NSMutableData data];
    } else {
        [self.delegate SemesterListParsedError];
    }
    
}

// Initial wird der Puffer auf 0 gesetzt. Die Methode wird automatisch bei bestehender Verbindung aufgerufen
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.dataStorage setLength:0];
}

// Wenn Daten vom Server empfangen wurde, werden sie an den Puffer gehängt.
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

// Wird aufgerufen, wenn es einen Verbindungsfehler gibt.
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{
    NSLog(@"Connection failed: %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    [self.delegate SemesterListParsedError];
}

// Wird aufgerufen, wenn alle Daten geladen wurden. Wandelt dann den JSON-String in ein Dictionary (Map) um.
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSDictionary *listing = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:self.dataStorage options:0 error:nil];
    if (listing) [self.delegate SemesterListParsed:listing];
}


@end
