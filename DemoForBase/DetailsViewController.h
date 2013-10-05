//
//  DetailsViewController.h
//  DemoForBase
//
//  Created by Alex Ovod on 10/3/13.
//  Copyright (c) 2013 Alex. All rights reserved.
//

#import <UIKit/UIKit.h>


@class User;

@interface DetailsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

+ (DetailsViewController *) detailViewControllerForUser:(User *)user;

@end
