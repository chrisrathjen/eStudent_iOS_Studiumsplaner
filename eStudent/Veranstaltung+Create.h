//
//  Veranstaltung+Create.h
//  eStudent
//
//  Created by Nicolas Autzen on 02.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Veranstaltung.h"

@interface Veranstaltung (Create)

+ (Veranstaltung *)veranstaltungWithTitle:(NSString *)t 
                                      ort:(NSString *)o 
                                      art:(NSString *)a
                                wochentag:(NSString *)w 
                             anfangsdatum:(NSDate *)ad 
                              anfangszeit:(NSString *)az
                                 enddatum:(NSDate *)ed
                                  endzeit:(NSString *)ez
                                inContext:(NSManagedObjectContext *)context;


@end
