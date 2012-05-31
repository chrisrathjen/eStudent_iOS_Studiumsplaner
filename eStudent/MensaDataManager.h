//
//  MensaDataFetcher.h
//  mensa_data
//
//  Created by Christian Rathjen on 11.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
//  Der Mensa Datenmanager benoetigt CoreData


#import <Foundation/Foundation.h>

@class MensaDataManager;
@protocol MensaDataManagerDelegate
@optional
- (void)mensaDataManager:(MensaDataManager *)sender loadedMenu:(NSMutableDictionary *)menu;
- (void)noDataToParse:(MensaDataManager *)sender;
- (void)noNetworkConnection:(MensaDataManager *)sender localizedError:(NSString *)errorString;
@end


@interface MensaDataManager : NSObject <NSXMLParserDelegate>
- (void)getXMLDataFromServer:(NSString *)Mensa; //Hier kann der Name der Mensa angegeben werden deren Daten geladen werden sollen(uni, gw2, air, ...)!

@property (nonatomic, weak) id <MensaDataManagerDelegate> delegate; //Delegate gibt Auskunft wann die Daten zur verfügung stehen
@property (nonatomic, strong) NSMutableDictionary *Menu; // Enthält den Speiseplan nach erfolgreichem parsen / ladem vom Speicher
@property (nonatomic, strong) UIManagedDocument *menuDatabase; //Enthält die Verbindung zur Datenbank

@end
