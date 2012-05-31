//
//  ESFlexibleView.m
//  eStudent
//
//  Created by Nicolas Autzen on 24.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ESFlexibleView.h"

@implementation ESFlexibleView

@synthesize unsichtbar, visibleFrame, readyForDeletion;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    self.hidden = NO;
    self.readyForDeletion = NO;
    return self;
}

- (id) initWithX:(float)x Y:(float)y andWidth:(float) width
{
    self = [self initWithFrame:CGRectMake(x, y, width, 0.0)];
    return self;
}

- (void) sizeToFit
{
    NSArray *subviews = self.subviews;
    float height = 0.0;
    for (UIView *subview in subviews) 
    {
        height += subview.frame.size.height;
    }
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
}

@end
