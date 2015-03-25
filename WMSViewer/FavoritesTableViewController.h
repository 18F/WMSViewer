//
//  FavoritesTableViewController.h
//  WMSViewer
//
//  Created by Alan Steremberg on 3/25/15.
//  Copyright (c) 2015 Alan Steremberg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavoritesTableViewController : UITableViewController
@property(nonatomic, strong) NSMutableArray *favorites;
@property(nonatomic, strong) NSArray *directory;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *close;

@end
