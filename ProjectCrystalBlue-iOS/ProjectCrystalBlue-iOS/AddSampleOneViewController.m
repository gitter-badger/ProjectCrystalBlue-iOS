//
//  AddSampleOneViewController.m
//  ProjectCrystalBlue-iOS
//
//  Created by Ryan McGraw on 3/1/14.
//  Copyright (c) 2014 Project Crystal Blue. All rights reserved.
//

#import "AddSampleOneViewController.h"
#import "AbstractLibraryObjectStore.h"
#import "SourceConstants.h"
#import "Source.h"
#import "AddSampleTwoViewController.h"
#import "SourceFieldValidator.h"
#import "MapViewController.h"

@interface AddSampleOneViewController ()
{
    AbstractCloudLibraryObjectStore *libraryObjectStore;
    Source *sourceToAdd;
    CLLocationManager *locationManager;
}
@end

@implementation AddSampleOneViewController
@synthesize KeyField, LatitudeField, LongitudeField,CollectedByField, DatePicker;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        libraryObjectStore = [[SimpleDBLibraryObjectStore alloc] initInLocalDirectory:@"ProjectCrystalBlue/Data"
                                                                     WithDatabaseName:@"test_database.db"];
        
        UINavigationItem *n = [self navigationItem];
        [n setTitle:@"Add Sample"];
        
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(addSource:)];
        
        UIBarButtonItem *backbtn = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(goBack:)];
        
        [[self navigationItem] setRightBarButtonItem:bbi];
        [[self navigationItem] setLeftBarButtonItem:backbtn];
    }
    return self;
}

- (IBAction)addSource:(id)sender
{
    if (![self validateTextFieldValues]) {
        return;
    }
    if (![libraryObjectStore libraryObjectExistsForKey:[KeyField text] FromTable:[SourceConstants tableName]] && ![[KeyField text] isEqualToString:@""])
    {
        // Logic to set to current time and user entered date
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDate *now = [NSDate date];
        NSDateComponents *nowComp = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:now];
        NSDate *date = DatePicker.date;
        NSDateComponents *comp = [calendar components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:date];
        
        comp.hour = nowComp.hour;
        comp.minute = nowComp.minute;
        date = [calendar dateFromComponents:comp];
        
        NSString *dateString = [formatter stringFromDate:date];
        sourceToAdd = [[Source alloc] initWithKey:[KeyField text]
                                        AndWithValues:[SourceConstants attributeDefaultValues]];
    
        [[sourceToAdd attributes] setObject:[LatitudeField text] forKey:SRC_LATITUDE];
        [[sourceToAdd attributes] setObject:[LongitudeField text] forKey:SRC_LONGITUDE];
        [[sourceToAdd attributes] setObject:[CollectedByField text] forKey:SRC_COLLECTED_BY];
        [[sourceToAdd attributes] setObject:dateString forKey:SRC_DATE_COLLECTED];
    
        AddSampleTwoViewController *astViewController = [[AddSampleTwoViewController alloc] initWithSource:sourceToAdd WithLibraryObject:libraryObjectStore];
    
        [astViewController setLibraryObjectStore:libraryObjectStore];
        [[self navigationController] pushViewController:astViewController  animated:YES];
    }
    
    else
    {
        NSString *message;
        
        if ([[KeyField text] isEqualToString:@""]) {
            message = @"Please enter Key Value";
        }
        else{
            message = @"Source already exist for key: ";
        }
        message = [message stringByAppendingString:[KeyField text]];
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:message
                              message:nil
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil, nil];
        [alert show];
    }
}


-(void) goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    locationManager = [[CLLocationManager alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)backgroundTapped:(id)sender
{
    [[self view] endEditing:YES];
}

- (IBAction)getLocation:(id)sender
{
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
}

- (IBAction)viewMap:(id)sender
{
    bool doIt = [self validateCoordinates];
    if(!doIt)
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Invalid/Blank Latitude and Longitude Fields"
                              message:nil
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
        MapViewController* mapViewController = [[MapViewController alloc] initWithKey:@"Source To Add" withLat:[LatitudeField text] withLong:[LongitudeField text]];
    
        [[self navigationController] pushViewController:mapViewController  animated:YES];
    }

}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        LatitudeField.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
        LongitudeField.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
    }
    [locationManager stopUpdatingLocation];
}

- (BOOL)validateTextFieldValues
{
    BOOL validationPassed = YES;

    ValidationResponse *latitudeOK = [SourceFieldValidator validateLatitude:[LatitudeField text]];
    if (!latitudeOK.isValid && validationPassed == YES) {
        validationPassed = NO;
        
        NSString *message = [latitudeOK alertWithFieldName:@"latitude" fieldValue:[LatitudeField text]];
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:message
                              message:nil
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil, nil];
        [alert show];
    }
    
    ValidationResponse *longitudeOK = [SourceFieldValidator validateLongitude:[LongitudeField text]];
    if (!longitudeOK.isValid && validationPassed == YES) {
        validationPassed = NO;
        
        NSString *message = [longitudeOK alertWithFieldName:@"longitude" fieldValue:[LongitudeField text]];
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:message
                              message:nil
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil, nil];
        [alert show];
    }
    
    ValidationResponse *collectedOK = [SourceFieldValidator validateCollectedBy:[CollectedByField text]];
    if (!collectedOK.isValid && validationPassed == YES) {
        validationPassed = NO;
        
        NSString *message = [collectedOK alertWithFieldName:@"collected by" fieldValue:[CollectedByField text]];
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:message
                              message:nil
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil, nil];
        [alert show];
    }

    return validationPassed;
}

- (BOOL)validateCoordinates
{
    BOOL validationPassed = YES;
    
    ValidationResponse *latitudeOK = [SourceFieldValidator validateLatitude:[LatitudeField text]];
    if (!latitudeOK.isValid && validationPassed == YES) {
        validationPassed = NO;
    }
    
    ValidationResponse *longitudeOK = [SourceFieldValidator validateLongitude:[LongitudeField text]];
    if (!longitudeOK.isValid && validationPassed == YES) {
        validationPassed = NO;
    }
    
    if([LongitudeField.text isEqualToString:@""])
    {
        validationPassed = NO;
    }
    
    if([LatitudeField.text isEqualToString:@""])
    {
        validationPassed = NO;
    }
    return validationPassed;
}

@end
