//
//  ESHintergrundViewController.m
//  eStudent
//
//  Created by Nicolas Autzen on 20.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ESHintergrundViewController.h"

@interface ESHintergrundViewController ()

@end

@implementation ESHintergrundViewController

@synthesize scrollview;

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.scrollview.contentSize = CGSizeMake(320.0, 641.0);
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

#pragma mark - change background

- (IBAction)hintergrundSetzen:(UIButton *)sender
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];    
    NSArray *backgrounds = self.scrollview.subviews;
    for (int i = 0; i < backgrounds.count; i++) {
        NSString *backgroundImage;
        if ([backgrounds objectAtIndex:i] == sender) {
            if (IS_IPHONE_5) {
                backgroundImage = [NSString stringWithFormat:@"background_%d-568h.jpg",(i+1)];
                NSLog(@"iPhone5 background set");
            } else {
                backgroundImage = [NSString stringWithFormat:@"background_%d.jpg",(i+1)];
            }
            [userDefaults setObject:backgroundImage forKey:@"backgroundImage"];
            [userDefaults synchronize];
            UINavigationController *nc = [self.navigationController.viewControllers objectAtIndex:1];
            nc.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:backgroundImage]];
            [self.navigationController popToViewController:nc animated:YES];
        }
    }
}

@end
