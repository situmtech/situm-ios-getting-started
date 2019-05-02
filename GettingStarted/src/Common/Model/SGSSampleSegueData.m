//
//  SampleSegueData.m
//  GettingStarted
//
//  Created by Fernando Sanchez Vilas on 22/04/2019.
//  Copyright © 2019 Situm Technologies S.L. All rights reserved.
//

#import "SGSSampleSegueData.h"
@interface SGSSampleSegueData()
@property (nonatomic,strong) NSString *sampleName;
@property (nonatomic,strong) NSString *segueId;
@end

@implementation SGSSampleSegueData
-(instancetype)initWithSampleName:(NSString *)sampleName segueId:(NSString *)segueId{
    self = [super init];
    if (self) {
        self.sampleName=sampleName;
        self.segueId=segueId;
    }
    return self;
}
@end
