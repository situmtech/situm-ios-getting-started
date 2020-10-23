//
//  SGSPositioningVC.h
//  GettingStarted
//
//  Created by Fernando Sanchez Vilas on 28/03/2019.
//  Copyright © 2019 Situm Technologies S.L. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SitumSDK/SitumSDK.h>
#import "SGSSamplesBaseVC.h"
NS_ASSUME_NONNULL_BEGIN

@interface SGSPositioningVC : SGSSamplesBaseVC<CLLocationManagerDelegate>
@property(nonatomic,strong) SITBuildingInfo *selectedBuildingInfo;
@end

NS_ASSUME_NONNULL_END
