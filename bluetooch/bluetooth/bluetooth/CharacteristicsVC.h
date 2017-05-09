//
//  CharacteristicsVC.h
//  bluetooth
//
//  Created by Eason on 2017/5/9.
//  Copyright © 2017年 eason. All rights reserved.
//

#import "BaseListViewController.h"
#import "BluetoochManager.h"
@interface CharacteristicsVC : BaseListViewController
@property (nonatomic, strong) CBPeripheral *cb_per;
@property (nonatomic, strong) CBService *cb_serv;
@end
