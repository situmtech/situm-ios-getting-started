//
//  ViewController.m
//  GettingStarted
//
//  Created by A Barros on 21/9/17.
//  Copyright © 2017 Situm Technologies S.L. All rights reserved.
//

#import "ViewController.h"

static NSString *SampleCellIdentifier = @"SampleCell";

// Samples static strings
static NSString *LocationAndRealTimeOnMapSample = @"Location and real time";

static NSString *RouteAndIndicationsOnMapSample = @"Route on map";

// Segues static strings
static NSString *LocationAndRealTimeOnMapSampleSegue = @"LocationAndRealTimeOnTopOfMapSampleSegue";

static NSString *RouteAndIndicationsOnMapSampleSegue = @"RouteAndIndicationsOnMapSampleSegue";



@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *samples;

@end

@implementation ViewController

@synthesize samples = _samples;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.samples = @[
                     LocationAndRealTimeOnMapSample,
                     RouteAndIndicationsOnMapSample
                     ];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)detectedSample:(NSString *)sample
{
    if ([sample isEqualToString:LocationAndRealTimeOnMapSample]) {
        [self performSegueWithIdentifier:LocationAndRealTimeOnMapSampleSegue
                                  sender:self];
    } else if ([sample isEqualToString:RouteAndIndicationsOnMapSample]) {
        [self performSegueWithIdentifier:RouteAndIndicationsOnMapSampleSegue
                                  sender:self];
    }
}

-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
    // Nothing to do for now
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.samples.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SampleCellIdentifier];
    
    NSString *cellText = self.samples[indexPath.row];
    
    [cell.textLabel setText:cellText];
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Perform segue
    NSString *sample = self.samples[indexPath.row];
    [self detectedSample:sample];
    
}

@end
