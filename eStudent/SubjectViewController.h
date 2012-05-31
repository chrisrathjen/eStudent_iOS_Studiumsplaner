//
//  SubjectViewController.h
//  eStudent
//
//  Created by Jalyna on 29.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubjectListLoader.h"

@interface SubjectViewController : UIViewController <UISearchBarDelegate, UITableViewDataSource> {
    UISearchBar *sb;
    UITableView *tv;
}

@property (nonatomic, strong) SubjectListLoader *downloader;
@property (nonatomic, retain) IBOutlet UITableView *tv;
@property (nonatomic, retain) IBOutlet UISearchBar *sb;
@property bool forced;

@end
