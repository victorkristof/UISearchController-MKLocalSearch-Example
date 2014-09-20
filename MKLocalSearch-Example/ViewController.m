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
@synthesize localSearch;
@synthesize searchBar;
@synthesize results;
@synthesize mapView;
@synthesize locationManager;

- (void)viewDidLoad {
	[super viewDidLoad];
	
	UITableViewController *searchResultsController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
	searchResultsController.tableView = self.tableView;
	searchResultsController.tableView.dataSource = self;
	searchResultsController.tableView.delegate = self;
	
	self.searchController = [[UISearchController alloc] initWithSearchResultsController:searchResultsController];
	[self.searchController setDelegate:self];
	[self.searchBar setDelegate:self];
	
//	self.tableView.tableHeaderView = self.searchBar;
//	self.definesPresentationContext = YES;
	
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

- (void)willPresentSearchController:(UISearchController *)aSearchController {
	NSLog(@"Will present search controller %@", aSearchController);
}

- (BOOL)setupLocationManager:(CLLocationManager *)aLocationManager {
	BOOL isSetup = NO;
	if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
		[[[UIAlertView alloc] initWithTitle:@"Location Services Disabled"
									message:@"You must enable Location Services for this app in order to use it."
								   delegate:self
						  cancelButtonTitle:nil
						  otherButtonTitles:@"Ok", nil] show];
		return isSetup;
	} else if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted) {
		[[[UIAlertView alloc] initWithTitle:@"Location Services Restricted"
									message:@"You must enable Location Services for this app in order to use it."
								   delegate:self
						  cancelButtonTitle:nil
						  otherButtonTitles:@"Ok", nil] show];
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

- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar {
	// Cancel any previous searches.
	[self.localSearch cancel];
	
	// Perform a new search.
	MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
	request.naturalLanguageQuery = aSearchBar.text;
	request.region = self.mapView.region;
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	self.localSearch = [[MKLocalSearch alloc] initWithRequest:request];
	
	[self.localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error){
		
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		[self.tableView setHidden:NO];
		
		if (error != nil) {
			[[[UIAlertView alloc] initWithTitle:@"Map Error"
										message:[error description]
									   delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil] show];
			return;
		}
		
		if ([response.mapItems count] == 0) {
			[[[UIAlertView alloc] initWithTitle:@"No Results"
										message:nil
									   delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil] show];
			return;
		}
		
		self.results = response;
		
		//	[self.searchController setActive:YES];
		
		[[(UITableViewController *)self.searchController.searchResultsController tableView] setHidden:NO];
		[[(UITableViewController *)self.searchController.searchResultsController tableView] reloadData];
	}];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.results.mapItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *IDENTIFIER = @"SearchResultsCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:IDENTIFIER];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:IDENTIFIER];
	}
	
	MKMapItem *item = self.results.mapItems[indexPath.row];
	
	cell.textLabel.text = item.placemark.name;
	cell.detailTextLabel.text = item.placemark.addressDictionary[@"Street"];
	
	return cell;
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)aSearchBar{
	if ([aSearchBar.text isEqualToString:@""]) {
		[self.tableView setHidden:YES];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
//	[self.searchController setActive:NO];
	[[(UITableViewController *)self.searchController.searchResultsController tableView] setHidden:YES];
	
	MKMapItem *item = self.results.mapItems[indexPath.row];
	
	NSLog(@"Selected \"%@\"", item.placemark.name);
	
	[self.mapView addAnnotation:item.placemark];
	[self.mapView selectAnnotation:item.placemark animated:YES];
	
	[self.mapView setCenterCoordinate:item.placemark.location.coordinate animated:YES];
	
	[self.mapView setUserTrackingMode:MKUserTrackingModeNone];
	
}


@end
