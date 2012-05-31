//
//  Veranstaltung+Create.m
//  eStudent
//
//  Created by Nicolas Autzen on 02.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Veranstaltung+Create.h"

@implementation Veranstaltung (Create)

+ (Veranstaltung *)veranstaltungWithTitle:(NSString *)t 
                                      ort:(NSString *)o 
                                      art:(NSString *)a
                                wochentag:(NSString *)w 
                             anfangsdatum:(NSDate *)ad 
                              anfangszeit:(NSString *)az
                                 enddatum:(NSDate *)ed
                                  endzeit:(NSString *)ez
                                inContext:(NSManagedObjectContext *)context
{
    Veranstaltung *veranstaltung = [NSEntityDescription insertNewObjectForEntityForName:@"Veranstaltung"                                inManagedObjectContext:context];
    veranstaltung.titel = t;
    veranstaltung.ort = o;
    veranstaltung.veranstaltungsart = a;
    veranstaltung.wochentag = w;
    veranstaltung.anfangsdatum = ad;
    veranstaltung.anfangszeit = az;
    veranstaltung.enddatum = ed;
    veranstaltung.endzeit = ez;
    
    return veranstaltung;
}



@end
