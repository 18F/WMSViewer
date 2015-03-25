//
//  LayerTableViewController.m
//  WMSViewer
//
//  Created by Alan Steremberg on 3/25/15.
//  Copyright (c) 2015 Alan Steremberg. All rights reserved.
//

#import "LayerTableViewController.h"

@interface LayerTableViewController ()

@end

@implementation LayerTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
- (IBAction)close:(id)sender
{
    NSLog(@"close Tapped");
    [[self presentingViewController] dismissViewControllerAnimated: YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.layers count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DisposeCell" forIndexPath:indexPath];
    NSDictionary *thisLayer = self.layers[indexPath.row];

    // Configure the cell...
  //  NSString *imageLayer = thisLayer[@"layer"];
    NSString *name = thisLayer[@"layer"];
    MaplyWMSLayer * wmsLayer = thisLayer[@"wmslayer"];
    
    cell.textLabel.text = wmsLayer.title;
    cell.detailTextLabel.text = wmsLayer.abstract;
    cell.detailTextLabel.numberOfLines = 6;
    cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;

    
//    [thisLayer setValue:imageLayer forKey:@"layer"];
//    [thisLayer setValue:layerName forKey:@"name"];
//    [thisLayer setValue:layer forKey:@"wmslayer"];

    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark UITableViewRowAction

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    __weak LayerTableViewController *weakSelf = self;
    
    UITableViewRowAction *actionGreen =
    [UITableViewRowAction
     rowActionWithStyle:UITableViewRowActionStyleNormal
     title:@"Save"
     handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
         NSLog(@"Add!");
         [weakSelf.tableView setEditing:NO animated:YES];
         NSMutableDictionary * favitem = [[NSMutableDictionary alloc]init];
         
         
         NSDictionary *thisLayer = self.layers[indexPath.row];
         MaplyWMSLayer * wmsLayer = thisLayer[@"wmslayer"];
         NSString * url = thisLayer[@"url"];
         if (wmsLayer.name) [favitem setObject:wmsLayer.name forKey:@"name"];
         if (wmsLayer.title) [favitem setObject:wmsLayer.title forKey:@"title"];
         if (wmsLayer.abstract) [favitem setObject:wmsLayer.abstract forKey:@"abstract"];
         if (url) [favitem setObject:url forKey:@"url"];
         [self.favorites addObject:favitem];
         NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.favorites forKey:@"favorites"];
         [defaults synchronize];

#if 0
         [weakSelf.itemsList insertObject:@(arc4random_uniform(100) + 100) atIndex:indexPath.row + 1];
         [weakSelf.tableView setEditing:NO animated:YES];
         [weakSelf.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row + 1
                                                                         inSection:indexPath.section]]
                                   withRowAnimation:UITableViewRowAnimationAutomatic];
#endif
  
     }];
    
    actionGreen.backgroundColor = [UIColor colorWithRed:0.323 green:0.814 blue:0.303 alpha:1.000];
    
    UITableViewRowAction *actionRed =
    [UITableViewRowAction
     rowActionWithStyle:UITableViewRowActionStyleNormal
     title:@"Delete"
     handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
         NSLog(@"Delete!");
         [weakSelf.tableView setEditing:NO animated:YES];

         [weakSelf.map removeLayer: [weakSelf.layers objectAtIndex:indexPath.row][@"layer"]];
         [weakSelf.layers removeObjectAtIndex:indexPath.row];
         [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath]
                                   withRowAnimation:UITableViewRowAnimationAutomatic];

#if 0
         [weakSelf.itemsList removeObjectAtIndex:indexPath.row];
         [weakSelf.tableView setEditing:NO animated:YES];
         [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath]
                                   withRowAnimation:UITableViewRowAnimationAutomatic];
#endif
    
     }];
    
    actionRed.backgroundColor = [UIColor colorWithRed:0.844 green:0.242 blue:0.292 alpha:1.000];
    
    
    return @[actionGreen,actionRed];
}


/*
 * Must implement this method to make 'UITableViewRowAction' work.
 *
 */
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
}


#pragma mark - UITableViewDelegate

//Displaying
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //    cell.contentView.backgroundColor = [UIColor blueColor];
    //
    //    cell.backgroundColor = [UIColor purpleColor];
    
}

//Editing Table Rows
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    /*
     return UITableViewCellEditingStyleNone when entering on "Reorder Mode".
     This will make the "Move control" appear but without the "minus circle" although the tableCell will indent
     (we still need to specify that we don't want this indentation)
     
     return UITableViewCellEditingStyleDelete in order to make the "UITableViewRowAction" work.
     I couldn't find any explanation in the docs (Xcode 6 beta 6), I've come to this conclusion through trial & error :P
     
     */
    
    return self.tableView.isEditing ? UITableViewCellEditingStyleNone: UITableViewCellEditingStyleDelete;
}


//Don't indent the cell 'cause only the move control is going to appear (see: editingStyleForRowAtIndexPath )
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

//selection
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"Selected: %@", indexPath);
    
}


@end
