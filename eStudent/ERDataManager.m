//
//  ERDataManager.m
//  eStudent
//
//  Created by Christian Rathjen on 15.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



#import "ERDataManager.h"

//Import CoreDataObject Subclass Categories
#import "Criterion+Criterion_Manage.h"
#import "Course+Course_Manage.h"
#import "Choosable+Choosable_Manage.h"
#import "Optional+Optional_Manage.h"




@interface ERDataManager() 

- (void)useDocument;
- (void)loadDocument;
- (void)setupDatabaseConnection;
- (void)getXMLDataFromNetwork;
- (BOOL)DataBaseAlreadyContainsRegulation:(NSString *)aSubject;
- (BOOL)DataBaseAlreadyContainsRegulationFile:(NSString *)fileName;


@property (nonatomic, strong) NSString *regulation;
@property (nonatomic, strong) NSString *currentURL;
@property (nonatomic, strong) NSMutableData *dataStorage; //Databuffer fuer die zu parsende XML
@property (nonatomic, strong) NSMutableString *currentElementValue; //Stringbuffer fuer den XML Parser (falls benoetigt)
@property (nonatomic, strong) ExamRegulations *currentExamRegulation;
@property (nonatomic, strong) Choosable *currentChoosable;
@property (nonatomic, strong) Optional *currentOptional;
@property (nonatomic, strong) Category *currentCategory;

@end

@implementation ERDataManager

@synthesize dataStorage = _dataStorage;
@synthesize currentElementValue = _currentElementValue;
@synthesize document = _document;
@synthesize delegate = _delegate;
@synthesize regulation = _regulation;
@synthesize currentURL = _currentURL;

//Zwischenspeicher zu CoreData instanzen zum erstellen abhaengiger Instanzen
@synthesize currentCategory, currentChoosable, currentOptional, currentExamRegulation;



- (void)getAllRegulations;
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ExamRegulations"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"subject" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    [self.delegate ERAllRegulations:[self.document.managedObjectContext executeFetchRequest:request error:nil]];//return Regulations to Delegate Class
}


//Diese methode gibt nur True zurueck falls entweder die Vak oder der Titel genau mit einem Kurs uebereinstimmt.(Vlt noch weiter ausbauen das teilhits auch YEs ergeben?)
- (void)RegulationsContainingCourse:(NSString *)name orVak:(NSString *)vak
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ExamRegulations"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"subject" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    NSArray *regulations = [self.document.managedObjectContext executeFetchRequest:request error:nil];
    NSMutableArray *regulationsWithCourse = [NSMutableArray array];
    
    for (ExamRegulations *aRegulation in regulations) {
        BOOL containsCourse = NO;
        for (Category *aCategory in aRegulation.categories) {
            for (Course_ER *aCourse in aCategory.courses) {
                if ([aCourse.name isEqualToString:name] || [aCourse.vak isEqualToString:vak]) {
                    containsCourse = YES;
                }
            }
            //If there is a Choosable with at least one passed course the passed cpourse is added to the passedArray. If no course is passed all of the choices are added to the awaitingArray
            for (Choosable *aChoosable in aCategory.hasChoice) {
                for (Course_ER *aCourse in aChoosable.choices) {
                    if ([aCourse.name isEqualToString:name] || [aCourse.vak isEqualToString:vak]) {
                        containsCourse = YES;
                    } 
                }
                
            }
        }
        if (containsCourse) {
            [regulationsWithCourse addObject:aRegulation];
        }
    }
    [self.delegate ERCourseAlreadyInRegulation:[regulationsWithCourse copy]];
    
}

//Legt einen Uebergebenen Kurs in  der Kategorie MISC ab, falls MISC nicht existiert wird MISC erstellt
- (void)createCourse:(NSString *)title withVak:(NSString *)vak withCP:(NSNumber *)cp inRegulation:(ExamRegulations *)aRegulation
{
    Category *miscCategory = nil;
    for (Category *aCat in aRegulation.categories) {
        if ([aCat.name isEqualToString:@"Importierte Kurse"]) {
            miscCategory = aCat;
        }
    }
    if (!miscCategory) {
        miscCategory = [Category categoryWithParsedData:@"Importierte Kurse" inExamRegulation:aRegulation inManagedObjectContext:self.document.managedObjectContext];
    }
    
    [Course_ER courseWithParsedData:cp withDuration:nil name:title necCP:nil vakNumber:vak inCategory:miscCategory isChoosbale:nil inManagedContext:self.document.managedObjectContext];
    
    [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
        if (success){
            [self.delegate ERCourseCreatedSuccessfully];
        }
    }];
}



