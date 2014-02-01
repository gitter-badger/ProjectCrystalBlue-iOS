//
//  LibraryObject.h
//  ProjectCrystalBlue-iOS
//
//  Created by Justin Baumgartner on 1/30/14.
//  Copyright (c) 2014 Library Object. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LibraryObject : NSObject

@property(readonly,copy) NSString *key;
@property NSDictionary *attributes;

- (id)initWithKey:(NSString *)aKey
AndWithAttributes:(NSArray *)attributeNames
AndWithDefaultValues:(NSArray *)attributeDefaultValues;

@end
