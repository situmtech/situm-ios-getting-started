//
//  SampleSegueData.h
//  GettingStarted
//
//  Created by Fernando Sanchez Vilas on 22/04/2019.
//  Copyright © 2019 Situm Technologies S.L. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SampleSegueData : NSObject
@property (nonatomic,strong, readonly) NSString *sampleName;
@property (nonatomic,strong, readonly) NSString *segueId;
-(instancetype)initWithSampleName:(NSString *)sampleName segueId:(NSString *)segueId NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