- (void)saveExamRegulation:(NSString *)regulation
                   address:(NSString *)address
{
    if (_dataStorage) self.dataStorage = nil;
    self.regulation = regulation;
    self.currentURL = address;
    [self setupDatabaseConnection]; 
}

- (void)saveEmptyRegulation:(NSString *)title date:(NSString *)date degree:(NSString *)degree cp:(NSString *)cp faculty:(NSString *)faculty
{
    [ExamRegulations examRegulationWithParsedData:[NSNumber numberWithInt:[cp intValue]] regulationName:title facultyNr:[NSNumber numberWithInt:[faculty intValue]] regulationDate:date subject:title degree:degree inManagedContext:self.document.managedObjectContext];
    [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
        NSLog(@"saving Database complete");
        [self.delegate ERSavingComplete:self];
    }];
}

- (void)createNewCategorie:(NSString *)name inRegulation:(ExamRegulations *)aRegualtion
{
    [Category categoryWithParsedData:name inExamRegulation:aRegualtion inManagedObjectContext:self.document.managedObjectContext];
    [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
        NSLog(@"saving Database complete");
        [self.delegate ERSavingComplete:self];
    }];
}

- (void)accessDatabase
{
    [self setupDatabaseConnection];
}

#pragma mark - Property access
//If Database Document is set, UseDocument is caled to open/create/use it
- (void) setDocument:(UIManagedDocument *)document
{
    if (_document != document){
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
        document.persistentStoreOptions = options;
        _document = document;
        if (self.currentURL) {
            [self useDocument];
        }else {
            [self loadDocument];
        }
    }
}


