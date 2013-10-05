//
//  Tags+Creation.m
//  DemoForBase
//
//  Created by Alex Ovod on 10/2/13.
//  Copyright (c) 2013 Alex. All rights reserved.
//

#import "Tag+Creation.h"

@implementation Tag (Creation)


+ (NSSet *) tags:(NSArray *) tags forUser:(User *)user inManagedObjectContext:(NSManagedObjectContext *) context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
    
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"tagName" ascending:NO]];
    request.predicate = [NSPredicate predicateWithFormat:@"tagName IN %@", tags];
    request.fetchBatchSize = [tags count];
    request.returnsObjectsAsFaults = YES;

    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];

    NSMutableSet *ms = [NSMutableSet setWithCapacity:tags.count];
    
    NSMutableArray *mTags = [tags mutableCopy];
    
    [matches enumerateObjectsUsingBlock:^(Tag *tag, NSUInteger index, BOOL *stop){
        [tag addUserObject:user];
        [mTags removeObject:tag.tagName];
    }];
    
    
    for (NSString *obj in mTags)
    {
        Tag *tag = (Tag *)[NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:context];
        [tag setTagName:obj];
        [tag addUserObject:user];
        [ms addObject:tag];
    }

    
    return ms;
}

@end
