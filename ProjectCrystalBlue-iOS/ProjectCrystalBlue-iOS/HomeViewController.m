//
//  HomeViewController.m
//  ProjectCrystalBlue-iOS
//
//  Created by Ryan McGraw on 3/1/14.
//  Copyright (c) 2014 Project Crystal Blue. All rights reserved.
//

#import "HomeViewController.h"
#import "SourceViewController.h"
#import "AddSampleOneViewController.h"
#import "DeleteSourcesViewController.h"
#import "CredentialsViewController.h"
#import "EmbedReaderViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UINavigationItem *n = [self navigationItem];
        [n setTitle:@"Project Crystal Blue"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIViewController *credentialsView = [[CredentialsViewController alloc] initWithNibName:@"CredentialsViewController"
                                                                                    bundle:nil];
    [self presentViewController:credentialsView animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)viewSources:(id)sender
{
    SourceViewController *sourceViewController = [[SourceViewController alloc] init];
    [[self navigationController] pushViewController:sourceViewController  animated:YES];
    
}

- (IBAction)addSource:(id)sender
{
    AddSampleOneViewController *asoViewController = [[AddSampleOneViewController alloc] init];
    [[self navigationController] pushViewController:asoViewController  animated:YES];
}

- (IBAction)scanQRCode:(id)sender
{
    EmbedReaderViewController *scanViewController = [[EmbedReaderViewController alloc] init];
    [[self navigationController] pushViewController:scanViewController animated:YES];
}

@end
