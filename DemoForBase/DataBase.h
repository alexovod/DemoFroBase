//
//  DataBase.h
//  DemoForBase
//
//  Created by Alex Ovod on 10/2/13.
//  Copyright (c) 2013 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataBase : NSObject

@property (nonatomic, retain) NSManagedObjectContext       *managedObjectContext;
@property (nonatomic, retain) NSManagedObjectContext       *mainManagedObjectContext;
@property (nonatomic, retain) NSManagedObjectModel         *managedObjectModel;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (DataBase *) sharedInstance;

@end
