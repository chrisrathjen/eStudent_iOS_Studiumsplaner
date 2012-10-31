//
//  NewCategorieViewController.h
//  eStudent
//
//  Created by Christian Rathjen on 16.08.12.
//
//

#import <UIKit/UIKit.h>
#import "ERDataManager.h"

@interface NewCategorieViewController : UIViewController
@property (nonatomic, strong) ERDataManager *datamanager;
@property (nonatomic, strong) ExamRegulations *aRegulation;
@end
