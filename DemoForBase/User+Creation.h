//
//  User+Creation.h
//  DemoForBase
//
//  Created by Alex Ovod on 10/2/13.
//  Copyright (c) 2013 Alex. All rights reserved.
//

#import "User.h"

#define USER_ENTITY @"User"

@interface User (Creation)

+ (BOOL) addUserWithName:(NSString *) name email:(NSString *)email age:(short)age tags:(NSArray *)tags inManagedObjectContext:(NSManagedObjectContext *) context;

@end