#pragma mark - Download XML data from network
//Checks if parsing is needed. If so download is started
- (void)getXMLDataFromNetwork {
    if (![self DataBaseAlreadyContainsRegulationFile:self.regulation]){
            NSString *aString = [NSString stringWithFormat:@"%@%@",BPO_Regulation,self.currentURL];
            NSURLRequest *dataRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:aString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
            NSURLConnection *dataConnection = [[NSURLConnection alloc] initWithRequest:dataRequest delegate:self];
            
            if (dataConnection) {
                self.dataStorage = [NSMutableData data];
                NSLog(@"connection established");
            } else {
                NSLog(@"Connection failed");
            }
            
    }else {
        //delegate needs to know there is nothing to download
        [self.delegate ERRegulationAlreadyPersistent];
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.dataStorage setLength:0];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (self.dataStorage) {
        [self.dataStorage appendData:data];
    } else {
        self.dataStorage = [self.dataStorage initWithData:data];
    }
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{
    NSLog(@"Connection failed: %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.dataStorage];
    [parser setDelegate:self];
    NSLog(@"start parsing");
    [parser parse];
}

#pragma mark - Parse downloaded XML data
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
    NSLog(@"Error while parsing %@",[parseError description]);
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict 
{
    if ([elementName isEqualToString:@"main"]) {
        ExamRegulations *aRegulation = [ExamRegulations examRegulationWithParsedData:[NSNumber numberWithInt:[[attributeDict objectForKey:@"cp"] intValue]] regulationName:self.regulation facultyNr:[NSNumber numberWithInt:[[attributeDict objectForKey:@"facultyNr"] intValue]] regulationDate:[attributeDict objectForKey:@"regulationDate"] subject:[attributeDict objectForKey:@"subject"] degree:[attributeDict objectForKey:@"degree"] inManagedContext:self.document.managedObjectContext];
            self.currentExamRegulation = aRegulation;
            NSLog(@"regulation added:%@", aRegulation.subject);
            return;

        
    } else if ([elementName isEqualToString:@"course"]) {
        if (self.currentChoosable) {
            [Course_ER courseWithParsedData:[NSNumber numberWithInt:[[attributeDict objectForKey:@"cp"] intValue]] withDuration:[NSNumber numberWithInt:[[attributeDict objectForKey:@"duration"] intValue]] name:[attributeDict objectForKey:@"name"] necCP:[NSNumber numberWithInt:[[attributeDict objectForKey:@"neccP"] intValue]] vakNumber:[attributeDict objectForKey:@"vak"] inCategory:nil isChoosbale:self.currentChoosable inManagedContext:self.document.managedObjectContext];
            NSLog(@"Course Added With Choosable: %@",[attributeDict objectForKey:@"name"]);
            return;
        }else {
            [Course_ER courseWithParsedData:[NSNumber numberWithInt:[[attributeDict objectForKey:@"cp"] intValue]] withDuration:[NSNumber numberWithInt:[[attributeDict objectForKey:@"duration"] intValue]] name:[attributeDict objectForKey:@"name"] necCP:[NSNumber numberWithInt:[[attributeDict objectForKey:@"neccP"] intValue]] vakNumber:[attributeDict objectForKey:@"vak"] inCategory:self.currentCategory isChoosbale:nil inManagedContext:self.document.managedObjectContext];
            NSLog(@"Course Added: %@",[attributeDict objectForKey:@"name"]);
            return;
        }
    } else if ([elementName isEqualToString:@"category"]) {
        Category *aCategory = [Category categoryWithParsedData:[attributeDict objectForKey:@"name"] inExamRegulation:self.currentExamRegulation inManagedObjectContext:self.document.managedObjectContext];
        self.currentCategory = aCategory;
        NSLog(@"Categorie added: %@", aCategory.name);
        return;
    } else if ([elementName isEqualToString:@"optional"]) {
        Optional *anOptional = [Optional anOptionalWithParsedData:[NSNumber numberWithInt:[[attributeDict objectForKey:@"cp"] intValue]] name:[attributeDict objectForKey:@"name"] vakNumber:[attributeDict objectForKey:@"vak"] inCategory:self.currentCategory inManagedObjectContext:self.document.managedObjectContext];
        self.currentOptional = anOptional;
        NSLog(@"Optional added: %@ - %@ - %@", anOptional.vak, anOptional.name, anOptional.cp);
        return;
    } else if ([elementName isEqualToString:@"choosable"]) {
        Choosable *aChoosable = [Choosable choosableWithParsedData:self.currentCategory withName:[attributeDict objectForKey:@"name"] cp:[NSNumber numberWithInt:[[attributeDict objectForKey:@"cp"] intValue]] duration:[NSNumber numberWithInt:[[attributeDict objectForKey:@"duration"] intValue]] inManagedObjectContext:self.document.managedObjectContext];
        self.currentChoosable = aChoosable;
        NSLog(@"choosable added");
        return;
    }  else if ([elementName isEqualToString:@"criterion"]) {
        [Criterion criterionWithParsedData:[attributeDict objectForKey:@"name"] note:[attributeDict objectForKey:@"note"] inCategory:self.currentCategory inContext:self.document.managedObjectContext];
        NSLog(@"criterion added, %@",[attributeDict objectForKey:@"name"]);
        return;
    }
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)aString
{
    if (!self.currentElementValue) {
        self.currentElementValue = [[NSMutableString alloc] initWithString:aString];
    }else{
        [self.currentElementValue appendString:aString]; //Wenn schon Text innerhalb des aktuellen Tags gefunden wurde wird der neue Text nur hinzugefuegt
    }
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"category"]) {
        self.currentCategory = nil;
        return;
    }  else if ([elementName isEqualToString:@"choosable"]) {
        self.currentChoosable = nil;
        return;
    } else if ([elementName isEqualToString:@"optional"]) {
        self.currentOptional = nil;
        return;
    } else if ([elementName isEqualToString:@"criterion"]) {
        return;
    }
}

-(void)parserDidEndDocument:(NSXMLParser *)parser 
{
    //parsing is done
    //can't tell delegate that parsing is done because of asyncronous CoreDate save calls
    NSLog(@"parsing complete saving data");
    [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
        NSLog(@"saving Database complete");
        [self.delegate ERSavingComplete:self];
        }];
    
    self.dataStorage = nil;
    self.currentElementValue = nil;
    
    self.currentChoosable = nil;
    self.currentCategory = nil;
    self.currentExamRegulation = nil;
    self.currentOptional = nil;
}





