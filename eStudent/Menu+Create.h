//
//  Menu+Create.h
//  mensa_data
//
//  Created by Christian Rathjen on 22.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Menu.h"
//Diese Kategorie erweitert die Datenbank Entity Menu um eine Methode zum erstellen neuer Menu-Eintraege.
@interface Menu (Create)
+ (Menu *)menuFromParsedData:(NSString *)location
               weekOftheYear:(NSString *)week
            inManagedContext:(NSManagedObjectContext *)context;
@end
