//
//  SplitViewController.m
//  ProjectCrystalBlue-iOS
//
//  Created by Ryan McGraw on 2/8/14.
//  Copyright (c) 2014 Project Crystal Blue. All rights reserved.
//

#import "SplitViewController.h"
#import "Split.h"
#import "DDLog.h"
#import "SplitEditViewController.h"
#import "ProcedureListViewController.h"
#import "AbstractCloudLibraryObjectStore.h"
#import "AbstractMobileCloudImageStore.h"
#import "SampleImageUtils.h"
#import "Procedures.h"
#import "PrimitiveProcedures.h"
#import "Reachability.h"
#import "PCBLogWrapper.h"

@interface SplitViewController ()
{
    NSArray *splits;
    NSString* option;
    NSString* delOption;
    Split *selectedSplit;
    int selectedRow;
}
@end

@implementation SplitViewController

@synthesize selectedSample, libraryObjectStore;

- (id)initWithSample:(Sample *)initSample
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        selectedSample = initSample;
        
        UINavigationItem *n = [self navigationItem];
        NSString *title = selectedSample.key;
        title = [title stringByAppendingString:@" Splits"];
        [n setTitle:title];
        
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc]
                                initWithTitle:@"Add New" style:UIBarButtonItemStyleBordered target:self action:@selector(addNewItem:)];
        UIBarButtonItem *backbtn = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(goBack:)];
        
        [[self navigationItem] setRightBarButtonItem:bbi];
        [[self navigationItem] setLeftBarButtonItem:backbtn];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Control for sync visual cue
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self
                       action:@selector(syncSplits)
             forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refreshControl;
}

- (void)syncSplits
{
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    if ([reach isReachable]) {
        [libraryObjectStore synchronizeWithCloud];
        [(AbstractMobileCloudImageStore *)[SampleImageUtils defaultImageStore] synchronizeWithCloud];
    }
    
    [self updateDisplayedSplits];
    [self.refreshControl endRefreshing];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self updateDisplayedSplits];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return splits.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"UITableViewCell"];
    }
    
    Split *split = [splits objectAtIndex:[indexPath row]];
    [[cell textLabel] setText:[split description]];
    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedSplit = [splits objectAtIndex:[indexPath row]];
    UIActionSheet *message;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        
        message = [[UIActionSheet alloc] initWithTitle:@"Action:" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Perform Procedure", @"View Split", @"Delete Split", nil];
    }
    else
    {
        message = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Perform Procedure", @"View Split", @"Delete Split", nil];
    }
    
    CGRect cellRect = [self.tableView cellForRowAtIndexPath:indexPath].frame;
    cellRect.origin.y += cellRect.size.height;
    cellRect.origin.y -= self.tableView.contentOffset.y;
    cellRect.size.height = 1;
    
    [message showFromRect:cellRect inView:[UIApplication sharedApplication].keyWindow animated:YES];
    
    while ((!message.hidden) && (message.superview != nil))
    {
        [[NSRunLoop currentRunLoop] limitDateForMode:NSDefaultRunLoopMode];
    }
    
    if([option isEqualToString:@"PROC"])
    {
        ProcedureListViewController *procedureListViewController = [[ProcedureListViewController alloc] initWithSplit:selectedSplit WithLibrary:libraryObjectStore];
        [[self navigationController] pushViewController:procedureListViewController  animated:YES];
    }
    
    if([option isEqualToString:@"VIEW"])
    {
        SplitEditViewController *splitEditViewController =
        [[SplitEditViewController alloc] initWithSplit:selectedSplit
                                             WithLibrary:libraryObjectStore
                                   AndNavigateBackToRoot:NO];
        
        [[self navigationController] pushViewController:splitEditViewController animated:YES];
    }
    if([option isEqualToString:@"DEL"])
    {
        selectedRow = indexPath.row;
        NSString *alertMessage = @"Are you sure you want to delete ";
        alertMessage = [alertMessage stringByAppendingString:[selectedSplit key  ]];
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:alertMessage
                              message:nil
                              delegate:self
                              cancelButtonTitle:@"No"
                              otherButtonTitles:@"Yes", nil];
        [alert show];
    }
}

- (void)updateDisplayedSplits
{
    splits = [libraryObjectStore getAllSplitsForSampleKey:selectedSample.key];
    [self.tableView reloadData];
}

- (void)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addNewItem:(id)sender
{
    Split *split;
    
    if (splits.count != 0)
        split = [splits firstObject];
    else
    {
        NSString *key = [PrimitiveProcedures uniqueKeyBasedOn:[selectedSample.key stringByAppendingString:@".001"]
                                                      inStore:libraryObjectStore
                                                      inTable:[SplitConstants tableName]];
        
        split = [[Split alloc] initWithKey:key
                         AndWithAttributes:[SplitConstants attributeNames]
                                 AndValues:[SplitConstants attributeDefaultValues]];
        [split.attributes setObject:selectedSample.key forKey:SPL_SAMPLE_KEY];
    }
    
    [Procedures addFreshSplit:split inStore:libraryObjectStore];
    [self updateDisplayedSplits];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
            option = @"PROC";
            break;
        case 1:
            option = @"VIEW";
            break;
        case 2:
            option = @"DEL";
            break;
        case 3:
            option = @"NOTHING";
            break;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
            break;
        case 1:
        {
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
            
            NSNumber *count = [formatter numberFromString:[selectedSample.attributes objectForKey:SMP_NUM_SPLITS]];
            count = [NSNumber numberWithInt:[count intValue] - 1];
            [selectedSample.attributes setObject:count.stringValue forKey:SMP_NUM_SPLITS];
            [libraryObjectStore updateLibraryObject:selectedSample IntoTable:[SampleConstants tableName]];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshSampleData"
                                                                object:self];
            
            [libraryObjectStore deleteLibraryObjectWithKey:selectedSplit.key FromTable:[SplitConstants tableName]];
            [self updateDisplayedSplits];
        }
    }
}

@end
