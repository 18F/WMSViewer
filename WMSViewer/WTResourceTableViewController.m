//
//  WTResourceTableViewController.m
//  Weather
//
//  Created by Alan Steremberg on 3/23/15.
//  Copyright (c) 2015 Scott Sherwood. All rights reserved.
//

#import "WTResourceTableViewController.h"
#import "WMSTableViewController.h"

@interface WTResourceTableViewController ()

@property (nonatomic) NSMutableArray *results;

@end


@implementation WTResourceTableViewController



- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    NSLog(@"initWithCoder");
    
    self = [super initWithCoder: aDecoder];
    if (self)
    {
        
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // self.navigationController.toolbarHidden = NO;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) viewWillAppear:(BOOL)animated {
    NSLog(@"View Will Appear");
    [super viewWillAppear:animated];
    
    
    // walk through and delete items from array that aren't wms
//    self.result[@"resources"]
    
    self.descriptionText.text = self.result[@"notes"];
    self.title = self.result[@"title"];
    
    self.results = [[NSMutableArray alloc] init];
    for ( NSDictionary *item in self.result[@"resources"]) {
        // do something with object
        if ([item[@"format"] isEqualToString:@"WMS" ]) {
            [self.results addObject: item];
        }
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"WMSSeg"]){
        UITableViewCell *cell = (UITableViewCell *)sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        WMSTableViewController *wac = (WMSTableViewController *)segue.destinationViewController;

        NSDictionary *w;
        w = self.results[indexPath.row];
        NSLog(@"setting result: %@",w);
        wac.result = w;

    }
}

#pragma mark - Actions

- (IBAction)clear:(id)sender
{
    self.title = @"";
    [self.tableView reloadData];
}

- (IBAction)jsonTapped:(id)sender
{
    NSLog(@"jsontapped");
}

- (IBAction)plistTapped:(id)sender
{
    
}

- (IBAction)xmlTapped:(id)sender
{
    
}

- (IBAction)clientTapped:(id)sender
{
    
}

- (IBAction)apiTapped:(id)sender
{
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(!self.result)
        return 0;
    NSLog(@"rows: %d",[self.results count]);
    return [self.results count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ResourceCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDictionary *daysWeather = nil;
    
    daysWeather = self.results[indexPath.row];
    
    
    cell.textLabel.text = daysWeather[@"name"];
    cell.detailTextLabel.text = daysWeather[@"description"];
    cell.detailTextLabel.numberOfLines = 6;
    cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
    
    return cell;
}
/*
#pragma mark - Table view delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *layerinfo = [self.results objectAtIndex:indexPath.row];
    // All instances of TestClass will be notified
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"AddLayer"
     object:layerinfo];
    
}
*/

@end
