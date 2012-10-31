//
//  CoursesDataManager.m
//  eStudent
//
//  Created by Jalyna on 06.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CoursesDataManager.h"
#import "CourseSubject.h"
#import "CourseCourse.h"
#import "CourseStaff.h"
#import "CourseDate.h"

@interface CoursesDataManager()

- (void)useDocument;
- (void)getDataFromNetwork:(NSString *)Courses;
- (void)loadDatabaseConnection;
- (void)loadDataFromDisk;
- (void)startParsingData;
- (void)loadDataIntoDatabase:(UIManagedDocument *)document;
- (void)startParsingData;

@property (nonatomic, strong) NSMutableData *dataStorage; // Enthält die XML nach erfolgreichem herrunterladen
@property (nonatomic, strong) NSMutableString *currentElementValue; // Stringbuffer für den xml Parser
@property (nonatomic, strong) NSString *currentSubject; // Aktuelles Fach als Filename
@property (nonatomic, strong) CourseDate *aDateEntry; // Zwischenspeicher für Date
@property (nonatomic, strong) CourseStaff *aStaffEntry; // Zwischenspeicher für Staff
@property (nonatomic, strong) CourseSubject *aSubject; // Zwischenspeicher für aktuelles Fach
@property (nonatomic, strong) CourseCourse *aCourse; // Zwischenspeicher für Course
@property (nonatomic, strong) NSMutableArray *subjectCourses; // Dient zur temporären Ablage der Kurse

@end

@implementation CoursesDataManager

@synthesize delegate = _delegate;
@synthesize dataStorage = _dataStorage;
@synthesize currentElementValue = _currentElementValue;
@synthesize coursesDatabase = _coursesDatabase;
@synthesize currentSubject = _currentSubject;
@synthesize aDateEntry = _aDateEntry;
@synthesize aStaffEntry = _aStaffEntry;
@synthesize aSubject = _aSubject;
@synthesize aCourse = _aCourse;
@synthesize subjectCourses = _subjectCourses;



// 1. Setzt Propertys und startet die Verbindung zur Datenbank
- (void)getXMLDataFromServer:(NSString *)Subject
{
    
    self.currentSubject = Subject;
    if (_dataStorage) _dataStorage = nil;
    [self loadDatabaseConnection];
}

// 2. Erstelle Datenbankverknuepfung und speichere diese in der Property
- (void)loadDatabaseConnection
{
    //Suche den Document Ordner der aktuellen App
    NSURL *filePath = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask]lastObject];
    //Setzte Verzeichnissnamen fuer die aktuelle Datenbank courses
    filePath = [filePath URLByAppendingPathComponent:@"courses"];
    self.coursesDatabase = [[UIManagedDocument alloc] initWithFileURL:filePath];
    
}

// 3. Set Courses Database
-(void)setCoursesDatabase:(UIManagedDocument *)coursesDatabase
{
    if (_coursesDatabase != coursesDatabase) {
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
        coursesDatabase.persistentStoreOptions = options;
        
        _coursesDatabase = coursesDatabase;
        [self useDocument];
    }
}

