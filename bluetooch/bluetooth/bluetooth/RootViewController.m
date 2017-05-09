//
//  RootViewController.m
//  bluetooth
//
//  Created by Eason on 2017/5/8.
//  Copyright © 2017年 eason. All rights reserved.
//

#import "RootViewController.h"
#import "BluetoochManager.h"
#import "DeviceListVC.h"
@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"首页";
    // Do any additional setup after loading the view.
}
- (IBAction)searchPressed:(id)sender {
    [self testManager];
}
-(void)testManager{
   
    UIStoryboard *main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DeviceListVC *listVc=[main instantiateViewControllerWithIdentifier:@"DeviceListVCID"];
    [self.navigationController pushViewController:listVc animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
