//
//  ValidationResponse.m
//  ProjectCrystalBlueOSX
//
//  Created by Logan Hood on 3/28/14.
//  Copyright (c) 2014 Project Crystal Blue. All rights reserved.
//

#import "ValidationResponse.h"
#import "PCBLogWrapper.h"

@implementation ValidationResponse

@synthesize isValid;
@synthesize errors;

- (instancetype)init
{
    self = [super init];
    if (self) {
        isValid = YES;
        errors = [[NSMutableArray alloc] init];
    }
    return self;
}

-(NSString *)alertWithFieldName:(NSString *)fieldName
                    fieldValue:(NSString *)fieldValue
{
    if (self.isValid) {
        return nil;
    }
    
    
    NSString *message = [NSString stringWithFormat:@"Invalid %@ \"%@\"", fieldName, fieldValue];
    
    NSMutableString *info = [[NSMutableString alloc] init];
    for (NSString *validationError in self.errors) {
        [info appendFormat:@"- %@\n", validationError];
    }

    return message;
}


@end
