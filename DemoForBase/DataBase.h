//
//  DataBase.h
//  DemoForBase
//
//  Created by Alex Ovod on 10/2/13.
//  Copyright (c) 2013 Alex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataBase : NSObject

@property (nonatomic, strong) NSManagedObjectContext       *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectContext       *mainManagedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel         *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (DataBase *) sharedInstance;

@end
