//
//  SCTBuildingsListViewController.m
//  SitumCalibrationTool
//
//  Created by A Barros on 14/3/17.
//  Copyright © 2017 Situm Technologies S.L. All rights reserved.
//

#import "SGSBuildingsListViewController.h"

#import <SitumSDK/SitumSDK.h>
#import "SGSUserInsideEventVC.h"
#import "SGSLocationAndRealtimeVC.h"

@interface SGSBuildingsListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *buildingsTableView;

@property (nonatomic, strong) NSArray *buildings; // model

@property (nonatomic, strong) SITBuildingInfo *selectedBuildingInfo;

@property (nonatomic, strong) NSString *segueIdentifier;

@end

@implementation SGSBuildingsListViewController

@synthesize buildingsTableView = _buildingsTableView;

@synthesize buildings = _buildings;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self retrieveData];
    
    self.buildingsTableView.dataSource = self;
    self.buildingsTableView.delegate = self;
    self.segueIdentifier = nil;
    
    if ([self.originSegue isEqualToString:  @"UserInsideEventSampleSegue"]) {
        self.segueIdentifier = @"UserInsideEvent2SampleSegue";
    } else if ([self.originSegue isEqualToString:  @"LocationAndRealTimeOnTopOfMapSampleSegue"]) {
        self.segueIdentifier = @"LocationAndRealTimeOnTopOfMap2SampleSegue";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender  {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UIViewController *destinationVC = segue.destinationViewController;
    if ([destinationVC isMemberOfClass:[SGSUserInsideEventVC class]]) {
        ((SGSUserInsideEventVC *)destinationVC).selectedBuildingInfo = self.selectedBuildingInfo;
    } else if ([destinationVC isMemberOfClass:[SGSLocationAndRealtimeVC class]]) {
        ((SGSLocationAndRealtimeVC *)destinationVC).selectedBuildingInfo = self.selectedBuildingInfo;
    }
}

#pragma mark -

- (void)retrieveData
{
    __weak typeof(self) welf = self;
    [[SITCommunicationManager sharedManager] fetchBuildingsWithOptions:nil success:^(NSDictionary *mapping) {
        NSArray<SITBuilding*>* buildings = [mapping valueForKey:@"results"];
        NSLog(@"%@", buildings);
        
        for (SITBuilding *building in buildings) {
            NSLog(@"%@", building.name);
        }
        welf.buildings = [mapping valueForKey:@"results"];
        
        [welf reloadData];
        
        
    } failure:^(NSError *error) {
        NSLog(@"error fetching buildings: %@", error);
    }];

}

- (void)reloadData
{
    [self.buildingsTableView reloadData];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return self.buildings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BuildingTableViewCell"];
    
    SITBuilding *building = self.buildings[indexPath.row];
    
    cell.textLabel.text = building.name;
    return cell;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Go to fetch information
    
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    SITBuilding *selectedBuilding = self.buildings[indexPath.row];
    
    UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Retrieving information. "
message:@"Hold on for a moment"
                                               delegate:nil
                                      cancelButtonTitle:nil
                                      otherButtonTitles:nil];
    [av show];
    
    __weak typeof(self) welf = self;
    
    [[SITCommunicationManager sharedManager] fetchBuildingInfo:selectedBuilding.identifier
                                                   withOptions:nil
                                                       success:^(NSDictionary *mapping) {
                                                           
                                                           [av dismissWithClickedButtonIndex:0
                                                                                    animated:YES];
                                                           
                                                           self.selectedBuildingInfo = [mapping valueForKey:@"results"];
                                                           
                                                           if (self.segueIdentifier != nil) {
                                                               [welf performSegueWithIdentifier:self.segueIdentifier sender:self];
                                                           }
                                                       }
                                                       failure:^(NSError *error) {
                                                           NSLog(@"error fetching information of the building: %@ ", error);
                                                           [av dismissWithClickedButtonIndex:0
                                                                                    animated:YES];
                                                           
                                                       }];
}

- (IBAction)unwindFromPositioning:(UIStoryboardSegue *)segue
{
    
}

@end
