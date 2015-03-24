//
//  ViewController.m
//  WMSViewer
//
//  Created by Alan Steremberg on 3/11/15.
//  Copyright (c) 2015 Alan Steremberg. All rights reserved.
//

#import "ViewController.h"
#import "AFHTTPRequestOperation.h"
#import <KissXML/DDXML.h>

@interface ViewController ()

@end

@implementation ViewController
{
    MaplyBaseViewController *theViewC;
    WhirlyGlobeViewController *globeViewC;
    MaplyViewController *mapViewC;
    MaplyQuadImageTilesLayer *backgroundlayer;

}

- (IBAction)ClearLayers:(id)sender
{
    NSLog(@"clear all called");
    [theViewC removeAllLayers];
    [theViewC addLayer:backgroundlayer];

}


// Set this to false for a map
const bool DoGlobe = true;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"RemoveLayers"]){
        NSLog(@"remove layers transition");
//        WMSTableViewController *wac = (WMSTableViewController *)segue.destinationViewController;
//        wac.result = w;
        
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    if (DoGlobe)
    {
        globeViewC = [[WhirlyGlobeViewController alloc] init];
        theViewC = globeViewC;
    } else {
        mapViewC = [[MaplyViewController alloc] init];
        theViewC = mapViewC;
    }
    
    // Create an empty globe or map and add it to the view
  //  [self.view addSubview:theViewC.view];
    [self.view insertSubview:theViewC.view belowSubview:self.AddLayer];
    theViewC.view.frame = self.view.bounds;
    [self addChildViewController:theViewC];

    
    // Do any additional setup after loading the view, typically from a nib.
    // this logic makes it work for either globe or map
  //  WhirlyGlobeViewController *globeViewC = nil;
  //  MaplyViewController *mapViewC = nil;
    if ([theViewC isKindOfClass:[WhirlyGlobeViewController class]])
        globeViewC = (WhirlyGlobeViewController *)theViewC;
    else
        mapViewC = (MaplyViewController *)theViewC;
    
    // we want a black background for a globe, a white background for a map.
    theViewC.clearColor = (globeViewC != nil) ? [UIColor blackColor] : [UIColor whiteColor];
    
    // and thirty fps if we can get it ­ change this to 3 if you find your app is struggling
    theViewC.frameInterval = 2;
    
    // add the capability to use the local tiles or remote tiles
    bool useLocalTiles = false;
    
    // we'll need this layer in a second
    MaplyQuadImageTilesLayer *layer;
    
    if (useLocalTiles)
    {
        MaplyMBTileSource *tileSource =
        [[MaplyMBTileSource alloc] initWithMBTiles:@"geography­-class_medres"];
        layer = [[MaplyQuadImageTilesLayer alloc]
                 initWithCoordSystem:tileSource.coordSys tileSource:tileSource];
    } else {
        // Because this is a remote tile set, we'll want a cache directory
        NSString *baseCacheDir =
        [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)
         objectAtIndex:0];
        NSString *aerialTilesCacheDir = [NSString stringWithFormat:@"%@/osmtiles/",
                                         baseCacheDir];
        int maxZoom = 18;
        
        // MapQuest Open Aerial Tiles, Courtesy Of Mapquest
        // Portions Courtesy NASA/JPL­Caltech and U.S. Depart. of Agriculture, Farm Service Agency
        MaplyRemoteTileSource *tileSource =
        [[MaplyRemoteTileSource alloc]
         initWithBaseURL:@"http://otile1.mqcdn.com/tiles/1.0.0/sat/"
         ext:@"png" minZoom:0 maxZoom:maxZoom];
        tileSource.cacheDir = aerialTilesCacheDir;
        layer = [[MaplyQuadImageTilesLayer alloc]
                 initWithCoordSystem:tileSource.coordSys tileSource:tileSource];
    }
    
    backgroundlayer = layer;
    
    
#if 0
   NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)  objectAtIndex:0];
    NSString *thisCacheDir = nil;

    thisCacheDir = [NSString stringWithFormat:@"%@/wms_layer/",cacheDir];
  /*  [self fetchWMSLayer:@"http://raster.nationalmap.gov/ArcGIS/services/Orthoimagery/USGS_EDC_Ortho_NAIP/ImageServer/WMSServer" layer:@"0" style:nil cacheDir:thisCacheDir ovlName:nil];*/
    [self fetchWMSLayer:@"http://nowcoast.noaa.gov/wms/com.esri.wms.Esrimap/obs" layer:@"RAS_RIDGE_NEXRAD" style:nil cacheDir:thisCacheDir ovlName:nil];
