//
//  RSTestProtocol.h
//  Proxy
//
//  Created by 李鹏飞 on 2020/3/23.
//  Copyright © 2020 LPF. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RSTestProtocol <NSObject>

@optional
- (void)testFunctionValue1:(id)value1 value2:(id)value2;


- (id)testFunctionWithReturnValue1:(id)value1 value2:(id)value2;

@end

NS_ASSUME_NONNULL_END
