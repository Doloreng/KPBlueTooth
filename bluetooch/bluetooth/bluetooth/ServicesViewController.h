//
//  ServicesViewController.h
//  bluetooth
//
//  Created by Eason on 2017/5/8.
//  Copyright © 2017年 eason. All rights reserved.
//

#import "BaseListViewController.h"
#import "BluetoochManager.h"
@interface ServicesViewController : BaseListViewController
-(void)setDevice:(CBPeripheral*)per;
@end
