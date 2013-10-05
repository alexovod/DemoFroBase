//
//  User+Creation.m
//  DemoForBase
//
//  Created by Alex Ovod on 10/2/13.
//  Copyright (c) 2013 Alex. All rights reserved.
//

#import "User+Creation.h"
#import "Tag+Creation.h"

@implementation User (Creation)

+ (BOOL) addUserWithName:(NSString *) name email:(NSString *)email age:(short)age tags:(NSArray *)tags inManagedObjectContext:(NSManagedObjectContext *) context
{

    BOOL result = NO;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];

    request.predicate = [NSPredicate predicateWithFormat:@"age = %d AND name = %@",age, name];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO]];
    request.fetchBatchSize = 1;
    request.returnsObjectsAsFaults= YES;

    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];

    
    if (!matches || matches.count > 1)
    {
        //error
    }
    else if (matches.count == 0)
    {
        User *user = (User *)[NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
        [user setName:name];
        [user setEmail:email];
        [user setAge:age];
        [Tag tags:tags forUser:user inManagedObjectContext:context];
        result = YES;
    }
    else if (matches.count == 1)
    {
        //user already exist;
//        User *user = [matches lastObject];
//        [Tag tags:tags forUser:user inManagedObjectContext:context];

    }
    
    return result;
}


@end
