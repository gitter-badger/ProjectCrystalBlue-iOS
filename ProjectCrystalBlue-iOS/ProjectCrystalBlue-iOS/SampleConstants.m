//
//  SampleConstants.m
//  ProjectCrystalBlueOSX
//
//  Created by Justin Baumgartner on 1/18/14.
//  Copyright (c) 2014 Project Crystal Blue. All rights reserved.
//

#import "SampleConstants.h"
#import "DDLog.h"

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

/* Attribute names
 */
static NSString *const KEY = @"key";
static NSString *const SOURCE_KEY = @"sourceKey";
static NSString *const CURRENT_LOCATION = @"currentLocation";
static NSString *const TAGS = @"tags";

/* Attribute default values
 */
static NSString *const DEF_VAL_KEY = @"key here";
static NSString *const DEF_VAL_SOURCE_KEY = @"sourceKey here";
static NSString *const DEF_VAL_CURRENT_LOCATION = @"USC";
static NSString *const DEF_VAL_TAGS = @"tag here";

/* Sample table name
 */
static NSString *const SAMPLE_TABLE_NAME = @"test_sample_table";

@implementation SampleConstants

+ (NSArray *)attributeNames
{
    static NSArray *attributeNames = nil;
    if (!attributeNames)
    {
        attributeNames = [NSArray arrayWithObjects:
                          KEY, SOURCE_KEY, CURRENT_LOCATION, TAGS, nil];
    }
    return attributeNames;
}

+ (NSArray *)attributeDefaultValues
{
    static NSArray *attributeDefaultValues = nil;
    if (!attributeDefaultValues)
    {
        attributeDefaultValues = [NSArray arrayWithObjects:
                                  DEF_VAL_KEY, DEF_VAL_SOURCE_KEY, DEF_VAL_CURRENT_LOCATION, DEF_VAL_TAGS, nil];
    }
    return attributeDefaultValues;
}

+ (NSString *)sampleTableName
{
    return SAMPLE_TABLE_NAME;
}

@end