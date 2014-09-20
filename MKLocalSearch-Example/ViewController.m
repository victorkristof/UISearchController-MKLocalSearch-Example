//
//  ViewController.m
//  MKLocalSearch-Example
//
//  Created by Victor Kristof on 19.09.14.
//  Copyright (c) 2014 Victor Krisotf. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

- (BOOL)setupLocationManager;

@end

@implementation ViewController

@synthesize searchController;
@synthesize localSearch;
@synthesize results;
@synthesize mapView;
@synthesize locationManager;

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// Keep the subviews inside the top and bottom layout guides
	self.edgesForExtendedLayout = UIRectEdgeLeft | UIRectEdgeBottom | UIRectEdgeRight;
	// Fix black glow on navigation bar
	[self.navigationController.view setBackgroundColor:[UIColor whiteColor]];
	
	if ([self setupLocationManager]) {
		[self.locationManager startUpdatingLocation];
		[self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
	} else {
		NSLog(@"Location Services disabled.");
	}
	
	// The TableViewController used to display the results of a search
	UITableViewController *searchResultsController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
	searchResultsController.automaticallyAdjustsScrollViewInsets = NO; // Remove table view insets
	searchResultsController.tableView.dataSource = self;
	searchResultsController.tableView.delegate = self;
	
	// Initialize our UISearchController
	self.searchController = [[UISearchController alloc] initWithSearchResultsController:searchResultsController];
	self.searchController.delegate = self;
	self.searchController.searchBar.delegate = self;
	
	// Add SearchController's search bar to our view and bring it to front
	CGRect searchBarFrame = self.searchController.searchBar.frame;
	CGRect viewFrame = self.view.frame;
	self.searchController.searchBar.frame = CGRectMake(searchBarFrame.origin.x,
													   searchBarFrame.origin.y,
													   viewFrame.size.width,
													   44.0);
	[self.view addSubview:self.searchController.searchBar];
	[self.view bringSubviewToFront:self.searchController.searchBar];
	
	self.definesPresentationContext = YES;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (BOOL)setupLocationManager {
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
		self.locationManager = [[CLLocationManager alloc] init];
		if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
			// Request localisation only when app is in front
			[self.locationManager requestWhenInUseAuthorization];
		}
		if ([CLLocationManager locationServicesEnabled]) {
			self.locationManager.delegate = self;
			self.locationManager.distanceFilter = 10;
			self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
			isSetup = YES;
			return isSetup;
		}
		
		return isSetup;
	}
}

-(void)willPresentSearchController:(UISearchController *)aSearchController {
	
	// Set the position of the result's table view below the status bar and search bar
	// Use of instance variable to do it only once, otherwise it goes down at every search request
	if (CGRectIsEmpty(_searchTableViewRect)) {
		CGRect tableViewFrame = ((UITableViewController *)aSearchController.searchResultsController).tableView
		.frame;
		tableViewFrame.origin.y = tableViewFrame.origin.y + 64; //status bar (20) + nav bar (44)
		tableViewFrame.size.height =  tableViewFrame.size.height;
		
		_searchTableViewRect = tableViewFrame;
	}
	
	[((UITableViewController *)aSearchController.searchResultsController).tableView setFrame:_searchTableViewRect];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// Hide search controller
	[self.searchController setActive:NO];
	
	MKMapItem *item = self.results.mapItems[indexPath.row];
	
	NSLog(@"Selected \"%@\"", item.placemark.name);
	
	[self.mapView addAnnotation:item.placemark];
	[self.mapView selectAnnotation:item.placemark animated:YES];
	
	[self.mapView setCenterCoordinate:item.placemark.location.coordinate animated:YES];
	
	[self.mapView setUserTrackingMode:MKUserTrackingModeNone];
	
}


@end
