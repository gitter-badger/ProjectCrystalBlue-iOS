//
//  SourceConstants.m
//  ProjectCrystalBlue-iOS
//
//  Created by Justin Baumgartner on 1/18/14.
//  Copyright (c) 2014 Project Crystal Blue. All rights reserved.
//

#import "SourceConstants.h"

/* Attribute names
 */
NSString *const CONTINENT = @"Continent";
NSString *const TYPE = @"Type";
NSString *const LITHOLOGY = @"Lithology";
NSString *const DEPOSYSTEM = @"Deposystem";
NSString *const GROUP = @"Group";
NSString *const FORMATION = @"Formation";
NSString *const MEMBER = @"Member";
NSString *const REGION = @"Region";
NSString *const LOCALITY = @"Locality";
NSString *const SECTION = @"Section";
NSString *const METER_LEVEL = @"Meter_Level";
NSString *const LATITUDE = @"Latitude";
NSString *const LONGITUDE = @"Longitude";
NSString *const AGE = @"Age";
NSString *const AGE_BASIS1 = @"Age_Basis1";
NSString *const AGE_BASIS2 = @"Age_Basis2";
NSString *const DATE_COLLECTED = @"Date_Collected";
NSString *const PROJECT = @"Project";
NSString *const SUBPROJECT = @"Subproject";

/* Attribute default values
 */
NSString *const DEF_VAL_CONTINENT = @"continent here";
NSString *const DEF_VAL_TYPE = @"Type here";
NSString *const DEF_VAL_LITHOLOGY = @"Lithology here";
NSString *const DEF_VAL_DEPOSYSTEM = @"Deposystem here";
NSString *const DEF_VAL_GROUP = @"Group here";
NSString *const DEF_VAL_FORMATION = @"Formation here";
NSString *const DEF_VAL_MEMBER = @"Member here";
NSString *const DEF_VAL_REGION = @"Region here";
NSString *const DEF_VAL_LOCALITY = @"Locality here";
NSString *const DEF_VAL_SECTION = @"Section here";
NSString *const DEF_VAL_METER_LEVEL = @"Meter_Level here";
NSString *const DEF_VAL_LATITUDE = @"Latitude here";
NSString *const DEF_VAL_LONGITUDE = @"Longitude here";
NSString *const DEF_VAL_AGE = @"Age here";
NSString *const DEF_VAL_AGE_BASIS1 = @"Age_Basis1 here";
NSString *const DEF_VAL_AGE_BASIS2 = @"Age_Basis2 here";
NSString *const DEF_VAL_DATE_COLLECTED = @"Date_Collected here";
NSString *const DEF_VAL_PROJECT = @"Project here";
NSString *const DEF_VAL_SUBPROJECT = @"Subproject here";

@implementation SourceConstants

+ (NSArray *)attributeNames
{
    static NSArray *attributeNames = nil;
    if (!attributeNames)
    {
        attributeNames = [NSArray arrayWithObjects:
                          CONTINENT,
                          nil];
    }
    return attributeNames;
}

+ (NSArray *)attributeDefaultValues
{
    static NSArray *attributeDefaultValues = nil;
    if (!attributeDefaultValues)
    {
        attributeDefaultValues = [NSArray arrayWithObjects:
                          DEF_VAL_CONTINENT,
                          nil];
    }
    return attributeDefaultValues;
}

@end