#endif
    
    
    layer.handleEdges = (globeViewC != nil);
    layer.coverPoles = (globeViewC != nil);
    layer.requireElev = false;
    layer.waitLoad = false;
    layer.drawPriority = 0;
    layer.singleLevelLoading = false;
    [theViewC addLayer:layer];
    
    // start up over San Francisco, center of the universe
    if (globeViewC != nil)
    {
        globeViewC.height = 0.8;
        [globeViewC animateToPosition:MaplyCoordinateMakeWithDegrees(-122.4192,37.7793)
                                 time:1.0];
    } else {
        mapViewC.height = 1.0;
        [mapViewC animateToPosition:MaplyCoordinateMakeWithDegrees(-122.4192,37.7793)
                               time:1.0];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(AddWMSLayer:)
                                                 name:@"AddWMSLayer"
                                               object:nil];

    
}
- (void) AddWMSLayer:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString:@"AddWMSLayer"])
    {
        NSLog (@"Successfully received the AddWMSLayer notification! %@",[notification object]);
        NSDictionary *theDict = (NSDictionary *)[notification object];
        
    
        
        NSString *url = theDict[@"result"][@"url"];
        MaplyWMSLayer *layer = theDict[@"layer"];
        NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)  objectAtIndex:0];
        NSString *thisCacheDir = nil;
       thisCacheDir = [NSString stringWithFormat:@"%@/wms_layer/",cacheDir];
        [self fetchWMSLayer:url layer:layer.name style:nil cacheDir:thisCacheDir ovlName:nil];

    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)fetchWMSLayer:(NSString *)baseURL layer:(NSString *)layerName style:(NSString *)styleName cacheDir:(NSString *)thisCacheDir ovlName:(NSString *)ovlName

{
    NSString * capabilitiesURL = nil;
    
    // many of the URLs from CKAN have the capabilities in it already..
   // NSRange range = [baseURL rangeOfString: @"GetCapabilities" options: NSCaseInsensitiveSearch];
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
    
    NSLog(@"about to load WMS: %@ %@",baseURL,capabilitiesURL);
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:capabilitiesURL]]];
    
    operation.responseSerializer = [AFXMLParserResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/vnd.ogc.wms_xml",@"text/xml",@"application/xml",nil];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        
        NSLog(@"HTML-->peration:%@",operation.responseString);
        
        NSLog(@"HTML-->responseObject:%@",responseObject);
        
        NSError *error;
        
        DDXMLDocument *doc = [[DDXMLDocument alloc] initWithData:operation.responseData options:0 error:&error];
        
        [self startWMSLayerBaseURL:baseURL xml:doc layer:layerName style:styleName cacheDir:thisCacheDir ovlName:ovlName];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        // Sometimes this works anyway
        
        // if (![self startWMSLayerBaseURL:baseURL xml:responseObject layer:layerName style:styleName cacheDir:thisCacheDir ovlName:ovlName])
        
        NSLog(@"Failed to get capabilities from WMS server: %@ %@",capabilitiesURL,error);
        
    }];
    
    
    
    [operation start];
    
}
// Try to start the layer, given the capabilities

- (bool)startWMSLayerBaseURL:(NSString *)baseURL xml:(DDXMLDocument *)XMLDocument layer:(NSString *)layerName style:(NSString *)styleName cacheDir:(NSString *)thisCacheDir ovlName:(NSString *)ovlName

{
    
    // See what the service can provide
    
    MaplyWMSCapabilities *cap = [[MaplyWMSCapabilities alloc] initWithXML:XMLDocument];
    
    MaplyWMSLayer *layer = [cap findLayer:layerName];
    
    MaplyCoordinateSystem *coordSys = [layer buildCoordSystem];
    
    MaplyWMSStyle *style = [layer findStyle:styleName];
    
    if (!layer)
        
    {
        
        NSLog(@"Couldn't find layer %@ in WMS response.",layerName);
        
        return false;
        
    } else if (!coordSys)
        
    {
        
        NSLog(@"No coordinate system we recognize in WMS response.");
        
        return false;
        
    } else if (styleName && !style)
        
    {
        
        NSLog(@"No style named %@ in WMS response.",styleName);
        
        return false;
        
    }
    
    
    
    if (layer && coordSys)
        
    {
        
        MaplyWMSTileSource *tileSource = [[MaplyWMSTileSource alloc] initWithBaseURL:baseURL capabilities:cap layer:layer style:style coordSys:coordSys minZoom:0 maxZoom:16 tileSize:256];
        
        tileSource.cacheDir = thisCacheDir;
        
        tileSource.transparent = true;
        
        MaplyQuadImageTilesLayer *imageLayer = [[MaplyQuadImageTilesLayer alloc] initWithCoordSystem:coordSys tileSource:tileSource];
        
        imageLayer.coverPoles = false;
        
        imageLayer.handleEdges = true;
        
        imageLayer.requireElev = false;
        
        imageLayer.waitLoad = false;
        
      //  [baseViewC addLayer:imageLayer];
         [theViewC addLayer:imageLayer];
        
        
        //if (ovlName)
            
        //    ovlLayers[ovlName] = imageLayer;
        
    }
    
    
    
    return true;
    
}



@end
