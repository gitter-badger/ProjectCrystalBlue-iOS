//
//  MapViewController.m
//  ProjectCrystalBlue-iOS
//
//  Created by Ryan McGraw on 4/21/14.
//  Copyright (c) 2014 Project Crystal Blue. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import "Source.h"

@interface MapViewController ()
{
    NSString *latitude;
    NSString *longitude;
}
@end

@implementation MapViewController

- (id)initWithKey:(NSString*) initKey withLat:(NSString*) initLat withLong:(NSString*) initLong
{
    self = [super init];
    if (self) {
        latitude = initLat;
        longitude = initLong;
        UINavigationItem *n = [self navigationItem];
        NSString* title =@"Map of ";
        title = [title stringByAppendingString:initKey];
        [n setTitle:title];
        
        UIBarButtonItem *backbtn = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(goBack:)];
        
        [[self navigationItem] setLeftBarButtonItem:backbtn];
        
    }
    return self;
}

-(void) goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.width)];
   
    [mapView setMapType:MKMapTypeStandard];
    [mapView setZoomEnabled:YES];
    [mapView setScrollEnabled:YES];
    MKCoordinateRegion region = { {0.0, 0.0 }, { 0.0, 0.0 } };
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
    region.center.latitude =  location.coordinate.latitude;
    region.center.longitude = location.coordinate.longitude;
    region.span.longitudeDelta = 0.01f;
    region.span.latitudeDelta = 0.01f;
    [mapView setRegion:region animated:YES];

    MKPlacemark *place = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(region.center.latitude, region.center.longitude) addressDictionary:nil];
    
    MKMapItem *mapItem = [[MKMapItem alloc]initWithPlacemark:place];
    
    [mapItem openInMapsWithLaunchOptions:nil];
    [self.view addSubview:mapView];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
