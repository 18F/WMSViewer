//
//  FavoritesTableViewController.m
//  WMSViewer
//
//  Created by Alan Steremberg on 3/25/15.
//  Copyright (c) 2015 Alan Steremberg. All rights reserved.
//

#import "FavoritesTableViewController.h"
#import "WMSTableViewController.h"
#import "WTTableViewController.h"
#import "GeoplatformTableViewController.h"

@interface FavoritesTableViewController ()

@end

@implementation FavoritesTableViewController
- (IBAction)close:(id)sender
{
    NSLog(@"close Tapped");
    [[self presentingViewController] dismissViewControllerAnimated: YES completion:nil];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"WMSSeg"]){
        UITableViewCell *cell = (UITableViewCell *)sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        WMSTableViewController *wac = (WMSTableViewController *)segue.destinationViewController;
        
        NSDictionary *w;
        // assume the section 1 for now?
        w = self.directory[indexPath.row];
        NSLog(@"setting result: %@",w);
        wac.result = w;
        
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:jsonPath];
    NSError *error = nil;
    NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSLog(@"json: %@",json);
    self.directory = json;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    switch (section) {
        case 0: {
            return [self.favorites count];
        }
        case 1: {
            return [self.directory count];
        }
        default:
            return 0;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FavoritesCell" forIndexPath:indexPath];
    
    NSDictionary * item = nil;
    
    switch (indexPath.section) {
        case 0: {
            item = self.favorites[indexPath.row];
            break;
        }
            
        case 1: {
            item = self.directory[indexPath.row];

            break;
        }
            
        default:
            break;
    }

    if (item)
    {
    cell.textLabel.text = item[@"title"];
    cell.detailTextLabel.text = item[@"abstract"];
    cell.detailTextLabel.numberOfLines = 6;
    cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    switch (indexPath.section) {
        case 0: {
            // we probably want to throw them the URL and the layer.. interesting
            NSMutableDictionary * theDict = [[NSMutableDictionary alloc] init] ;
            NSDictionary *favitem = self.favorites[indexPath.row];
            [theDict setValue: favitem[@"name"] forKey: @"name"];
            [theDict setValue: favitem[@"url"] forKey: @"url"];
            
            // All instances of TestClass will be notified
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"AddWMSLayer"
             object:theDict];
            [[self presentingViewController] dismissViewControllerAnimated: YES completion:nil];

            
            break;
        }
            
        case 1: {
            NSDictionary *item = self.directory[indexPath.row];
            if ([item[@"type"] isEqualToString:@"wms" ])
            {
                NSLog(@"WMS: %@",item);
                UIStoryboard *MainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
                WMSTableViewController *info=[MainStoryboard instantiateViewControllerWithIdentifier:@"WMSController"];
                info.result = item;
                // [[self presentingViewController] pushViewController:info animated:YES completion:nil];
             
                [self.navigationController pushViewController:info animated:YES ];
            }
            else if ([item[@"type"] isEqualToString: @"usckan"])
            {
                NSLog(@"USCKAN: %@",item);
                UIStoryboard *MainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
                WTTableViewController *info=[MainStoryboard instantiateViewControllerWithIdentifier:@"WTController"];
                info.ckan = item[@"url"];
                [self.navigationController pushViewController:info animated:YES ];

            }
            else if ([item[@"type"] isEqualToString: @"geoplatform"])
            {
                NSLog(@"geoplatform: %@",item);
                UIStoryboard *MainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
                GeoPlatformTableViewController *info=[MainStoryboard instantiateViewControllerWithIdentifier:@"GeoPlatformController"];
                info.geoplatform = item[@"url"];
                [self.navigationController pushViewController:info animated:YES ];

            }
            break;
        }
            
        default:
            break;
    }

    
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
        return @"Favorites";
        break;
        case 1:
        return @"Data Catalogs";
        break;
    }
    return @"";
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
