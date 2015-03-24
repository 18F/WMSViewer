//
//  WTTableViewController.h
//  Weather
//
//  Created by Scott on 26/01/2013.
//  Updated by Joshua Greene 16/12/2013.
//
//  Copyright (c) 2013 Scott Sherwood. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMStatefulTableViewController.h"

@interface WTTableViewController : JMStatefulTableViewController


// Actions
- (IBAction)clear:(id)sender;
- (IBAction)jsonTapped:(id)sender;
- (IBAction)plistTapped:(id)sender;
- (IBAction)xmlTapped:(id)sender;
- (IBAction)clientTapped:(id)sender;
- (IBAction)apiTapped:(id)sender;
- (IBAction)closeTapped:(id)sender;

@end