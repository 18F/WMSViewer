//
//  WMSTableViewController.m
//  WMSViewer
//
//  Created by Alan Steremberg on 3/23/15.
//  Copyright (c) 2015 Alan Steremberg. All rights reserved.
//

#import "WMSTableViewController.h"
#import "AFHTTPRequestOperation.h"
#import <KissXML/DDXML.h>

@interface WMSTableViewController ()
@property (nonatomic) NSMutableArray *layers;

@end

@implementation WMSTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    
}
- (void) viewWillAppear:(BOOL)animated {
    NSLog(@"View Will Appear");
    [super viewWillAppear:animated];
    
    NSLog(@"title: %@ url: %@ result: %@",self.result[@"title"],self.result[@"url"],self.result);
    self.title = self.result[@"title"];

    [self loadWMSURL: self.result[@"url"]];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Helper



- (void)loadWMSURL:(NSString *)baseURL {
    NSString * capabilitiesURL = nil;
    
    NSRange range = [baseURL rangeOfString: @"?" options: NSCaseInsensitiveSearch];
    if (range.location == NSNotFound)
    {
        capabilitiesURL = [MaplyWMSCapabilities CapabilitiesURLFor:baseURL];
    }
    else
    {
        //        capabilitiesURL = baseURL;
        NSArray * parts  = [baseURL componentsSeparatedByString:@"?"];
        baseURL = parts[0];
        capabilitiesURL = [MaplyWMSCapabilities CapabilitiesURLFor:baseURL];
        
    }

#if 0
    // many of the URLs from CKAN have the capabilities in it already..
    NSRange range = [baseURL rangeOfString: @"GetCapabilities" options: NSCaseInsensitiveSearch];
    if (range.location == NSNotFound)
    {
        capabilitiesURL = [MaplyWMSCapabilities CapabilitiesURLFor:baseURL];
    }
    else
    {
        capabilitiesURL = baseURL;
    }
#endif
    
AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:capabilitiesURL]]];

operation.responseSerializer = [AFXMLParserResponseSerializer serializer];
operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/vnd.ogc.wms_xml",@"text/xml",@"application/xml",nil];

[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
    
    
    
    NSLog(@"HTML-->peration:%@",operation.responseString);
    
    NSLog(@"HTML-->responseObject:%@",responseObject);
    
    NSError *error;
    
    DDXMLDocument *doc = [[DDXMLDocument alloc] initWithData:operation.responseData options:0 error:&error];
    
    MaplyWMSCapabilities *cap = [[MaplyWMSCapabilities alloc] initWithXML:doc];
    
    self.layers = cap.layers;
    
    [self.tableView reloadData];

    
} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    
    // Sometimes this works anyway
    
    // if (![self startWMSLayerBaseURL:baseURL xml:responseObject layer:layerName style:styleName cacheDir:thisCacheDir ovlName:ovlName])
    
    NSLog(@"Failed to get capabilities from WMS server: %@ %@",capabilitiesURL,error);
    
}];



[operation start];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
         return [self.layers count];
;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"WMSCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    MaplyWMSLayer *layer = self.layers[indexPath.row];
    
    
    cell.textLabel.text = layer.title;
    cell.detailTextLabel.text = layer.abstract;
    cell.detailTextLabel.numberOfLines = 6;
    cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
    

    // Configure the cell...
    
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - Table view delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
// we probably want to throw them the URL and the layer.. interesting
    NSMutableDictionary * theDict = [[NSMutableDictionary alloc] init] ;
    MaplyWMSLayer *layer = self.layers[indexPath.row];
    [theDict setValue: layer forKey: @"layer"];
    [theDict setValue: self.result forKey: @"result"];
    
    // All instances of TestClass will be notified
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"AddWMSLayer"
     object:theDict];
    [[self presentingViewController] dismissViewControllerAnimated: YES completion:nil];

}

@end
