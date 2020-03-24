//
//  TestViewController.m
//  Proxy
//
//  Created by 李鹏飞 on 2020/3/23.
//  Copyright © 2020 LPF. All rights reserved.
//

#import "TestViewController.h"
#import "RSDelegateProxy.h"

@interface TestViewController ()

@property (nonatomic, strong) RSDelegateProxy<RSTestProtocol> *delegateProxy;

@end

@implementation TestViewController

//RS_DELEGATE_PROXY(RSTestProtocol)

RS_DELEGATE_SETTER(RSTestProtocol)

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor greenColor];
    
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self.delegateProxy testFunctionValue1:@[@"1", @"2", @"3"] value2:@"value2"];
//    [self.delegateProxy test];
//    NSLog(@"%@", ret);
    
    
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

@end
