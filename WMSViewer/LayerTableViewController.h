//
//  LayerTableViewController.h
//  WMSViewer
//
//  Created by Alan Steremberg on 3/25/15.
//  Copyright (c) 2015 Alan Steremberg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WhirlyGlobeComponent.h>

@interface LayerTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UIBarButtonItem *close;
@property(nonatomic, strong) NSMutableArray *layers;
@property(nonatomic, strong) NSMutableArray *favorites;
@property(nonatomic, strong) MaplyBaseViewController *map;

@end
