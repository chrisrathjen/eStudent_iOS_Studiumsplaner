//
//  MensaDataFetcher.m
//  mensa_data
//
//  Created by Christian Rathjen on 11.12.11.
//  Copyright (c) 2011 eStudent - iOS Dev Divsion. All rights reserved.

// Diese Klasse kann Mensaspeisepläne sowohl aus dem Internet als auch aus dem lokalem Speicher laden und den Anwendungen zur Verfügung stellen!
 

#import "MensaDataManager.h"
#import "foodEntry.h"
#import "Food+Create.h"
#import "Day+Create.h"
#import "Menu+Create.h"




@interface MensaDataManager()

- (void)useDocument;
- (void)getDataFromNetwork:(NSString *)Mensa;
- (void)loadDatabaseConnection;
- (void)loadDataFromDisk;
- (void)startParsingData;
- (void)setMenu:(NSMutableDictionary *)Menu key:(NSString *)key;
- (void)loadDataIntoDatabase:(UIManagedDocument *)document;
- (void)startParsingData;

@property (nonatomic, strong) NSMutableData *dataStorage; // Enthält die XML nach erfolgreichem herrunterladen
@property (nonatomic, strong) NSMutableString *currentElementValue; // Stringbuffer für den xml Parser
@property (nonatomic, strong) NSMutableDictionary *currentMenu; // Dient zur temporären Ablage der Essen enes Tages 
@property (nonatomic, strong) foodEntry *aFoodEntry;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *weekOfTheYear;
@property (nonatomic, strong) NSString *foodOrder;
@end


@implementation MensaDataManager

@synthesize delegate = _delegate;
@synthesize dataStorage = _dataStorage;
@synthesize currentElementValue = _currentElementValue;
@synthesize Menu = _Menu;
@synthesize currentMenu = _currentMenu;
@synthesize aFoodEntry = _aFoodEntry;
@synthesize location = _location;
@synthesize weekOfTheYear = _weekOfTheYear;
@synthesize menuDatabase = _menuDatabase;
@synthesize foodOrder = _foodOrder;


//Diese Methode baut eine Verbindung zum Server auf und laed den aktuellen Speiseplan herrunter.


#pragma mark - Property access

-(void)setMenu:(NSMutableDictionary *)Menu key:(NSString *)key
{
    if (!_Menu) {
        _Menu = [[NSMutableDictionary alloc] init];
    }
    [_Menu setObject:Menu forKey:key];
}
-(void)setMenu:(NSMutableDictionary *)Menu{
    if (!_Menu){
        _Menu = [[NSMutableDictionary alloc] init];
        _Menu = Menu;
    }
}
-(void)setMenuDatabase:(UIManagedDocument *)menuDatabase
{
    if (_menuDatabase != menuDatabase) {
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
        menuDatabase.persistentStoreOptions = options;
        _menuDatabase = menuDatabase;
        [self useDocument];
    }
}


- (NSString *)getWeek {
    NSDate *date = [NSDate date];
    NSDateFormatter *weekFormatter = [[NSDateFormatter alloc] init];
    [weekFormatter setDateFormat:@"w"];
    NSString *weekDateString = [weekFormatter stringFromDate:date];
    return weekDateString = [NSString stringWithFormat:@"%i",[weekDateString integerValue] - 1];
}


#pragma mark - Startup

//Setzt Propertys und startet die Verbindung zur Datenbank
- (void)getXMLDataFromServer:(NSString *)Mensa
{

    self.location = Mensa;
    self.weekOfTheYear = [self getWeek];
    //NSLog(@"Aktuelle Woche: %@", [self getWeek]);
    if (_dataStorage) _dataStorage = nil;
    [self loadDatabaseConnection];

}


-(void)getDataFromNetwork:(NSString *)Mensa;
{
    NSURLRequest *dataRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://17.foodspl.appspot.com/mensa?id=%@", Mensa]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    NSURLConnection *dataConnection = [[NSURLConnection alloc] initWithRequest:dataRequest delegate:self];
    
    if (dataConnection) {
        _dataStorage = [NSMutableData data];
    }else{
        NSLog(@"Connection failed");
    }
}



