//
//  SCTBuildingsListViewController.m
//  SitumCalibrationTool
//
//  Created by A Barros on 14/3/17.
//  Copyright © 2017 Situm Technologies S.L. All rights reserved.
//

#import "SGSBuildingsListViewController.h"

#import <SitumSDK/SitumSDK.h>

@interface SGSBuildingsListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *buildingsTableView;

@property (nonatomic, strong) NSArray *buildings; // model

@property (nonatomic, strong) SITBuildingInfo *selectedBuildingInfo;

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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    /*SCTPositioningViewController *destinationVC = (SCTPositioningViewController *)segue.destinationViewController;
    
    destinationVC.buildingInfo = self.selectedBuildingInfo;*/
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
    
    [[SITCommunicationManager sharedManager] fetchEventsFromBuilding:selectedBuilding withOptions:nil withCompletion:^SITHandler(NSArray<SITEvent *> *result, NSError *error) {
        NSLog(@"There are events");
        return false;
    }];
    
    [[SITCommunicationManager sharedManager] fetchOutdoorPoisOfBuilding:selectedBuilding.identifier withOptions:nil success:^(NSDictionary *mapping) {
        NSLog(@"There are Exterior POIs");
    } failure:^(NSError *error) {
    }];
    
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
                                                           NSArray<SITFloor*>* floors = self.selectedBuildingInfo.floors;
                                                           SITLocation *location;
                                                           for (SITFloor *floor in floors) {
                                                               if ([location.position.floorIdentifier isEqualToString:floor.identifier]) {
                                                                   NSLog([NSString stringWithFormat:@"User is located in floor: %@", floor.identifier]);
                                                               }
                                                           }
                                                           
                                                           [welf performSegueWithIdentifier:@"FromBuildingListToPositioning" sender:self];
                                                           
                                                       }
                                                       failure:^(NSError *error) {
                                                           NSLog(@"error fetching information of the building: %@ ", error);
                                                           [av dismissWithClickedButtonIndex:0
                                                                                    animated:YES];
                                                           
                                                       }];
    
    [[SITCommunicationManager sharedManager] fetchEventsFromBuilding:selectedBuilding withCompletion:^SITHandler(NSArray<SITEvent *> *result, NSError *error) {
        if (result) {
            //process events
        }
        if (error) {
            //handle error
        }
        return false;
    }];
}

- (IBAction)unwindFromPositioning:(UIStoryboardSegue *)segue
{
    
}

@end
