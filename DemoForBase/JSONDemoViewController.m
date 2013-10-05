//
//  JSONDemoViewController.m
//  DemoForBase
//
//  Created by Alex Ovod on 10/2/13.
//  Copyright (c) 2013 Alex. All rights reserved.
//

#import "JSONDemoViewController.h"
#import "JSONDemoTableViewCell.h"
#import "DetailsViewController.h"
#import "DataBase.h"
#import "Tag+Creation.h"
#import "User+Creation.h"

@interface JSONDemoViewController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSManagedObjectContext *mainThreadContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchResultController;

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) dispatch_source_t source;
@property (nonatomic) CGFloat progress;
@property (nonatomic) CGFloat totalProgress;
@property (nonatomic, assign) BOOL scrolling;
@property (nonatomic, assign) BOOL decelerating;


@property (assign) BOOL importing;

@property (assign) int numberOfObjets;

@end

@implementation JSONDemoViewController

- (NSFetchedResultsController *) fetchResultController
{
    if (_fetchResultController)
        return _fetchResultController;
    
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:self.mainThreadContext];
    [request setEntity:entity];
    
    NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [request setSortDescriptors:@[sortByName]];

    [request setFetchBatchSize:20];
    [request setReturnsObjectsAsFaults:YES];

    NSFetchedResultsController *fetchResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.mainThreadContext sectionNameKeyPath:nil cacheName:nil];
    
    _fetchResultController = fetchResultsController;
    _fetchResultController.delegate = self;
    
    return _fetchResultController;
    
}

- (id)init
{
    self = [super init];
    if (self) {
        
        _queue = dispatch_queue_create("com.read.json.queue", DISPATCH_QUEUE_SERIAL);
        self.title = @"Demo for Base";
        // Custom initialization
    }
    return self;
}

- (void) fetch
{
    
    
        NSLog(@"fetch");
        [self.mainThreadContext performBlock:^{
            NSError *error;
            if (![self.fetchResultController performFetch:&error])
            {
                NSLog(@"Unresolved error - %@, %@", error, [error userInfo]);
                exit(-1);
            }
        
        }];

}

- (void) setupProgressView
{
    
    self.source = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_ADD, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_event_handler(self.source, ^{
        self.progress += dispatch_source_get_data(self.source);
        [self.progressView setProgress:(self.progress/self.totalProgress) animated:YES];
    });
    dispatch_resume(self.source);

    CGFloat w = [[UIScreen mainScreen] bounds].size.width;
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 64, w, 4)];
    [self.progressView bringSubviewToFront:self.view];
    
    [self.view addSubview:self.progressView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.context = [[DataBase sharedInstance] managedObjectContext];
    self.mainThreadContext = [[DataBase sharedInstance] mainManagedObjectContext];
    
    [self importJSONFile];
    [self setupTableView];
    [self setupProgressView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) saveTags:(NSArray *) tags name:(NSString *) name email:(NSString *) email age:(short)age inManagedObjectContext:(NSManagedObjectContext *) context
{
    
    //save in db
    return [User addUserWithName:name email:email age:age tags:tags inManagedObjectContext:context];

 }

- (void) importJSONFile
{
    dispatch_async(self.queue, ^{

        @autoreleasepool {
            
            self.importing = YES;
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
            NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
            NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
            
            self.totalProgress  = jsonArray.count;

            self.numberOfObjets = jsonArray.count;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            
            NSManagedObjectContext *importContext = [[NSManagedObjectContext alloc] init];
            importContext.parentContext = self.context;
            importContext.undoManager  = nil;
            
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(contextChanged:)
                                                         name:NSManagedObjectContextDidSaveNotification
                                                       object:importContext];
            
            
            
            int numberOfIterations = 0;
            
            CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
            
            for (NSDictionary *dict in jsonArray) {
                @autoreleasepool {
                    
                    NSString *name = [dict objectForKey:@"name"];
                    NSString *email = [dict objectForKey:@"email"];
                    short age = [[dict objectForKey:@"age"] shortValue];
                    NSArray *tags = [dict objectForKey:@"tags"];
                    ++numberOfIterations;
                    
                    [self saveTags:tags name:name email:email age:age inManagedObjectContext: importContext];
                    
                    //update progress bar once per 100 iterations
                    if ((numberOfIterations % 100) == 0)
                        dispatch_source_merge_data(self.source, 100);
                    
                    
                    #warning simulate longer data loading
//                    usleep(10000);

                    // Commit the change per 0.5 secconds
                    if (CFAbsoluteTimeGetCurrent() - startTime >= 0.5)
                    {
                        [self saveContext:importContext];

                        startTime = CFAbsoluteTimeGetCurrent();
                    }
                    
                    //save db every 500 iterations
                    if ((numberOfIterations % 500) == 0)
                    {
                        [self saveParentContextMoreComming:YES];
                    }
                    
                    
                }
            }
            
            self.importing = NO;
            [self saveContext:importContext];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.progressView removeFromSuperview];
                self.progressView = nil;
            });

        }
    });
    
}

