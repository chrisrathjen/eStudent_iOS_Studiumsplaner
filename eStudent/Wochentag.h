//
//  Wochentag.h
//  eStudent
//
//  Created by Nicolas Autzen on 28.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Veranstaltung;

@interface Wochentag : NSManagedObject

@property (nonatomic, retain) NSString * wochentag;
@property (nonatomic, retain) NSSet *veranstaltungen;
@end

@interface Wochentag (CoreDataGeneratedAccessors)

- (void)addVeranstaltungenObject:(Veranstaltung *)value;
- (void)removeVeranstaltungenObject:(Veranstaltung *)value;
- (void)addVeranstaltungen:(NSSet *)values;
- (void)removeVeranstaltungen:(NSSet *)values;

@end
