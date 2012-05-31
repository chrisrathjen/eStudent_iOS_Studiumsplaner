//
//  ERDataManager.h
//  eStudent
//
//  Created by Christian Rathjen on 15.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


//TODO Zwei gleichnamige Studiengaenge erlauben falls der Abschluss unterschiedlich ist.

// Cp der Bestandenen Kurse sammeln und in der Uebersicht anzeigen

// Requirements fehlen  noch. Diese liegen als durch kommata getrenne Liste (String) vor. Ideal wäre eine direkte zuweisung zu den Course Objekten.

// Man könnte jeden Kurs namen derrequirements hat in einem NSDict speichern sodass man sie später öffnen kann und die requirements in der Datenbank suchent. Was ist mit kursen die nicht in der DB sind weil sie diesesSemester nicht imVorlesungsverzeichniss waren?



#import <Foundation/Foundation.h>
#import "Category+Category_Manage.h"
#import "ExamRegulations.h"
#import "ExamRegulation+ExamRegulation_Manage.h"

@class ERDataManager;
@protocol ERDataManagerDelegate
@optional
- (void)ERSavingComplete:(ERDataManager *)sender;//Database received new entries, got saved and ist ready to use
- (void)ERDocumentIsReady:(ERDataManager *)sender;//Database was opened, and is ready. No new entries were added
- (void)ERNoDataStored:(ERDataManager *)sender;//Completed searching for Regulations
- (void)ERAllRegulations:(NSArray *)allRegulations;
- (void)ERCourseAlreadyInRegulation:(NSArray *)regulationsContainenCourse;
- (void)ERCourseCreatedSuccessfully;
- (void)ERRegulationAlreadyPersistent;
@end

//TODO bekomme vak cheke ob schon eingetragen return BOOL
//TODO bekomme alle Daten zu einem kurs zum eintragen

@interface ERDataManager : NSObject <NSXMLParserDelegate>
- (void)saveExamRegulation:(NSString *)regulation
                   address:(NSString *)address;
- (void)accessDatabase;
- (void)deleteRegulation:(ExamRegulations *)aRegulation;
- (void)deleteCategory:(Category *)aCategory;
- (void)getAllRegulations;
- (void)RegulationsContainingCourse:(NSString *)name orVak:(NSString *)vak;
- (void)createCourse:(NSString *)title withVak:(NSString *)vak withCP:(NSNumber *)cp inRegulation:(ExamRegulations *)aRegulation;

@property (nonatomic, weak) id <ERDataManagerDelegate> delegate;
@property (nonatomic, strong) UIManagedDocument *document;//Datamodel

@end
