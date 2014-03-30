//
//  SampleFieldValidatorTests.m
//  ProjectCrystalBlueOSX
//
//  Created by Logan Hood on 3/22/14.
//  Copyright (c) 2014 Project Crystal Blue. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SampleFieldValidator.h"

@interface SampleFieldValidatorTests : XCTestCase

@end

@implementation SampleFieldValidatorTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCurrentLocation
{
    NSString *valid = @"Basement #12.02";
    NSString *tooShort = @"";
    NSMutableString *tooLong = [NSMutableString stringWithString:@""];
    for (int i = 0; i < 91; ++i) {
        [tooLong appendString:@"a"];
    }

    XCTAssertTrue([SampleFieldValidator validateCurrentLocation:valid]);
    XCTAssertFalse([SampleFieldValidator validateCurrentLocation:tooShort]);
    XCTAssertFalse([SampleFieldValidator validateCurrentLocation:tooLong]);
}

@end