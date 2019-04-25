//
//  SampleSegueData.m
//  GettingStarted
//
//  Created by Fernando Sanchez Vilas on 22/04/2019.
//  Copyright © 2019 Situm Technologies S.L. All rights reserved.
//

#import "SampleSegueData.h"
@interface SampleSegueData()
@property (nonatomic,strong) NSString *sampleName;
@property (nonatomic,strong) NSString *segueId;
@end

@implementation SampleSegueData
-(instancetype)initWithSampleName:(NSString *)sampleName segueId:(NSString *)segueId{
    self = [super init];
    if (self) {
        self.sampleName=sampleName;
        self.segueId=segueId;
    }
    return self;
}
@end