#pragma mark - Database
//Regulation Databasefiles are saved in ~/Documents/Regulations/*filename*
- (void)setupDatabaseConnection
{
    NSURL *filePath = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    filePath = [filePath URLByAppendingPathComponent:@"Regulations"];
    if (!self.document) {
        self.document = [[UIManagedDocument alloc]initWithFileURL:filePath];
    }
}
//Searches for eistings Database entries with a subject
- (BOOL)DataBaseAlreadyContainsRegulation:(NSString *)aSubject
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ExamRegulations"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"subject" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"subject = %@", aSubject];
    NSError *error = nil;
    NSArray *results = [self.document.managedObjectContext executeFetchRequest:request error:&error];
    if ([results count] > 0)
    {
        NSLog(@"This Regulation is already in the database");
        [self.delegate ERDocumentIsReady:self];
        return YES;
    } else {
        NSLog(@"Regulation not found");
        return NO;
    }
    
    
}
//Searches for eistings Database entries with a filename
//prefered
-(BOOL)DataBaseAlreadyContainsRegulationFile:(NSString *)fileName
{
    
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ExamRegulations"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"fileName" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"fileName = %@", fileName];
    NSError *error = nil;
    NSArray *results = [self.document.managedObjectContext executeFetchRequest:request error:&error];
    if ([results count] > 0)
    {
        NSLog(@"Entry found - using existing entry. Mad shit.");
        return YES;
    } else {
        return NO;
    }
}
//Database is created/opened/ready
- (void)useDocument
{
    NSLog(@"FilePath: %@", [self.document.fileURL path]);
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.document.fileURL path]]) {
        NSLog(@"creating new datbase");
        [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            [self getXMLDataFromNetwork];
            if ([[NSFileManager defaultManager] fileExistsAtPath:[self.document.fileURL path]]) NSLog(@"there is now a Database stored");
            
        }];
    } else if (self.document.documentState == UIDocumentStateClosed) {
        [self.document openWithCompletionHandler:^(BOOL success) {
            NSLog(@"Database opened");
            [self getXMLDataFromNetwork];
        }];
    } else if (self.document.documentState == UIDocumentStateNormal) {
        [self getXMLDataFromNetwork];
    }
}

- (void)loadDocument
{
    NSLog(@"FilePath: %@", [self.document.fileURL path]);
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.document.fileURL path]]) {
        NSLog(@"no Database found pls add some Regulations");
        [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            //tell the view that there is no data
            if ([[NSFileManager defaultManager] fileExistsAtPath:[self.document.fileURL path]]) NSLog(@"there is now a Database stored");
            [self.delegate ERNoDataStored:self];
        }];
    } else if (self.document.documentState == UIDocumentStateClosed) {
        [self.document openWithCompletionHandler:^(BOOL success) {
            NSLog(@"Database opened");
            [self.delegate ERDocumentIsReady:self];
        }];
    } else if (self.document.documentState == UIDocumentStateNormal) {
        [self.delegate ERDocumentIsReady:self];
    }
}

-(void)deleteCategory:(Category *)aCategory
{
    for (Course_ER *aCourse in aCategory.courses) {
        [self.document.managedObjectContext deleteObject:aCourse];
    }
    for (Choosable *aChoosable in aCategory.hasChoice) {
        [self.document.managedObjectContext deleteObject:aChoosable];
    }
    for (Optional *anOptional in aCategory.optional) {
        [self.document.managedObjectContext deleteObject:anOptional];
    }
    for (Criterion *aCriterion in aCategory.criteria) {
        [self.document.managedObjectContext deleteObject:aCriterion];
    }
    [self.document.managedObjectContext deleteObject:aCategory];
    [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
        NSLog(@"Saving after deletion of a Categorie");
    }];
}

- (void)deleteRegulation:(ExamRegulations *)aRegulation
{
    for (Category *aCategory in aRegulation.categories) {
        for (Course_ER *aCourse in aCategory.courses) {
            [self.document.managedObjectContext deleteObject:aCourse];
        }
        for (Choosable *aChoosable in aCategory.hasChoice) {
            [self.document.managedObjectContext deleteObject:aChoosable];
        }
        for (Optional *anOptional in aCategory.optional) {
            [self.document.managedObjectContext deleteObject:anOptional];
        }
        for (Criterion *aCriterion in aCategory.criteria) {
            [self.document.managedObjectContext deleteObject:aCriterion];
        }
        [self.document.managedObjectContext deleteObject:aCategory];
    }
    [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
        [self.document.managedObjectContext deleteObject:aRegulation];
        [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
            NSLog(@"Saving after deletion of a Regulation");
        }];
    }];
    //delete aRegulation
    
}

- (void)closeDatabaseConnection {
    if (self.document.documentState == UIDocumentStateNormal) {
        [self.document closeWithCompletionHandler:^(BOOL success){
            if (success) {
                NSLog(@"Datenbank geschlossen!");
            }
        }];
    }
}
@end
