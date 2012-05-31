//
//  ESStundenplanData.m
//  eStudent
//
//  Created by Nicolas Autzen on 19.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ESStundenplanDataManager.h"
#import "Veranstaltung.h"

@implementation ESStundenplanDataManager

@synthesize isDocumentReady, delegate, managedDocument = _managedDocument;

- (void)openDocument
{
    if (!self.managedDocument) 
    {
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"Stundenplan_Database"];
        self.managedDocument = [[UIManagedDocument alloc] initWithFileURL:url];
    }
}

- (void)setManagedDocument:(UIManagedDocument *)managedDocument
{
    if (_managedDocument != managedDocument) {
        _managedDocument = managedDocument;
        [self useDocument];
    }
}

- (void)useDocument
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.managedDocument.fileURL path]]) 
    {
        [self.managedDocument saveToURL:self.managedDocument.fileURL 
                       forSaveOperation:UIDocumentSaveForCreating 
                      completionHandler:^(BOOL success){
                          if (success) {
                              self.isDocumentReady = YES;
                              [self.delegate documentIsReady];
                          }
                          else {
                              self.isDocumentReady = NO;
                          }
                      }];
    }
    else if (self.managedDocument.documentState == UIDocumentStateClosed) 
    {
        [self.managedDocument openWithCompletionHandler:^(BOOL success){
            if (success) {
                self.isDocumentReady = YES;
                [self.delegate documentIsReady];
            }
            else {
                self.isDocumentReady = NO;
            }
        }];
    }
    else if (self.managedDocument.documentState == UIDocumentStateNormal) 
    {
        self.isDocumentReady = YES;
        [self.delegate documentIsReady];
    }
}

- (void)save
{
    [self.managedDocument saveToURL:self.managedDocument.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){}];
}

- (NSArray *)getAllVeranstaltungen
{
    if (self.isDocumentReady) 
    {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Veranstaltung"];
        request.sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"anfangszeit" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"titel" ascending:YES], nil];
        return [self.managedDocument.managedObjectContext executeFetchRequest:request error:nil];
    }
    NSLog(@"Die Datenbank ist noch nicht bereit");
    return nil;
    
}

@end
