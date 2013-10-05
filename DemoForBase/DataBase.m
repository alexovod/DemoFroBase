//
//  DataBase.m
//  DemoForBase
//
//  Created by Alex Ovod on 10/2/13.
//  Copyright (c) 2013 Alex. All rights reserved.
//

#import "DataBase.h"
#import <CoreData/CoreData.h>

@interface DataBase()


@property (nonatomic) BOOL firstStart;

@end

@implementation DataBase

+ (DataBase *) sharedInstance
{
    static DataBase *sharedInstance;
    
    @synchronized(self) {
        if (!sharedInstance)
            sharedInstance = [[DataBase alloc] init];
        return sharedInstance;
    }
    
    return nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        //create DB
//        [self managedObjectContext];
    }
    return self;
}

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) mainManagedObjectContext
{
    if (_mainManagedObjectContext)
        return _mainManagedObjectContext;
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _mainManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _mainManagedObjectContext.parentContext = self.managedObjectContext;
        _mainManagedObjectContext.undoManager = nil;
        
    }
    return _mainManagedObjectContext;
    
}

- (NSManagedObjectContext *) managedObjectContext {
	
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _managedObjectContext.persistentStoreCoordinator = coordinator;
        _mainManagedObjectContext.undoManager = nil;
        
    }
    return _managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    return _managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"DataBase2.sqlite"]];
        
	NSError *error;
    NSMutableDictionary *pragmaOptions = [NSMutableDictionary dictionary];
    [pragmaOptions setObject:@"OFF" forKey:@"synchronous"];
    [pragmaOptions setObject:@"OFF" forKey:@"count_changes"];
    [pragmaOptions setObject:@"MEMORY" forKey:@"journal_mode"];
    [pragmaOptions setObject:@"MEMORY" forKey:@"temp_store"];
    NSDictionary *storeOptions = [NSDictionary dictionaryWithObject:pragmaOptions forKey:NSSQLitePragmasOption];

    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:storeOptions error:&error]) {
        // Handle the error.
        NSLog(@"Error");
    }
	
    return _persistentStoreCoordinator;
}

- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

@end
