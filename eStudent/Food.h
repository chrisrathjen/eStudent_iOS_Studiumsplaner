//
//  Food.h
//  mensa_data
//
//  Created by Christian Rathjen on 03.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Day;

@interface Food : NSManagedObject

@property (nonatomic, retain) NSString * extra;
@property (nonatomic, retain) NSString * foodDescription;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * order;
@property (nonatomic, retain) NSString * staffPrice;
@property (nonatomic, retain) NSString * studentPrice;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) Day *day;

@end
