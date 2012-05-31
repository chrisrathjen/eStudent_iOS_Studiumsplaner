//
//  ESFlexibleView.h
//  eStudent
//
//  Created by Nicolas Autzen on 24.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ESFlexibleView : UIView

@property (nonatomic)BOOL unsichtbar;
@property (nonatomic)CGRect visibleFrame;
@property (nonatomic)BOOL readyForDeletion;

- (id) initWithX:(float)x Y:(float)y andWidth:(float) width;

@end
