//
//  BluetoochManager.m
//  bluetooth
//
//  Created by Eason on 2017/4/12.
//  Copyright © 2017年 eason. All rights reserved.
//

#import "BluetoochManager.h"
@interface BluetoochManager()<CBCentralManagerDelegate,CBPeripheralDelegate>{
    DevicesCallBack _deviceCallback;                        //设备列表回调
    ConnectCallBack _connectCallback;                       //连接设备回调
    DiscoverServicesCallBack _discoverServiecesCallback;    //设备服务列表回调
    DiscoverCharacteristicsForServiceCallBack _discoverCharacteristicsForServiceCallback; //设备服务的特性列表回调
    ReciveUpdateValueForCharacteristicCallBack _reciveUpdateValueForCharacteristicCallback;
}
@property (nonatomic, strong)CBCentralManager *CBManager;
@property (nonatomic, strong) NSMutableArray *muDevices;
@property (nonatomic, strong) NSMutableData *deviceReciveData;
@property (nonatomic, assign) float progress;
@property (nonatomic, readonly) NSArray *scanUUIDS;
@property (nonatomic, retain) CBPeripheral *currentPer;

@end

static id _instance;
@implementation BluetoochManager



-(float)progress{
    if (_progress==0) {
        return 1;
    }
    return _progress;
}


/**
 停止搜索
 */
- (void) stopScanning{
    _deviceCallback=nil;
    [_muDevices removeAllObjects];
    [[self manager] stopScan];
}
/**
 搜索设备列表
 
 @param uuidString 特殊字符串
 @param aCallBack 返回
 */
