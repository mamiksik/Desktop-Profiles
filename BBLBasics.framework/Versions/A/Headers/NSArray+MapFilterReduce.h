//
//  NSArray+MapFilterReduce.h
//  BBLBasics
//
//  Created by Andy Park on 29/01/2017.
//  Copyright © 2017 Big Bear Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (MapFilterReduce)

- (NSArray *)mapWith:(id (^)(id obj, NSUInteger idx))block;

- (NSArray*)filterWith:(BOOL (^)(id element))block;

@end