// 4. Diese Methode sucht nach einer lokalen Datenbank (und erstellt diese falls nicht vorhanden). Jenachdem in welchem Zustand die Datenbank ist wird diese erstellt oder genutzt. Muss sie erstellt werden sind auch keine lokalen Daten verfuegbar und ein neuer Datensatz wird geparsed und danach abgespeichert. Ist bereits eine Datenbank vorhanden und verfuegbar wird ueberprueft ob die Datenbank einen aktuellen Datensatz enthaellt. Ist dies nicht der Fall wird eine neue Version geparsed und gespeichert. Fuer den Fall das ein aktueller Datensatz vorhanden ist wird diese geladen
-(void)useDocument{
    NSLog(@"Access Document");
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.coursesDatabase.fileURL path]]){
        //Falls die Datei nicht existiert wird sie erstellt
        [self.coursesDatabase saveToURL:self.coursesDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success){
            [self getDataFromNetwork:self.currentSubject];
            if ([[NSFileManager defaultManager] fileExistsAtPath:[self.coursesDatabase.fileURL path]]) NSLog(@"there is now a Databased stored");
        }];
        return;
    } 
    
    if (self.coursesDatabase.documentState == UIDocumentStateClosed){
        [self.coursesDatabase closeWithCompletionHandler:nil];
        NSLog(@"oeffne bestehende DB, %@", [self.coursesDatabase description]);
        [self.coursesDatabase openWithCompletionHandler:^(BOOL success){
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CourseSubject"];
            request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"file" ascending:YES]];
            request.predicate = [NSPredicate predicateWithFormat:@"file = %@", self.currentSubject];
            NSError *error = nil;
            NSArray *results = [self.coursesDatabase.managedObjectContext executeFetchRequest:request error:&error];
            NSLog(@"Es befinden sich %d Subjects in der DB", [results count]);
            
            if ([results count] > 0)//Ist ein Datensatz gefunden kann dieser geladen werden
            {
                [self loadDataFromDisk];
            } else {
                [self getDataFromNetwork:self.currentSubject];
                NSLog(@"Found empty database, parsing from the net");
            }
        }];
        
        return;
    }
    
    if (self.coursesDatabase.documentState == UIDocumentStateNormal) {
        NSLog(@"Nutze bestehende Db");
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CourseSubject"];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"file" ascending:YES]];
        request.predicate = [NSPredicate predicateWithFormat:@"file = %@", self.currentSubject];
        NSError *error = nil;
        NSArray *results = [self.coursesDatabase.managedObjectContext executeFetchRequest:request error:&error];
        
        if ([results count] > 0)//Ist ein Datensatz gefunden kann dieser geladen werden
        {
            [self loadDataFromDisk];
        } else {
           [self getDataFromNetwork:self.currentSubject];
           NSLog(@"Found empty database, parsing from the net");
        } 
        return;
    }
}

// 5. Get Data From Network
-(void)getDataFromNetwork:(NSString *)Subject;
{
        NSURLRequest *dataRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:CATALOG_COURSES, [Subject stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    NSURLConnection *dataConnection = [[NSURLConnection alloc] initWithRequest:dataRequest delegate:self];
        NSLog(@"get Data from network: %@", dataRequest.URL);
    
    if (dataConnection) {
        _dataStorage = [NSMutableData data];
    }else{
        NSLog(@"Connection failed");
    }
}

// 6. Diese Datenbank laed den aktuellen Datensatz aus der Datenbank in die Property
- (void)loadDataFromDisk
{
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CourseSubject"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"file" ascending:YES]];
    //Suche alle Courseses fuer die aktuelle Mensa sowie Woche
    request.predicate = [NSPredicate predicateWithFormat:@"file = %@", self.currentSubject];
    NSError *error = nil;
    NSArray *results = [self.coursesDatabase.managedObjectContext executeFetchRequest:request error:&error];
    
    //Falls ein oder mehrere Datensaetze gefunden worden wird der letzte verwendet (normalerweise gibt es hier immer nur einen aktuellen Datensatz, falls es doch mehr gibt werden diese in der naechsten woche alle entfernt)
    if ([results count] > 0) {
        _aSubject = [results lastObject]; //gefundenes Subject
        NSLog(@"Courses werden geladen..."); 
        NSSet *courses = [[NSSet alloc] initWithSet:_aSubject.hasCourses]; //Alle Courses des Subjects
        //NSMutableDictionary *currentCourses = [[NSMutableDictionary alloc]init];
        _subjectCourses = [[NSMutableArray alloc] init];
        for (CourseCourse *aCourse in courses) {
            [_subjectCourses addObject:aCourse];
        }
     
        [self.delegate coursesDataManager:self loadedCourses:self.subjectCourses loadedSubject:self.aSubject]; //Sagt dem Delegate bescheid das die Daten nun in der Property zur Verfuegung stehen
     
     }else {
         //Dies solle nie passieren aber falls kein entsprechendes Coursese gefunden wurde wird ein neues geparsed
         NSLog(@"error, using net");
         [self getDataFromNetwork:self.currentSubject];
     }
} 

//Ist die Verbindung zurueckgesetzt werden die bereits geladenen Daten verworfen
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [_dataStorage setLength:0];
}
//Sind noch keine Daten vorhanden wird ein neues Array angelegt, ansonsten werden die neuen Daten an das bestehende Array appended.
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (_dataStorage) {
        [_dataStorage appendData:data];
    }else{
        _dataStorage = [_dataStorage initWithData:data];
    }
}