#pragma mark - Network Connection
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
        NSLog(@"Downloaded stuff");
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
#pragma mark - Parsing Network Data

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
    
    //Bei jedem neuen Essen wird der temporäre Essen's Objekt zurückgesetzt 
    if ([elementName isEqualToString:@"food"]) {
        _aFoodEntry = [[foodEntry alloc] init];
        return;
    }
    
    //Bei jedem neuen Tag wird der Tages-Speiseplan zurückgesetzt. Der vorherriege inhalt wird vorher in einer anderen Methode gespeichert
    if ([elementName isEqualToString:@"mon"]) {
        if (!_currentMenu) _currentMenu = [[NSMutableDictionary alloc]init];
        return;
    }else if ([elementName isEqualToString:@"tue"]) {
        if (!_currentMenu) _currentMenu = [[NSMutableDictionary alloc]init];
        return;
    }else if ([elementName isEqualToString:@"wed"]) {
        if (!_currentMenu) _currentMenu = [[NSMutableDictionary alloc]init];
        return;
    }else if ([elementName isEqualToString:@"thu"]) {
        if (!_currentMenu) _currentMenu = [[NSMutableDictionary alloc]init];
        return;
    }else if ([elementName isEqualToString:@"fri"]) {
        if (!_currentMenu) _currentMenu = [[NSMutableDictionary alloc]init];
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
}

//Die Methode wird aufgerufen wenn ein Tag geschlossen wird. Hier werden dann die bereitsgespeicherten Texte in die foodEntry Objekte gespeichert und die Objekte in die Tages Dictinaries und die Tages Dicts ins Menu Dictionary.
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    
    //Ein foodEntry Objekt mit den Daten des aktuellen Essen's befuellen
    if ([elementName isEqualToString:@"name"]) {
        [self.aFoodEntry setName:_currentElementValue];
        _currentElementValue = nil;
        return;
    }else if ([elementName isEqualToString:@"desc"]){
        [self.aFoodEntry setFoodDescription:_currentElementValue];
        _currentElementValue = nil;
        return;
    }else if ([elementName isEqualToString:@"type"]){
        [self.aFoodEntry setType:_currentElementValue];
        _currentElementValue = nil;
        return;
    }else if ([elementName isEqualToString:@"extra"]){
        [self.aFoodEntry setExtra:_currentElementValue];
        _currentElementValue = nil;
        return;
    }else if ([elementName isEqualToString:@"student"]){
        [self.aFoodEntry setStudentPrice:_currentElementValue];
        _currentElementValue = nil;
        return;
    }else if ([elementName isEqualToString:@"staff"]){
        [self.aFoodEntry setStaffPrice:_currentElementValue];
        _currentElementValue = nil;
        return;
    }

    
    //Ist das Ende des aktuellen Essen's Tag erreicht wird das essen's objekt in das Tagesmenü gespeichert
    if([elementName isEqualToString:@"food"]){
        if (!self.foodOrder){
            self.foodOrder = @"1";
        }
        self.aFoodEntry.order = self.foodOrder;
        self.foodOrder = [NSString stringWithFormat:@"%d",[self.foodOrder intValue] + 1];
        [_currentMenu setObject:_aFoodEntry forKey:[NSString stringWithFormat:@"%@", [self.aFoodEntry name]]];
        _aFoodEntry = nil;
        return;
    }   
    //Tag fertig geparsed:
    if ([elementName isEqualToString:@"mon"]) {
       // [_Menu setObject:_currentMenu forKey:@"Monday"];
        [self setMenu:_currentMenu key:@"Monday"];
        _currentMenu = nil;
        self.foodOrder = nil;
        return;
    }else if ([elementName isEqualToString:@"tue"]) {
        [self setMenu:_currentMenu key:@"Tuesday"];
        _currentMenu = nil;
        self.foodOrder = nil;
        return;
    }else if ([elementName isEqualToString:@"wed"]) {
        [self setMenu:_currentMenu key:@"Wednesday"];
        _currentMenu = nil;
        self.foodOrder = nil;
        return;
    }else if ([elementName isEqualToString:@"thu"]) {
        [self setMenu:_currentMenu key:@"Thursday"];
        _currentMenu = nil;
        self.foodOrder = nil;
        return;
    }else if ([elementName isEqualToString:@"fri"]) {
        [self setMenu:_currentMenu key:@"Friday"];
        _currentMenu = nil;
        self.foodOrder = nil;
        return;
    }
    
}
//Ist das Dokument fertig geparsed wird dem Delegate bescheidgegeben das auf die Daten zugegriffen werden kann! Zudem werden die Daten in die Datenbank geschrieben.
-(void)parserDidEndDocument:(NSXMLParser *)parser
{
    if ([self.Menu objectForKey:@"Monday"]) {
        [self.delegate mensaDataManager:self loadedMenu:[self.Menu mutableCopy]];
        [self loadDataIntoDatabase:self.menuDatabase];
    }else {
        [self.delegate noDataToParse:self];
    }
    
    
    _currentMenu = nil;
    _aFoodEntry = nil;
    _currentElementValue = nil;
    _dataStorage = nil;
}


