//
//  Tags+Creation.h
//  DemoForBase
//
//  Created by Alex Ovod on 10/2/13.
//  Copyright (c) 2013 Alex. All rights reserved.
//

#import "Tag.h"

@interface Tag (Creation)

+ (NSSet *) tags:(NSArray *) tags forUser:(User *)user inManagedObjectContext:(NSManagedObjectContext *) context;

@end
