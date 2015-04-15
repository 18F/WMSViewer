//
//  GeoPlatformTableViewController.m
//  WMSViewer
//
//  Created by Alan Steremberg on 4/13/15.
//  Copyright (c) 2015 Alan Steremberg. All rights reserved.
//

#import "GeoPlatformTableViewController.h"
#import "WTResourceTableViewController.h"
#import "AFHTTPRequestOperation.h"
#import "WMSTableViewController.h"

@interface GeoPlatformTableViewController ()<UISearchResultsUpdating, UISearchBarDelegate>
@property int numItems;
@property (nonatomic) NSMutableArray *results;
@property NSString *search;
@property (nonatomic, strong) UISearchController *searchController;

@end

@implementation GeoPlatformTableViewController




- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.numItems = 0;
        self.results = nil;
        self.search =@"";
        
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
        self.numItems = 0;
        self.results = nil;
        self.search =@"";
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    
    self.searchController.searchResultsUpdater = self;
    
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    
    self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0);
    
    self.tableView.tableHeaderView = self.searchController.searchBar;

}

- (void) viewWillAppear:(BOOL)animated {
    NSLog(@"View Will Appear");
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"WeatherDetailSegue"]){
        UITableViewCell *cell = (UITableViewCell *)sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            WTResourceTableViewController *wac = (WTResourceTableViewController *)segue.destinationViewController;
            
            NSDictionary *w;
            w = self.results[indexPath.row];
            wac.result = w;
    }
}

#pragma mark - Actions

- (IBAction)clear:(id)sender
{
    self.title = @"";
    [self.tableView reloadData];
}

- (IBAction)closeTapped:(id)sender
{
    NSLog(@"close Tapped");
    [[self presentingViewController] dismissViewControllerAnimated: YES completion:nil];
}
- (IBAction)jsonTapped:(id)sender
{
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
    NSLog(@"number of rows, section: %d",section);
    
    switch(section)
    {
        case 0:
        case 1:
            if(!self.results)
                return 0;
            NSLog(@"results rows: %d",[self.results count]);
            return [self.results count];
            break;
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
        case 1:
            return @"Data Sets";
            break;
    }
    return @"";
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"GeoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    switch (indexPath.section) {
            
        case 0:
        case 1:
        {
            NSDictionary *dict = self.results[indexPath.row];
            cell.textLabel.text = dict[@"label"];
            if ([dict[@"service"][@"esri"] boolValue] == true)
                cell.detailTextLabel.text = @"Esri Rest";
            else
                cell.detailTextLabel.text = @"WMS";

        }
            break;
    }
    
    
    
    return cell;
}


#pragma mark - Table view delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSDictionary *item = self.results[indexPath.row];

    NSLog(@"WMS: %@",item);
    UIStoryboard *MainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
    WMSTableViewController *info=[MainStoryboard instantiateViewControllerWithIdentifier:@"WMSController"];
    info.result = item;
   // item[@"title"]=item[@"label"];
    
    [self.navigationController pushViewController:info animated:YES ];
}


#pragma mark - JMStatefulTableViewControllerDelegate
- (void) statefulTableViewControllerWillBeginInitialLoading:(JMStatefulTableViewController *)vc completionBlock:(void (^)())success failure:(void (^)(NSError *error))failure {
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
        NSLog(@"initial loading..");
        // 1
        NSString *string = [NSString stringWithFormat:@"%@?count=100&includeFacets=false&sortElement=label&sortOrder=asc&text=%@",self.geoplatform,self.search];
        NSURL *url = [NSURL URLWithString:string];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        // 2
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            // 3
            
            self.results = [NSMutableArray arrayWithArray:responseObject[@"results"]];
            
            
            
            self.title = @"JSON Retrieved";
            [self.tableView reloadData];
            dispatch_async(dispatch_get_main_queue(), ^{
                success();
            });
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            // 4
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Weather"
                                                                message:[error localizedDescription]
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            [alertView show];
        }];
        
        // 5
        [operation start];
        
    });
}

- (void) statefulTableViewControllerWillBeginLoadingFromPullToRefresh:(JMStatefulTableViewController *)vc completionBlock:(void (^)(NSArray *indexPathsToInsert))success failure:(void (^)(NSError *error))failure {
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
        NSLog(@"pull to refresh..");
        // 1
        NSString *string = [NSString stringWithFormat:@"%@?count=100&includeFacets=false&sortElement=label&sortOrder=asc&text=%@",_geoplatform,_search];
        NSURL *url = [NSURL URLWithString:string];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        // 2
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            // 3
            [self.results arrayByAddingObjectsFromArray: responseObject[@"results"]];
            
            self.title = @"JSON Retrieved";
            //[self.tableView reloadData];
            
            NSMutableArray *a = [NSMutableArray array];
            
            for(NSInteger i = 0; i < [self.results count]; i++) {
                [a addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                success([NSArray arrayWithArray:a]);
            });
            
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            // 4
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Weather"
                                                                message:[error localizedDescription]
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            [alertView show];
        }];
        [operation start];
        
    });
}


- (void) statefulTableViewControllerWillBeginLoadingNextPage:(JMStatefulTableViewController *)vc completionBlock:(void (^)())success failure:(void (^)(NSError *))failure {
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
        self.numItems+=100;
        NSLog(@"loading next page.. %d",self.numItems);
        
        // 1
        NSString *string = [NSString stringWithFormat:@"%@?count=100&includeFacets=false&sortElement=label&sortOrder=asc&start=%d&text=%@",_geoplatform,_numItems,_search];
        NSURL *url = [NSURL URLWithString:string];
        NSLog(@"loading next page.. %@",string);
        
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        // 2
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            // 3
            
            [self.results addObjectsFromArray: responseObject[@"results"]];
            NSLog(@"arows: %d",[self.results count]);
            
            self.title = @"JSON Retrieved";
            [self.tableView reloadData];
            dispatch_async(dispatch_get_main_queue(), ^{
                success();
            });
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            // 4
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Weather"
                                                                message:[error localizedDescription]
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            [alertView show];
        }];
        
        // 5
        [operation start];
        
    });
}

/* is there more content? */

- (BOOL) statefulTableViewControllerShouldBeginLoadingNextPage:(JMStatefulTableViewController *)vc {
    NSLog(@"should begin next page..");
    return true;
}


- (BOOL) statefulTableViewControllerShouldPullToRefresh:(JMStatefulTableViewController *)vc
{
    return false;
}

- (void) statefulTableViewController:(JMStatefulTableViewController *)vc didTransitionToState:(JMStatefulTableViewControllerState)state
{
    self.tableView.tableHeaderView = self.searchController.searchBar;

}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    // update the filtered array based on the search text
    NSString *searchText = searchController.searchBar.text;
    NSLog(@"asearch text: %@",searchText);
    _search = searchText;
    // change the query
    [ _results removeAllObjects];
    [ self loadNewer];
    
}
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    
    NSLog(@"bsearch text: %@",searchText);


}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    NSLog(@"csearch text: %@",searchString);


    return YES;
}

@end
