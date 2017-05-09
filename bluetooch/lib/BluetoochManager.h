//
//  BluetoochManager.h
//  bluetooth
//
//  Created by Eason on 2017/4/12.
//  Copyright © 2017年 eason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
typedef enum{
    DEVICE_FAILECONNECTSTATE,
    DEVICE_SUCCESSCONNECTSTATE,
    DEVICE_DISCONNECTSTATE,
    DEVICE_OFFLINESTATE
}ConnectDeviceType;

typedef NS_ENUM(NSInteger,CharacteristicNotifyType){
    CHARACTERISTIC_UPDATEVALUESTATE,    //特性数据更新
    CHARACTERISTIC_NOTIFYSTATE,         //特性状态通知
    CHARACTERISTIC_WRITESTATE           //特性写入通知
};

/**
 搜索蓝牙设备列表Block

 @param error 错误
 @param devices 设备列表
 */
typedef void (^DevicesCallBack)(NSError* error,NSArray*devices);

/**
 连接某个设备Block

 @param error 错误
 @param cType 连接状态
 */
typedef void(^ConnectCallBack)(NSError *error,ConnectDeviceType cType);

/**
 设备的服务Block

 @param error 错误
 @param services 服务列表
 */
typedef void(^DiscoverServicesCallBack)(NSError*error,NSArray*services);

/**
 设备的服务特性Block

 @param error 错误
 @param characteristics 特性列表
 */
typedef void(^DiscoverCharacteristicsForServiceCallBack)(NSError*error,NSArray*characteristics);

/**
 收到更新到的特性数据

 @param error 错误
 @param data 数据
 */
typedef void(^ReciveUpdateValueForCharacteristicCallBack)(NSError*error,CharacteristicNotifyType aType,NSData*data);
@interface BluetoochManager : NSObject

/**
 获取蓝牙管理器单例

 @return 对象
 */
+(instancetype)sharedInstance;

/**
 搜索设备列表

 @param uuidString 特殊字符串
 @param aCallBack 返回
 */
-(void)startScanningForUUIDString:(NSString *)uuidString callBack:(DevicesCallBack)aCallBack;

/**
 停止搜索
 */
- (void) stopScanning;

/**
 连接某个设备

 @param peripheral 设备信息
 @param aCallBack 返回
 */
- (void) connectPeripheral:(CBPeripheral*)peripheral callBack:(ConnectCallBack)aCallBack;

/**
 断开某个蓝牙连接

 @param peripheral 连接
 */
- (void) disconnectPeripheral:(CBPeripheral*)peripheral;

/**
 断开当前连接
 */
-(void) disconnectCurrentPeripheral;
/**
 发现某个蓝牙设备的服务

 @param peripheral 设备
 @param aCallBack 服务列表
 */
-(void)discoverServicesAtPeripheral:(CBPeripheral*)peripheral callBack:(DiscoverServicesCallBack)aCallBack;

/**
 发现某个蓝牙设备服务的特性类别

 @param peripheral 设备
 @param aService 服务
 @param aCallBack 特性列表
 */
-(void)discoverCharacteristicsAtPeripheral:(CBPeripheral*)peripheral ofService:(CBService*)aService callBack:(DiscoverCharacteristicsForServiceCallBack)aCallBack;

/**
 设置监听某个蓝牙设备服务的特性变化

 @param peripheral 设备
 @param characteristic 特性
 */
-(void)setNotifyValueAtPeripheral:(CBPeripheral*)peripheral forCharacteristic:(CBCharacteristic*)characteristic callBack:(ReciveUpdateValueForCharacteristicCallBack)aCallBack;

/**
 读取设备服务的特性里的数据

 @param peripheral 设备
 @param characteristic 特性
 */
-(void)readValueAtPeripheral:(CBPeripheral*)peripheral forCharacteristic:(CBCharacteristic *)characteristic callBack:(ReciveUpdateValueForCharacteristicCallBack)aCallBack;

/**
 根据设备服务的特性写入数据

 @param data 待数据
 @param peripheral 设备
 @param characteristic 特性
 @param aType CBCharacteristicWriteType 类型
 */
-(void)writeValue:(NSData *)data atPeripheral:(CBPeripheral*)peripheral forCharacteristic:(CBCharacteristic *)characteristic type:(CBCharacteristicWriteType)aType callBack:(ReciveUpdateValueForCharacteristicCallBack)aCallBack;
@end
