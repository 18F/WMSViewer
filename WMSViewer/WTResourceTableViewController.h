//
//  WTResourceTableViewController.h
//  Weather
//
//  Created by Alan Steremberg on 3/23/15.
//  Copyright (c) 2015 Scott Sherwood. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WTResourceTableViewController : UITableViewController
// Actions
- (IBAction)clear:(id)sender;
- (IBAction)apiTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *rowclicked;
@property(nonatomic, strong) NSDictionary *result;
@property (weak, nonatomic) IBOutlet UITextView *descriptionText;

@end