//Bei Fehlern werden diese zunaechst auf die Konsole ausgegeben
-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    NSLog(@"Parsing error - %@", [parseError localizedDescription]);
}

#pragma mark - Database

//Sucht Einträge die nicht mehr aktuell sind und löscht diese aus der Datenbank

-(void)deleteOldEntries:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Menu"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"week" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"(location == %@) AND (week != %@)", self.location, self.weekOfTheYear];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    for (Menu *aMenu in results) {
        NSSet *days = aMenu.days;
        for (Day *day in days) {
            NSSet *foods = day.foods;
            for (Food *aFood in foods) {
                [context deleteObject:aFood];
            }
            [context deleteObject:day];
        }
        [context deleteObject:aMenu];
    }    
}

//Lade Daten aus der Menu Property in die Datenbank
- (void)loadDataIntoDatabase:(UIManagedDocument *)document
{
    NSEnumerator *enumerator = [self.Menu keyEnumerator];//Iterator fuer die Wochentage in Menu
    NSString * key;
    
    //Neues Menu erstellen
    Menu *aMenu = [Menu menuFromParsedData:self.location weekOftheYear:self.weekOfTheYear inManagedContext:document.managedObjectContext];
    
    //Benutze Iterator um alle Wochentage einzutragen (key enthaelt den Wochentag)
    while (key = [enumerator nextObject]){
        Day *aDay = [Day dayWithParsedData:key location:aMenu inManagedContext:document.managedObjectContext];
        NSEnumerator *dayEnumerator = [[self.Menu objectForKey:key] keyEnumerator];
        NSString *meal; 
        //Iterator fuer die Speisen des aktuellen Tages
        while (meal = [dayEnumerator nextObject]) {
            foodEntry *aFoodEntry = [[self.Menu objectForKey:key] objectForKey:meal];
            [Food foodWithFoodEntry:aFoodEntry orderString:aFoodEntry.order onDayOfTheWeek:aDay inManagedContext:document.managedObjectContext];
            //Ordnungsnummer fuer die Reihenfolge der Eintragung  
        }

    }
    
    [self.menuDatabase saveToURL:self.menuDatabase.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler: ^(BOOL success){
        NSLog(@"saved database");
    }];
}

//Diese Methode sucht nach einer lokalen Datenbank fuer die aktuelle Mensa (und erstellt diese falls nicht vorhanden). Jenachdem in welchem Zustand die Datenbank ist wird diese erstellt oder genutzt. Muss sie erstellt werden sind auch keine lokalen Mensadatenverfuegbar und ein neuer Datensatz wird geparsed und danach abgespeichert. Ist bereits eine Datenbank vorhanden und verfuegbar wird ueberprueft ob die Datenbank einen aktuellen Datensatz enthaellt. Ist dies nicht der Fall wird eine neue Version geparsed und gespeichert. Fuer den Fall das ein aktueller Datensatz vorhanden ist wird diese geladen
-(void)useDocument{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.menuDatabase.fileURL path]]){
        //Falls die Datei nicht existiert wird sie erstellt
        [self.menuDatabase saveToURL:self.menuDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success){
            [self getDataFromNetwork:self.location];
            if ([[NSFileManager defaultManager] fileExistsAtPath:[self.menuDatabase.fileURL path]]) NSLog(@"there is now a Databased stored");
             }];
        } else if (self.menuDatabase.documentState == UIDocumentStateClosed){
            //NSLog(@"oeffne bestehende DB");
            [self.menuDatabase openWithCompletionHandler:^(BOOL success){
                NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Menu"];
                request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"week" ascending:YES]];
                request.predicate = [NSPredicate predicateWithFormat:@"week = %@", [self getWeek]];
                NSError *error = nil;
                NSArray *results = [self.menuDatabase.managedObjectContext executeFetchRequest:request error:&error];
                //NSLog(@"Es befinden sich %d Menues in der DB", [results count]);
                
                if ([results count] > 0)//Ist ein Datensatz gefunden kann dieser geladen werden
                {
                    [self loadDataFromDisk];
                } else {
                    [self getDataFromNetwork:self.location];
                    NSLog(@"Found database but parsing from the net");
                }
            }];
        }else if (self.menuDatabase.documentState == UIDocumentStateNormal) {
            //NSLog(@"Nutze bestehende Db");
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Menu"];
            request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"week" ascending:YES]];
            request.predicate = [NSPredicate predicateWithFormat:@"week = %@", [self getWeek]];
            NSError *error = nil;
            NSArray *results = [self.menuDatabase.managedObjectContext executeFetchRequest:request error:&error];
            
            if ([results count] > 0)//Ist ein Datensatz gefunden kann dieser geladen werden
            {
                [self loadDataFromDisk];
            } else {
                [self getDataFromNetwork:self.location];
                NSLog(@"Found database but parsing from the net");
            } 
        }
         }

