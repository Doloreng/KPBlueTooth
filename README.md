## iOS蓝牙通讯模块文档说明
code中有三个文件夹：lib和bluetooth,lib是封装的蓝牙通信，bluetooth是demo。

-------
**lib**
_BluetoochManager_ 是一个单例类，具体实现搜索蓝牙设备、连接设备、搜索设备的相关服务、搜索服务的相关特性和针对特性订阅、读取、写入的操作。


**bluetooth**
使用lib中的库的demo

_BaseListViewController_ 列表展示相关信息的基础类
_DeviceListVC_ 搜索、展示设备列表
_ServicesViewController_ 搜索、展示服务列表
_CharacteristicsVC_ 搜索、展示特性列表的类

-----
该工具是以CBCentralMannager 中心模式 :以手机（app）作为中心，连接其他外设的场景(主要写此种该模式的应用方法)
主要要使用的是CBPeripheral、CBService、CBCharacteristic，使用蓝牙设备连接的主要步奏
**第一步引用头文件、代理和管理器**    

```
#import <CoreBluetooth/CoreBluetooth.h>
@interface BluetoochManager()<CBCentralManagerDelegate,CBPeripheralDelegate>{
	CBCentralManager *CBManager;
}

```    
**初始化蓝牙设备代理**    

```
CBManager=[[CBCentralManager alloc]initWithDelegate:self queue:nil];

//代理回调
#pragma mark CBCentralManagerDelegate
//设备列表相关
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSString * state = nil;
    
    switch ([central state])
    {
        case CBManagerStateUnsupported:
        {
            state = @"硬件不支持低电量蓝牙";
        }
            break;
        case CBManagerStateUnauthorized:
        {
            state = @"这个应用程序未被授权使用蓝牙";
            
        }
            break;
        case CBManagerStatePoweredOff:
        {
            state = @"蓝牙处于未开启，请开启蓝牙";
            
        }
            break;
        case CBManagerStatePoweredOn:
        {
            state = @"work";
            NSLog(@"蓝牙启动");
            //切记蓝牙启动后才可以调用相关搜索设备的功能
        }
            break;
        default :
        {
            state = @"未知名错误";
        }
            break;
    }
}
```    
**搜索蓝牙设备**


```
/**
 查找蓝牙设备
 */
-(void)scanForPeripherals{
    NSDictionary *options	= [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    [[self manager] scanForPeripheralsWithServices:self.scanUUIDS options:options];
}
//代理回调
#pragma mark CBCentralManagerDelegate
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI{
    NSString *str = [NSString stringWithFormat:@"Did discover peripheral. peripheral: %@ rssi: %@, UUID: %@ advertisementData: %@ ", peripheral.name, RSSI, peripheral.identifier.UUIDString, advertisementData];
    NSLog(@"外设:\n %@",str);
    
}
```    
**连接设备**


```
// 连接某个设备
- (void)connectPeripheral:(CBPeripheral*)peripheral{
    
    if ([peripheral state]==CBPeripheralStateDisconnected) {
        [CBManager connectPeripheral:peripheral options:nil];
    }else{
        NSString *state = @"设备正在使用中";
    }
}
//代理回调
#pragma mark CBCentralManagerDelegate 连接外设
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error{
    NSLog(@"连接外设 error:\n %@",error);
}
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Did connect to peripheral: %@", peripheral);
    [self stopScanning];
}
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error{
    NSLog(@"Did disconnect to peripheral: %@", peripheral);
}

```    
**查找设备服务**     

```    
/**
 发现某个蓝牙设备的服务
 
 @param peripheral 设备信息
 */
-(void)discoverServicesAtPeripheral:(CBPeripheral*)peripheral{
    peripheral.delegate = self;
    NSArray		*uuids	= [NSArray new];
    [peripheral discoverServices:uuids];
}
//代理回调
#pragma mark CBPeripheralDelegate 设备服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error{
    NSArray		*services	= nil;
    if (error) {
        NSLog(@"设备的服务查找 Error %@\n", error);
    }
    services = [peripheral services];
    if (!services || ![services count]) {
        NSString *s_message=@"该设备没有服务";
    }
}
```    

**查找服务的特性**    

```
/**
 发现某个蓝牙设备服务的特性类别
 
 @param peripheral 设备
 @param aService 服务
 @param aCallBack 特性列表
 */
-(void)discoverCharacteristicsAtPeripheral:(CBPeripheral*)peripheral ofService:(CBService*)aService{
 
    [peripheral discoverCharacteristics:[NSArray new] forService:aService];
    
}
//代理回调
#pragma mark CBPeripheralDelegate 服务的特性
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error{
    NSArray *characteristics = [service characteristics];
    if (error) {
        NSLog(@"设备的服务的特性查找 Error %@\n", error);
    }
    if (!characteristics||!characteristics.count) {
        NSString *c_message=@"该设备没有服务相关的特性";
    }
}
```    
**读取、订阅、写入信息**    

```    
/**
 订阅某个蓝牙设备服务的特性变化
 
 @param peripheral 设备
 @param characteristic 特性
 */
-(void)setNotifyValueAtPeripheral:(CBPeripheral*)peripheral forCharacteristic:(CBCharacteristic*)characteristic{
    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
}

/**
 读取设备服务的特性里的数据
 
 @param peripheral 设备
 @param characteristic 特性
 */
-(void)readValueAtPeripheral:(CBPeripheral*)peripheral forCharacteristic:(CBCharacteristic *)characteristic{
    [peripheral readValueForCharacteristic:characteristic];
}

/**
 根据设备服务的特性写入数据
 
 @param data 待数据
 @param peripheral 设备
 @param characteristic 特性
 @param aType CBCharacteristicWriteType 类型
 */
-(void)writeValue:(NSData *)data atPeripheral:(CBPeripheral*)peripheral forCharacteristic:(CBCharacteristic *)characteristic type:(CBCharacteristicWriteType)aType {
    [peripheral writeValue:data forCharacteristic:characteristic type:aType];
}

//代理回调
#pragma mark CBPeripheralDelegate 读写回调
//数据更新
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        NSLog(@"数据更新失败了 %@",error);
    }
    NSLog(@"收到的数据：%@",characteristic);
}
//订阅特性的状态通知
-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        NSLog(@"订阅特性状态更新出错了 %@",error);
        
    }
    NSLog(@"状态的数据：%@",characteristic);
}
//写入数据的状态消息
-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        NSLog(@"特性写入出错了 %@",error);
    }
    NSLog(@"写入的数据：%@",characteristic);
}

```

