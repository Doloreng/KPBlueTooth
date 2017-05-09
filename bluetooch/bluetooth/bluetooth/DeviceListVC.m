//
//  DeviceListVC.m
//  bluetooth
//
//  Created by Eason on 2017/5/8.
//  Copyright © 2017年 eason. All rights reserved.
//

#import "DeviceListVC.h"
#import "BluetoochManager.h"
#import "ServicesViewController.h"
@interface DeviceListVC ()

@end

@implementation DeviceListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"设备列表";
    
    [self searchDeviceList];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[BluetoochManager sharedInstance] disconnectCurrentPeripheral];
}
/**
 搜索设备列表
 */
-(void)searchDeviceList{
    BluetoochManager *manager=[BluetoochManager sharedInstance];
    __weak typeof(self) wSelf=self;
    [manager startScanningForUUIDString:nil callBack:^(NSError *error, NSArray *devices) {
        //
        NSLog(@"devices %@",devices);
        [wSelf refreshDeviceList:devices];
    }];
}

/**
 更新搜索到的设备列表

 @param devices 设备列表
 */
-(void)refreshDeviceList:(NSArray *)devices{
    self.listArr=[NSMutableArray arrayWithArray:devices];
    [self.listVc reloadData];
    
}

/**
 搜索设备相关的服务

 @param per 设备
 */
-(void)searchService:(CBPeripheral*)per{
    UIStoryboard *main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ServicesViewController *vc=[main instantiateViewControllerWithIdentifier:@"ServicesViewControllerID"];
    [vc setDevice:per];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark BaseList
-(void)updateCell:(UITableViewCell *)cell forItem:(id)item{
    CBPeripheral *per=item;
    cell.textLabel.text=[NSString stringWithFormat:@"设备名称：%@\n",per.name];
}
-(void)didSelectCell:(UITableViewCell *)cell forItem:(id)item{
    CBPeripheral *per=item;
    __weak typeof(self) wSelf=self;
    [[BluetoochManager sharedInstance] connectPeripheral:per callBack:^(NSError *error, ConnectDeviceType cType) {
        //
        if (error) {
            NSLog(@"连接失败 %@",error);
        }else{
            NSLog(@"连接成功");
            if (cType ==DEVICE_SUCCESSCONNECTSTATE) {
                [wSelf searchService:per];
            }
            
        }
    }];
}
@end
