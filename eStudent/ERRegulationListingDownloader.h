//
//  ERRegulationListingDownloader.h
//  eStudent
//
//  Created by Christian Rathjen on 24.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ERRegulationListingDownloader;
@protocol ERRegulationListingDownloaderDelegate
@optional
- (void)ERListingParsed:(NSDictionary *)regulations;
@end

@interface ERRegulationListingDownloader : NSObject
- (void)getJSONRegulationListing;

@property (nonatomic, weak) id <ERRegulationListingDownloaderDelegate> delegate;
@end
