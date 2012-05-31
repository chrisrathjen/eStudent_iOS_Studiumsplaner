//
//  ERRegulationListingDownloader.m
//  eStudent
//
//  Created by Christian Rathjen on 24.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ERRegulationListingDownloader.h"
@interface ERRegulationListingDownloader()

@property (nonatomic, strong) NSMutableData *dataStorage; //Databuffer fuer die zu parsende XML

@end


@implementation ERRegulationListingDownloader

@synthesize dataStorage = _dataStorage;
@synthesize delegate = _delegate;



- (void)getJSONRegulationListing {
    NSLog(@"started downloader");
    NSURLRequest *dataRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:BPO_JSON_URL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    NSURLConnection *dataConnection = [[NSURLConnection alloc] initWithRequest:dataRequest delegate:self];
    
    if (dataConnection) {
        self.dataStorage = [NSMutableData data];
        NSLog(@"connection established");
    } else {
        NSLog(@"Connection failed");
    }
    
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.dataStorage setLength:0];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (self.dataStorage) {
        // Daten anhängen
        [self.dataStorage appendData:data];
    } else {
        // Sonst initialisieren
        self.dataStorage = [self.dataStorage initWithData:data];
    }
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{
    NSLog(@"Connection failed: %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSDictionary *listing = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:self.dataStorage options:0 error:nil];
    if (listing) {
        NSLog(@"Object wurde erstellt!");
        // Ruft ERListingParsed in UI/RegulationListingController auf.
        [self.delegate ERListingParsed:listing];
    }else {
        NSLog(@"Object wurde nicht erstellt");
    }
}


@end