//Fehlerausgabe
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection failed: %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    [self.delegate noNetworkConnection:self localizedError:[error localizedDescription]];
    
}
//Ist der Download abgeschlossen wird der Parser mit den uebertragenen Daten aufgerufen!
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self startParsingData];
}


//Startet den Parser mit den vorher herruntergeladenen Daten
-(void)startParsingData
{
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:_dataStorage];
    parser.delegate = self;
    
    [parser parse];
}
//Wir aufgerufen wenn ein neues Tag gefunden wurde!
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    
    // Neues Subject
    if([elementName isEqualToString:@"subject"]) {
        //_aSubject = [[CourseSubject alloc] init];
        _aSubject = [NSEntityDescription insertNewObjectForEntityForName:@"CourseSubject" inManagedObjectContext:self.coursesDatabase.managedObjectContext];
        return;
    }
    
    // Neuer Kurs
    if([elementName isEqualToString:@"course"]) {
        //if (!_currentCourses) _currentCourses = [[NSMutableDictionary alloc]init];
        //_aCourse = [[CourseCourse alloc] init];
        _aCourse = [NSEntityDescription insertNewObjectForEntityForName:@"CourseCourse" inManagedObjectContext:self.coursesDatabase.managedObjectContext];
        if(!_subjectCourses) _subjectCourses = [ [NSMutableArray alloc] init];
        [_subjectCourses addObject:_aCourse];
        return;
    }
    
    // Neue Staff 
    if([elementName isEqualToString:@"member"]) {
        //_aStaffEntry = [[CourseStaff alloc] init];
        _aStaffEntry = [NSEntityDescription insertNewObjectForEntityForName:@"CourseStaff" inManagedObjectContext:self.coursesDatabase.managedObjectContext];
        return;
    }
    
    // Neues Date  
    if([elementName isEqualToString:@"date"]) {
        //_aDateEntry = [[CourseDate alloc] init];
        _aDateEntry = [NSEntityDescription insertNewObjectForEntityForName:@"CourseDate" inManagedObjectContext:self.coursesDatabase.managedObjectContext];
        return;
    }
    
}
//Wird aufgerufen wenn Text zwischen den tags gefunden wurde. 
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)aString
{
    
    if (!_currentElementValue) {
        _currentElementValue = [[NSMutableString alloc] initWithString:aString];
    }else{
        [_currentElementValue appendString:aString]; //Wenn schon Text innerhalb des aktuellen Tags gefunden wurde wird der neue Text nur hinzugefuegt
    }
    _currentElementValue = [[_currentElementValue stringByReplacingOccurrencesOfString:@"\n" withString:@""] mutableCopy];
    _currentElementValue = [[_currentElementValue stringByReplacingOccurrencesOfString:@"\r" withString:@""] mutableCopy];
    _currentElementValue = [[_currentElementValue stringByReplacingOccurrencesOfString:@"\t" withString:@""] mutableCopy];
    [_currentElementValue setString:[_currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
}


//Die Methode wird aufgerufen wenn ein Tag geschlossen wird. Hier werden dann die bereitsgespeicherten Texte in die foodEntry Objekte gespeichert und die Objekte in die Tages Dictinaries und die Tages Dicts ins Courses Dictionary.
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    //NSLog(@"Closed Title %@ : %@",elementName, _currentElementValue);
    if ([elementName isEqualToString:@"title"]) {
        if(self.aSubject.title == NULL || self.aSubject.title == nil) {
            // Title für Subject
            [self.aSubject setTitle:_currentElementValue];
        } else {
            // Title für Course
            [self.aCourse setTitle:_currentElementValue];
        }
        _currentElementValue = nil;
        return;
    }
    
    // Course VAK
    if ([elementName isEqualToString:@"vak"]) {
        [self.aCourse setVak: _currentElementValue];
        _currentElementValue = nil;
        return;
    }
    
    // Course Description
    if ([elementName isEqualToString:@"description"]) {
        [self.aCourse setCourse_description: _currentElementValue];
        _currentElementValue = nil;
        return;
    }
    
    // Course ECTS
    if ([elementName isEqualToString:@"ects"]) {
        [self.aCourse setEcts: _currentElementValue];
        _currentElementValue = nil;
        return;
    }
    
    // Staff Name
    if ([elementName isEqualToString:@"member"]) {
        [self.aStaffEntry setName: _currentElementValue];
        _currentElementValue = nil;
        return;
    }
    
    // Date text
    if ([elementName isEqualToString:@"text"]) {
        [self.aDateEntry setText: _currentElementValue];
        _currentElementValue = nil;
        return;
    }
    
    // Date prefix
    if ([elementName isEqualToString:@"prefix"]) {
        [self.aDateEntry setPrefix: _currentElementValue];
        _currentElementValue = nil;
        return;
    }
    
    // Date weekDay
    if ([elementName isEqualToString:@"weekDay"]) {
        [self.aDateEntry setWeekDay: _currentElementValue];
        _currentElementValue = nil;
        return;
    }
    
    // Date startRange
    if ([elementName isEqualToString:@"startRange"]) {
        [self.aDateEntry setStartRange: _currentElementValue];
        _currentElementValue = nil;
        return;
    }
    
    // Date endRange
    if ([elementName isEqualToString:@"endRange"]) {
        [self.aDateEntry setEndRange: _currentElementValue];
        _currentElementValue = nil;
        return;
    }
    
    // Date room
    if ([elementName isEqualToString:@"room"]) {
        [self.aDateEntry setRoom: _currentElementValue];
        _currentElementValue = nil;
        return;
    }
    
    // Date dayStart
    if ([elementName isEqualToString:@"dayStart"]) {
        [self.aDateEntry setDayStart: _currentElementValue];
        _currentElementValue = nil;
        return;
    }
    
    // Date dayEnd
    if ([elementName isEqualToString:@"dayEnd"]) {
        [self.aDateEntry setDayEnd: _currentElementValue];
        _currentElementValue = nil;
        return;
    }
    
    
    // Finished Staff
    if ([elementName isEqualToString:@"staff"]) {
        [self.aStaffEntry setBelongsToCourseStaff: _aCourse];
        [self.aCourse addHasStaffObject: _aStaffEntry];
        
        _aStaffEntry = nil;
        _currentElementValue = nil;
        return;
    }
    
    // Finished Date
    if ([elementName isEqualToString:@"date"]) {
        [self.aDateEntry setBelongsToCourseDate: _aCourse];
        [self.aCourse addHasDateObject: _aDateEntry];
        _aDateEntry = nil;
        _currentElementValue = nil;
        return;
    }
    
    // Finished Course
    if ([elementName isEqualToString:@"course"]) {
        [self.aCourse setBelongsToSubject: _aSubject];
        [self.aSubject addHasCoursesObject: _aCourse];
        _aCourse = nil;
        _currentElementValue = nil;
        return;
    }
    
    // Finished Subject
    if ([elementName isEqualToString:@"subject"]) {
        [self.aSubject setFile: _currentSubject];
        _currentElementValue = nil;
        return;
    }
    
            
}
//Ist das Dokument fertig geparsed wird dem Delegate bescheidgegeben das auf die Daten zugegriffen werden kann! Zudem werden die Daten in die Datenbank geschrieben.
-(void)parserDidEndDocument:(NSXMLParser *)parser
{
    [self.delegate coursesDataManager:self loadedCourses:self.subjectCourses loadedSubject:self.aSubject];
    [self loadDataIntoDatabase:self.coursesDatabase];
    
    _currentSubject = nil;
    _currentElementValue = nil;
    _dataStorage = nil;
    _aSubject = nil;
}


//Bei Fehlern werden diese zunaechst auf die Konsole ausgegeben
-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    NSLog(@"Parsing error - %@", [parseError localizedDescription]);
}

#pragma mark - Database

//Lade Daten aus der Courses Property in die Datenbank
- (void)loadDataIntoDatabase:(UIManagedDocument *)document
{  
    [self.coursesDatabase saveToURL:self.coursesDatabase.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler: ^(BOOL success){
        NSLog(@"saved database");
    }];
}


@end
