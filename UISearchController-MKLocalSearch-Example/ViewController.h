//
//  ViewController.h
//  MKLocalSearch-Example
//
//  Created by Victor Kristof on 19.09.14.
//  Copyright (c) 2014 Victor Krisotf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController <	UISearchBarDelegate,
												UISearchControllerDelegate,
												CLLocationManagerDelegate,
												UITableViewDataSource,
												UITableViewDelegate> {
	@private
	CGRect _searchTableViewRect;
}

// Search
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) MKLocalSearch *localSearch;
@property (strong, nonatomic) MKLocalSearchResponse *results;

// Map
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;

// Navigation

@end

