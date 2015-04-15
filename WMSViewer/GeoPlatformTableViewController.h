//
//  GeoPlatformTableViewController.h
//  WMSViewer
//
//  Created by Alan Steremberg on 4/13/15.
//  Copyright (c) 2015 Alan Steremberg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMStatefulTableViewController.h"

@interface GeoPlatformTableViewController : JMStatefulTableViewController

@property(nonatomic, strong) NSString *geoplatform;
@property IBOutlet UISearchBar *geoSearchBar;
@end

