//
//  TestViewController.h
//  Proxy
//
//  Created by 李鹏飞 on 2020/3/23.
//  Copyright © 2020 LPF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSTestProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface TestViewController : UIViewController

@property (nonatomic, weak) id<RSTestProtocol> delegate;

@end

NS_ASSUME_NONNULL_END