- (void) saveParentContextMoreComming:(BOOL)moreComming
{
    [self.context performBlock:^{
        NSError *error;
        if([self.context hasChanges] && ![self.context save:&error])
        {
            NSLog(@"failed to save data in db");
            exit(-1);
        }
        
        if (!moreComming)
        {
            [self.context reset];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self fetch];
            });
        }
        
    }];
    
}

- (void) saveContext:(NSManagedObjectContext *) aContext
{
    NSError *error;
    if([aContext hasChanges] && [aContext save:&error])
    {
        [aContext reset];
        
    }

}

//merging from import context
- (void)contextChanged:(NSNotification*)notification {
   
    if (notification.object == self.context) return;
    
    [self.mainThreadContext performBlock:^{
        [self.mainThreadContext mergeChangesFromContextDidSaveNotification:notification];
        
        if (!self.importing)
            [self saveParentContextMoreComming:NO];


    }];

}

- (void) setupTableView
{

    self.tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] bounds] style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetch];
    [self.tableView reloadData];
    
    
}


#pragma mark Table view Delegate & Datasource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
        return self.numberOfObjets;

}

- (JSONDemoTableViewCell *) cellWithID:(NSString *) cellID
{
    
    JSONDemoTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil)
    {
        cell = [[JSONDemoTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    }
    return cell;
}

- (JSONDemoTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    
    JSONDemoTableViewCell *cell = [self cellWithID:cellIdentifier];

    NSUInteger numberOfFetchedObjects = [[[self.fetchResultController sections] objectAtIndex:indexPath.section] numberOfObjects];
    
    if (self.importing && numberOfFetchedObjects <= indexPath.row )
    {
        cell.nameLable.text = @"";
        cell.ageLable.text = @"";
        cell.emailLable.text = @"Loading...";
        
    } else
    {
        User *user = [self.fetchResultController objectAtIndexPath:indexPath];
        cell.nameLable.text = user.name;
        cell.ageLable.text = [NSString stringWithFormat:@"Age: %d",user.age];
        cell.emailLable.text = user.email;
        
        [cell.nameLable sizeToFit];
        [cell.emailLable sizeToFit];
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([[[self.fetchResultController sections] objectAtIndex:indexPath.section] numberOfObjects] <= indexPath.row)
        return;
        
    User *user = [self.fetchResultController objectAtIndexPath:indexPath];
    
    DetailsViewController *vC = [DetailsViewController detailViewControllerForUser:user];
    [self.navigationController pushViewController:vC animated:YES];
    
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}


#pragma mark Scroll View delegate

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    self.decelerating = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.decelerating = NO;
    [self.tableView reloadData];

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    self.scrolling = NO;
    
    if (!decelerate)
        [self.tableView reloadData];


}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    self.scrolling = YES;
}

#pragma mark FetchedResultsController

- (void) controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    
    if (self.decelerating || self.scrolling)
        return;
    
    [self.tableView reloadData];
}

@end