-(void)startScanningForUUIDString:(NSString *)uuidString callBack:(DevicesCallBack)aCallBack{
    if ([[self manager] isScanning]) {
        [self stopScanning];
        
    }
    NSArray *uuidArray;
    if (uuidString) {
        uuidArray= [NSArray arrayWithObjects:[CBUUID UUIDWithString:uuidString], nil];
    }
    _scanUUIDS=uuidArray;
    _deviceCallback=aCallBack;
//    先初始化蓝牙设备
    self.muDevices=[NSMutableArray new];
    
    
    if ([self manager].state ==CBManagerStatePoweredOn) {
        NSDictionary *options	= [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
       [[self manager] scanForPeripheralsWithServices:uuidArray options:options];
    }
//    [[self manager] scanForPeripheralsWithServices:uuidArray options:options];
    
}

/**
 查找蓝牙设备
 */
-(void)scanForPeripherals{
    NSDictionary *options	= [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    [[self manager] scanForPeripheralsWithServices:self.scanUUIDS options:options];
}
/**
 连接某个设备
 
 @param peripheral 设备信息
 @param aCallBack 返回
 */
- (void)connectPeripheral:(CBPeripheral*)peripheral callBack:(ConnectCallBack)aCallBack{
    
    _connectCallback=aCallBack;
    _currentPer=peripheral;
    if ([peripheral state]==CBPeripheralStateDisconnected) {
        //        servicePeripheral=peripheral;
        [_CBManager connectPeripheral:peripheral options:nil];
    }else{
        NSString *state = @"设备正在使用中";
        NSError *error=[[NSError alloc]initWithDomain:state code:DEVICE_OFFLINESTATE userInfo:nil];
        _connectCallback(error,DEVICE_OFFLINESTATE);
    }
}

/**
 断开某个蓝牙连接
 
 @param peripheral 连接
 */
- (void) disconnectPeripheral:(CBPeripheral*)peripheral
{
    if(peripheral){
        [_CBManager cancelPeripheralConnection:peripheral];
    }
    
}
-(void)disconnectCurrentPeripheral{
    if (_currentPer) {
        [self disconnectPeripheral:_currentPer];
    }
    
}
/**
 发现某个蓝牙设备的服务
 
 @param peripheral 设备信息
 */
-(void)discoverServicesAtPeripheral:(CBPeripheral*)peripheral callBack:(DiscoverServicesCallBack)aCallBack{
    _discoverServiecesCallback=aCallBack;
    peripheral.delegate = self;
    NSArray		*uuids	= [NSArray new];
    [peripheral discoverServices:uuids];
}
/**
 发现某个蓝牙设备服务的特性类别
 
 @param peripheral 设备
 @param aService 服务
 @param aCallBack 特性列表
 */
-(void)discoverCharacteristicsAtPeripheral:(CBPeripheral*)peripheral ofService:(CBService*)aService callBack:(DiscoverCharacteristicsForServiceCallBack)aCallBack{
    _discoverCharacteristicsForServiceCallback=aCallBack;
    if (![peripheral.delegate isEqual:self]) {
        peripheral.delegate=self;
    }
    [peripheral discoverCharacteristics:[NSArray new] forService:aService];
    
}
/**
 设置监听某个蓝牙设备服务的特性变化
 
 @param peripheral 设备
 @param characteristic 特性
 */
-(void)setNotifyValueAtPeripheral:(CBPeripheral*)peripheral forCharacteristic:(CBCharacteristic*)characteristic callBack:(ReciveUpdateValueForCharacteristicCallBack)aCallBack{
    _reciveUpdateValueForCharacteristicCallback=aCallBack;
    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
}

/**
 读取设备服务的特性里的数据
 
 @param peripheral 设备
 @param characteristic 特性
 */
-(void)readValueAtPeripheral:(CBPeripheral*)peripheral forCharacteristic:(CBCharacteristic *)characteristic callBack:(ReciveUpdateValueForCharacteristicCallBack)aCallBack{
    _reciveUpdateValueForCharacteristicCallback=aCallBack;
    [peripheral readValueForCharacteristic:characteristic];
}

/**
 根据设备服务的特性写入数据
 
 @param data 待数据
 @param peripheral 设备
 @param characteristic 特性
 @param aType CBCharacteristicWriteType 类型
 */
-(void)writeValue:(NSData *)data atPeripheral:(CBPeripheral*)peripheral forCharacteristic:(CBCharacteristic *)characteristic type:(CBCharacteristicWriteType)aType callBack:(ReciveUpdateValueForCharacteristicCallBack)aCallBack{
    _reciveUpdateValueForCharacteristicCallback=aCallBack;
    [peripheral writeValue:data forCharacteristic:characteristic type:aType];
}
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
            NSError *error=[[NSError alloc]initWithDomain:state code:CBManagerStateUnsupported userInfo:nil];
            if (_deviceCallback) {
                _deviceCallback(error,_muDevices);
            }
        }
            break;
        case CBManagerStateUnauthorized:
        {
            state = @"这个应用程序未被授权使用蓝牙";
            NSError *error=[[NSError alloc]initWithDomain:state code:CBManagerStateUnauthorized userInfo:nil];
            if (_deviceCallback) {
                _deviceCallback(error,_muDevices);
            }
        }
            break;
        case CBManagerStatePoweredOff:
        {
            state = @"蓝牙处于未开启，请开启蓝牙";
            NSError *error=[[NSError alloc]initWithDomain:state code:CBManagerStatePoweredOff userInfo:nil];
            if (_deviceCallback) {
                _deviceCallback(error,_muDevices);
            }
        }
            break;
        case CBManagerStatePoweredOn:
        {
            state = @"work";
            NSLog(@"蓝牙启动");
            [self scanForPeripherals];
        }
            break;
        default :
        {
            state = @"未知名错误";
            NSError *error=[[NSError alloc]initWithDomain:state code:CBManagerStateUnknown userInfo:nil];
            if (_deviceCallback) {
                _deviceCallback(error,_muDevices);
            }
        }
            break;
    }
    
    //    NSLog(@"Central manager state: %@", state);
}
//查到外设
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI{
    NSString *str = [NSString stringWithFormat:@"Did discover peripheral. peripheral: %@ rssi: %@, UUID: %@ advertisementData: %@ ", peripheral.name, RSSI, peripheral.identifier.UUIDString, advertisementData];
    NSLog(@"外设:\n %@",str);
    if (![_muDevices containsObject:peripheral]) {
        [_muDevices addObject:peripheral];
        //        NSString *state=[NSString stringWithFormat:@"扫描到新的设备"];
        NSArray *cbArr=[_muDevices copy];
        if (_deviceCallback) {
            _deviceCallback(nil,cbArr);
        }
    }
}
#pragma mark CBCentralManagerDelegate 连接外设
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error{
    NSLog(@"连接外设 error:\n %@",error);
    if (_connectCallback) {
        _connectCallback(error,DEVICE_FAILECONNECTSTATE);
    }
}
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Did connect to peripheral: %@", peripheral);
    //    self.servicePeripheral=peripheral;
    [self stopScanning];
    if (_connectCallback) {
        _connectCallback(nil,DEVICE_SUCCESSCONNECTSTATE);
    }
}
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error{
    NSLog(@"Did disconnect to peripheral: %@", peripheral);
    if (_connectCallback) {
        _connectCallback(nil,DEVICE_DISCONNECTSTATE);
    }
    
    
}
#pragma mark CBPeripheralDelegate 设备服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error{
    NSArray		*services	= nil;
    if (error) {
        NSLog(@"设备的服务查找 Error %@\n", error);
        if (_discoverServiecesCallback) {
            _discoverServiecesCallback(error,services);
        }
        return;
    }
    services = [peripheral services];
    if (!services || ![services count]) {
        NSString *s_message=@"该设备没有服务";
        NSError *s_error=[NSError errorWithDomain:s_message code:0 userInfo:nil];
        if (_discoverServiecesCallback) {
            _discoverServiecesCallback(s_error,services);
        }
        return;
    }
    if (_discoverServiecesCallback) {
        _discoverServiecesCallback(nil,services);
    }
}
#pragma mark CBPeripheralDelegate 服务的特性
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error{
    NSArray *characteristics = [service characteristics];
    if (error) {
        NSLog(@"设备的服务的特性查找 Error %@\n", error);
        if (_discoverCharacteristicsForServiceCallback) {
            _discoverCharacteristicsForServiceCallback(error,characteristics);
        }
        return;
    }
    if (!characteristics||!characteristics.count) {
        NSString *c_message=@"该设备没有服务相关的特性";
        NSError *c_error=[NSError errorWithDomain:c_message code:0 userInfo:nil];
        if (_discoverCharacteristicsForServiceCallback) {
            _discoverCharacteristicsForServiceCallback(c_error,characteristics);
        }
        return;
    }
    if (_discoverCharacteristicsForServiceCallback) {
        _discoverCharacteristicsForServiceCallback(nil,characteristics);
    }
}
#pragma mark CBPeripheralDelegate 读写回调
//数据更新
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        NSLog(@"数据更新失败了 %@",error);
        if (_reciveUpdateValueForCharacteristicCallback) {
            _reciveUpdateValueForCharacteristicCallback(error,CHARACTERISTIC_UPDATEVALUESTATE,nil);
        }
        return;
    }
    NSLog(@"收到的数据：%@",characteristic);
    _reciveUpdateValueForCharacteristicCallback(nil,CHARACTERISTIC_UPDATEVALUESTATE,characteristic.value);
}
//订阅通知
-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        NSLog(@"订阅特性状态更新出错了 %@",error);
        if (_reciveUpdateValueForCharacteristicCallback) {
            _reciveUpdateValueForCharacteristicCallback(error,CHARACTERISTIC_NOTIFYSTATE,nil);
        }
        return;
    }else{
        if (_reciveUpdateValueForCharacteristicCallback) {
            _reciveUpdateValueForCharacteristicCallback(nil,CHARACTERISTIC_NOTIFYSTATE,characteristic.value);
        }
    }
    NSLog(@"状态的数据：%@",characteristic);
}
//写入数据
-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        NSLog(@"特性写入出错了 %@",error);
        if (_reciveUpdateValueForCharacteristicCallback) {
            _reciveUpdateValueForCharacteristicCallback(error,CHARACTERISTIC_WRITESTATE,nil);
        }
        return;
    }else{
        if (_reciveUpdateValueForCharacteristicCallback) {
            _reciveUpdateValueForCharacteristicCallback(nil,CHARACTERISTIC_WRITESTATE,characteristic.value);
        }
    }
    NSLog(@"写入的数据：%@",characteristic);
}
//拼接返回字典
+(NSDictionary*)splitReslutDictWithState:(NSInteger)state message:(NSString*)message advertisementData:(NSDictionary*)advertisementData error:(NSError*)error{
    NSString *statestr=[NSString stringWithFormat:@"%li",(long)state];
    if (advertisementData) {
        return [[NSDictionary alloc]initWithObjectsAndKeys:statestr,@"state",message,@"message",advertisementData,@"advertisementData",error,@"error", nil];
    }
    return [[NSDictionary alloc]initWithObjectsAndKeys:statestr,@"state",message,@"message",error,@"error",advertisementData,@"advertisementData", nil];
}
#pragma mark 蓝牙
-(CBCentralManager*)manager{
    if (!_CBManager) {
         _CBManager=[[CBCentralManager alloc]initWithDelegate:self queue:nil];
    }
    return _CBManager;
}




#pragma mark 单例
+(instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance=[[self alloc]init];
    });
    return _instance;
}
-(instancetype)init{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ((self ==[super init])) {
            
        }
    });
    return self;
}
+(instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance=[super allocWithZone:zone];
    });
    return _instance;
}
+(id)copyWithZone:(struct _NSZone *)zone{
    return _instance;
}

+(id)mutableCopyWithZone:(struct _NSZone *)zone{
    return _instance;
}

- (id)copy{
    return _instance;
}

-(id)mutableCopy{
    return _instance;
}
@end
