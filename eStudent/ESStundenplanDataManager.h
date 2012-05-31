//
//  ESStundenplanData.h
//  eStudent
//
//  Created by Nicolas Autzen on 19.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Veranstaltung.h"

@class ESStundenplanDataManager;

@protocol ESStundenplanDataManagerDelegate
- (void)documentIsReady;
@end

@interface ESStundenplanDataManager : NSObject

@property (nonatomic,strong)UIManagedDocument *managedDocument;
@property (nonatomic)BOOL isDocumentReady;
@property (nonatomic,strong)id <ESStundenplanDataManagerDelegate> delegate;

- (void)openDocument;
- (void)useDocument;
- (void)save;
- (NSArray *)getAllVeranstaltungen;

@end
