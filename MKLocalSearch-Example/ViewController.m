//
//  ViewController.m
//  MKLocalSearch-Example
//
//  Created by Victor Kristof on 19.09.14.
//  Copyright (c) 2014 Victor Krisotf. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

- (BOOL)setupLocationManager:(CLLocationManager *)locationManager;

@end

@implementation ViewController

@synthesize searchController;
@synthesize searchBar;
@synthesize mapView;
@synthesize locationManager;

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	[self.searchController setDelegate:self];
	[self.searchBar setDelegate:self];
	
	if ([self setupLocationManager:self.locationManager]) {
		[self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
		[self.locationManager startUpdatingLocation];
	} else {
		NSLog(@"Location Services disabled.");
	}

	
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (BOOL)setupLocationManager:(CLLocationManager *)aLocationManager {
	BOOL isSetup = NO;
	if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled"
														message:@"You must enable Location Services for this app in order to use it."
													   delegate:self
											  cancelButtonTitle:nil
											  otherButtonTitles:@"Ok", nil];
		[alert show];
		return isSetup;
	} else if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Services Restricted"
														message:@"You must enable Location Services for this app in order to use it."
													   delegate:self
											  cancelButtonTitle:nil
											  otherButtonTitles:@"Ok", nil];
		[alert show];
		return isSetup;
	} else {
		aLocationManager = [[CLLocationManager alloc] init];
		if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
			[self.locationManager requestWhenInUseAuthorization];
			// Request only when app is in front
		}
		if ([CLLocationManager locationServicesEnabled]) {
			aLocationManager.delegate = self;
			aLocationManager.distanceFilter = 10;
			aLocationManager.desiredAccuracy = kCLLocationAccuracyBest;
			isSetup = YES;
			return isSetup;
		}
		
		return isSetup;
	}

	
}

@end
