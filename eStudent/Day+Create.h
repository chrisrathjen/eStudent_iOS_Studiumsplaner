//
//  Day+Create.h
//  mensa_data
//
//  Created by Christian Rathjen on 22.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Day.h"
#import "Menu.h"
//Diese Kategorie erweitert die Datenbank Entity Day um eine Methode zum erstellen neuer Day-Eintraege.
@interface Day (Create)
+ (Day *)dayWithParsedData:(NSString *)name
                  location:(Menu *)menu
          inManagedContext:(NSManagedObjectContext *)context;
@end