//Erstelle Datenbankverknuepfung und speichere diese in der Property
- (void)loadDatabaseConnection
{
    //Suche den Document Ordner der aktuellen App
    NSURL *filePath = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask]lastObject];
    //Setzte Verzeichnissnamen fuer die aktuelle Datenbank (uni / gw2 / air / ...)
    filePath = [filePath URLByAppendingPathComponent:self.location];
    //NSLog(@"Hallo:%@",[NSString stringWithContentsOfURL:filePath]);
    //Der Setter ruft dann useDocument auf
    if (!self.menuDatabase) {
        self.menuDatabase = [[UIManagedDocument alloc] initWithFileURL:filePath];
    }
}

//Diese Datenbank laed den aktuellen Datensatz aus der Datenbank in die Property
- (void)loadDataFromDisk
{
   
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Menu"];
            request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"week" ascending:YES]];
            //Suche alle Menues fuer die aktuelle Mensa sowie Woche
            request.predicate = [NSPredicate predicateWithFormat:@"(week = %@) AND (location = %@)", [self getWeek], self.location];
            NSError *error = nil;
            NSArray *results = [self.menuDatabase.managedObjectContext executeFetchRequest:request error:&error];
    
            //Falls ein oder mehrere Datensaetze gefunden worden wird der letzte verwendet (normalerweise gibt es hier immer nur einen aktuellen Datensatz, falls es doch mehr gibt werden diese in der naechsten woche alle entfernt)
            if ([results count] > 0) {
                Menu *aMenu = [results lastObject]; //gefundenes Menu
                NSLog(@"Gespeicherte Woche: %@ wird geladen", aMenu.week); 
                NSSet *days = [[NSSet alloc] initWithSet:aMenu.days]; //Alle Tage des gefundenen Menues
                for (Day *aDay in days) {
                    NSMutableDictionary *currentMenu = [[NSMutableDictionary alloc]init];
                    NSSet *meals = [[NSSet alloc] initWithSet:aDay.foods]; // Alles Essen des aktuelen Tages
                    for (Food *aFood in meals) {
                        
                        foodEntry *aFoodEntry = [[foodEntry alloc] init];
                        
                        aFoodEntry.name = aFood.name;
                        aFoodEntry.foodDescription = aFood.foodDescription;
                        aFoodEntry.type = aFood.type;
                        aFoodEntry.extra = aFood.extra;
                        aFoodEntry.staffPrice = aFood.staffPrice;
                        aFoodEntry.studentPrice = aFood.studentPrice;
                        aFoodEntry.order = aFood.order;
                        
                        //NSLog(@"%@ - %@",aFoodEntry.name, aFoodEntry.order);
                        
                        [currentMenu setObject:aFoodEntry forKey:aFoodEntry.name];
                        aFoodEntry = nil;//Reset Essen
                    }
                    
                    [self setMenu:currentMenu key:aDay.name];//fuege TagesMenue dem WochenMenu hinzu
                    currentMenu = nil;//reset Tagesmenue
                }
                
                [self.delegate mensaDataManager:self loadedMenu:[self.Menu mutableCopy]];;//Sagt dem Delegate bescheid das die Daten nun in der Property zur Verfuegung stehen
                
            }else {
                //Dies solle nie passieren aber falls kein entsprechendes Menue gefunden wurde wird ein neues geparsed
                [self getDataFromNetwork:self.location];
            }
            
            //loesche alte Daten falls vorhanden!
    [self deleteOldEntries:self.menuDatabase.managedObjectContext];
}


@end
