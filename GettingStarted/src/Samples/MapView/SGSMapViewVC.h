//
//  SGSMapViewVC.h
//  GettingStarted
//
//  Created by fsvilas on 28/7/23.
//  Copyright © 2023 Situm Technologies S.L. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SitumSDK/SitumSDK.h>
#import "SGSSamplesBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface SGSMapViewVC : SGSSamplesBaseVC
@property(nonatomic,strong) SITBuildingInfo *selectedBuildingInfo;
@end

NS_ASSUME_NONNULL_END
