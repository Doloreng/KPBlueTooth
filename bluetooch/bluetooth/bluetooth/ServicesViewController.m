//
//  ServicesViewController.m
//  bluetooth
//
//  Created by Eason on 2017/5/8.
//  Copyright © 2017年 eason. All rights reserved.
//

#import "ServicesViewController.h"
#import "CharacteristicsVC.h"

@interface ServicesViewController ()
@property (nonatomic, strong) CBPeripheral*s_per;

@end

@implementation ServicesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"服务列表";
    
    if (self.s_per) {
        [self searchService:self.s_per];
    }
//    [self searchServices];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}
-(void)setDevice:(CBPeripheral*)per{
    _s_per=per;
}
-(void)searchService:(CBPeripheral*)per{
    __weak typeof(self) wSelf=self;
    [[BluetoochManager sharedInstance] discoverServicesAtPeripheral:per callBack:^(NSError *error, NSArray *services) {
        //
        NSLog(@"error %@ \n services %@",error,services);
        [wSelf refreshList:services];
    }];
}
-(void)refreshList:(NSArray*)services{
    self.listArr=[NSMutableArray arrayWithArray:services];
    [self.listVc reloadData];
}
#pragma mark BaseListView
-(void)updateCell:(UITableViewCell *)cell forItem:(id)item{
    CBService *sv=item;
    cell.textLabel.text=[NSString stringWithFormat:@"服务：%@\n",sv];
    cell.textLabel.font=[UIFont systemFontOfSize:12];
    cell.textLabel.numberOfLines=0;
}
-(void)didSelectCell:(UITableViewCell *)cell forItem:(id)item{
    CharacteristicsVC *cvc= (CharacteristicsVC*)[self viewControllerWithStoryName:@"CharacteristicsVCID"];
    cvc.cb_per=self.s_per;
    cvc.cb_serv=item;
    [self.navigationController pushViewController:cvc animated:YES];
}
-(CGFloat)cellHeight{
    return 64;
}

@end
