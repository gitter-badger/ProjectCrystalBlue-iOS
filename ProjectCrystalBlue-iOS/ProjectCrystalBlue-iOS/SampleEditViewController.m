//
//  SampleEditViewController.m
//  ProjectCrystalBlue-iOS
//
//  Created by Ryan McGraw on 2/15/14.
//  Copyright (c) 2014 Project Crystal Blue. All rights reserved.
//

#import "SampleEditViewController.h"
#import "ProcedureRecordParser.h"

@interface SampleEditViewController ()

{
    NSArray *tags;
}

@end

@implementation SampleEditViewController

@synthesize selectedSample, libraryObjectStore;

- (id)initWithSample:(Sample*)initSample {
    // Call the superclass's designated initializer
    selectedSample = initSample;
    tags = [[NSMutableArray alloc] init];
    
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
        UINavigationItem *n = [self navigationItem];
        [n setTitle:[selectedSample key]];
        
        UIBarButtonItem *actions = [[UIBarButtonItem alloc] initWithTitle:@"Options" style:UIBarButtonItemStyleBordered target:self action:@selector(multiOptions:)];
        
        UIBarButtonItem *backbtn = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(goBack:)];
        
        [[self navigationItem] setRightBarButtonItem:actions];
        [[self navigationItem] setLeftBarButtonItem:backbtn];
        
    }
    return self;
}


-(void) goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (id)initWithStyle:(UITableViewStyle)style {
    return [self init];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([tags count] == 0)
        return 1;
    else
        return [tags count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Create an instance of UITableViewCell, with default appearance
    // Check for a reusable cell first, use that if it exists
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    // If there is no reusable cell of this type, create a new one
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"UITableViewCell"];
    }
    // Set the text on the cell with the description of the item // that is at the nth index of items, where n = row this cell // will appear in on the tableview
    //Sample *p = [samples objectAtIndex:[indexPath row]];
    if ([tags count] > 0) {
        NSString *p = [tags objectAtIndex:[indexPath row]];
        [[cell textLabel] setText:p];
    }
    else
        [[cell textLabel] setText:@"No Procedures Done"];
    
    return cell;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    tags = [ProcedureRecordParser nameArrayFromRecordList:[[selectedSample attributes] objectForKey:SMP_TAGS]];
}

@end
