//
//  DetailsViewController.m
//  DemoForBase
//
//  Created by Alex Ovod on 10/3/13.
//  Copyright (c) 2013 Alex. All rights reserved.
//

#import "DetailsViewController.h"
#import "Tag.h"
#import "User.h"

@interface DetailsViewController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) User *user;

@end

enum DetailCellRow {
    kCellTypeName,
    kCellTypeAge,
    kCellTypeEmail,
    kCellTypeLast
    };

enum TableSections {
    kTableSectionUserDetails,
    kTableSectinoTags,
    kTableSectionLast
    };

@implementation DetailsViewController


- (id)initWithUseData:(User *) user
{
    self = [super init];
    if (self) {

        self.user = user;

    }
    return self;
}

+ (DetailsViewController *) detailViewControllerForUser:(User *)user
{
    return [[self alloc] initWithUseData:user];
}


- (void) setupTableView
{
    CGRect frame = [[UIScreen mainScreen] bounds];
    
    CGFloat h = self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height;
    frame.origin.y += h;
    frame.size.height -= h;
    
    self.tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] bounds] style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Details";

    [self setupTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2; //user details and tags in other section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case kTableSectionUserDetails:
            return kCellTypeLast;

        case kTableSectinoTags:
            return self.user.tags.count;

        default:
            break;
    };
    
    return 0;
}

- (UITableViewCell *) cellWithID:(NSString *) cellID
{
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [self cellWithID:cellIdentifier];
    
    switch (indexPath.section) {
        case kTableSectionUserDetails:
        {

            switch (indexPath.row) {
                case kCellTypeName:
                    cell.textLabel.text = self.user.name;
                    break;

                case kCellTypeAge:
                    cell.textLabel.text = [NSString stringWithFormat:@"Age: %d", self.user.age];
                    break;

                case kCellTypeEmail:
                    cell.textLabel.text = self.user.email;
                    break;

                default:
                    break;
            }
        }
        break;
            
        case kTableSectinoTags:
        {
            cell.textLabel.text = [self.user.tags.allObjects[indexPath.row] tagName];
        }
        break;
            
        default:
            break;
    }
    
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == kTableSectinoTags)
        return @"Tags";
    
    return nil;    
}

@end
