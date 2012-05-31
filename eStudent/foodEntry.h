//
//  foodEntry.h
//  mensa_data
//
//  Created by Christian Rathjen on 11.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

//Ein foodEntry Objekt kann alle Daten enthalten die der Mensaparser zur Verfügung stellt.

@interface foodEntry : NSObject 
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *foodDescription;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *extra;
@property (nonatomic, strong) NSString *studentPrice;
@property (nonatomic, strong) NSString *staffPrice;
@property (nonatomic, strong) NSString *order;
@end
