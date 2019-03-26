//
//  SGSExamplesBaseVC.h
//  GettingStarted
//
//  Created by Fernando Sanchez Vilas on 26/03/2019.
//  Copyright © 2019 Situm Technologies S.L. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SGSExamplesBaseVC : UIViewController
-(void)customizeNavigationBarWithTitle:(NSString *)title;
-(void)exitExample:(UIBarButtonItem *)sender; 
@end

NS_ASSUME_NONNULL_END
