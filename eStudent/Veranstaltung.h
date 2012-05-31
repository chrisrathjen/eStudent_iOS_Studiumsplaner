//
//  Veranstaltung.h
//  eStudent
//
//  Created by Nicolas Autzen on 26.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Veranstaltung : NSManagedObject

@property (nonatomic, retain) NSDate * anfangsdatum;
@property (nonatomic, retain) NSString * anfangszeit;
@property (nonatomic, retain) NSDate * enddatum;
@property (nonatomic, retain) NSString * endzeit;
@property (nonatomic, retain) NSString * ort;
@property (nonatomic, retain) NSString * titel;
@property (nonatomic, retain) NSString * veranstaltungsart;
@property (nonatomic, retain) NSString * wochentag;
@property (nonatomic, retain) NSNumber * hidden;

@end
