//
//  CharacteristicsVC.m
//  bluetooth
//
//  Created by Eason on 2017/5/9.
//  Copyright © 2017年 eason. All rights reserved.
//

#import "CharacteristicsVC.h"

@interface CharacteristicsVC ()

@end

@implementation CharacteristicsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.cb_per&&self.cb_serv) {
        [self discoverCharacteristics:_cb_per service:_cb_serv];
    }
    NSArray *chaArr=self.cb_serv.characteristics;
    for (CBCharacteristic *item in chaArr) {
        NSLog(@"该服务中含有的特性:%@",item);
    }
    // Do any additional setup after loading the view.
}

/**
 发现特性列表

 @param per 设备
 @param service 服务
 */
-(void)discoverCharacteristics:(CBPeripheral*)per service:(CBService*)service{
    __weak typeof(self) wSelf=self;
    [[BluetoochManager sharedInstance] discoverCharacteristicsAtPeripheral:per ofService:service callBack:^(NSError *error, NSArray *characteristics) {
        //
        [wSelf refreshlist:characteristics];
    }];
}
-(void)refreshlist:(NSArray*)chas{
    self.listArr=[NSMutableArray arrayWithArray:chas];
    [self.listVc reloadData];
}

-(void)decodeResultData:(NSData*)data{
    if(!data){
        return;
    }
    NSString *str=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"结果 %@", str);
}

-(void)handleNotifyCharacteristic:(CBCharacteristic*)cha type:(CharacteristicNotifyType)type error:(NSError*)error data:(NSData*)data{
    switch (type) {
        case CHARACTERISTIC_WRITESTATE:
        {
            //写入状态通知
            NSLog(@"写入状态通知");
        }
            break;
        case CHARACTERISTIC_UPDATEVALUESTATE:
        {
            //数据回调通知
            if (data) {
                [self decodeResultData:data];
            }
            
        }
            break;
        case CHARACTERISTIC_NOTIFYSTATE:
        {
            //特性状态通知
            NSLog(@"订阅通知的更新");
        }
            break;
            
        default:
            break;
    }
}
#pragma mark BaseListView
-(void)updateCell:(UITableViewCell *)cell forItem:(id)item{
    CBCharacteristic *chtt=item;
    cell.textLabel.text=[NSString stringWithFormat:@"特性：%@\n",chtt];
    cell.textLabel.font=[UIFont systemFontOfSize:12];
    cell.textLabel.numberOfLines=0;
}
-(void)didSelectCell:(UITableViewCell *)cell forItem:(id)item{
    __weak typeof(self) wSelf=self;
    
    CBCharacteristic *cha=item;
//    [[BluetoochManager sharedInstance] setNotifyValueAtPeripheral:self.cb_per forCharacteristic:cha callBack:^(NSError *error, CharacteristicNotifyType aType, NSData *data) {
//        //
//        NSLog(@"监听到的数据变化:\n error:%@,\n type: %ld \n data:%@",error,aType,data);
//        [wSelf handleNotifyCharacteristic:item type:aType error:error data:data];
//        
//    }];
    [[BluetoochManager sharedInstance] readValueAtPeripheral:self.cb_per forCharacteristic:cha callBack:^(NSError *error, CharacteristicNotifyType aType, NSData *data) {
        //
        NSLog(@"监听到的数据变化:\n error:%@,\n type: %ld \n data:%@",error,(long)aType,data);
        [wSelf handleNotifyCharacteristic:item type:aType error:error data:data];
    }];
    
}
-(CGFloat)cellHeight{
    return 64;
}
@end
