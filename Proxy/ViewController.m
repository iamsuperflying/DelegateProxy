//
//  ViewController.m
//  Proxy
//
//  Created by 李鹏飞 on 2020/3/23.
//  Copyright © 2020 LPF. All rights reserved.
//

#import "ViewController.h"
#import "TestViewController.h"

@interface ViewController ()<RSTestProtocol>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    TestViewController *tv = [TestViewController new];
    tv.delegate = self;
    [self presentViewController:tv animated:YES completion:nil];
}

//- (void)testFunctionValue1:(id)value1 value2:(id)value2 {
//    
//}
//
//- (id)testFunctionWithReturnValue1:(id)value1 value2:(id)value2 {
//    return self;
//}

@end
