//
//  BaseListViewController.m
//  bluetooth
//
//  Created by Eason on 2017/5/9.
//  Copyright © 2017年 eason. All rights reserved.
//

#import "BaseListViewController.h"

@interface BaseListViewController ()

@end

@implementation BaseListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _listVc=[[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
    _listVc.delegate=self;
    _listVc.dataSource=self;
    [self.view addSubview:_listVc];
    self.listArr=[NSMutableArray new];
    // Do any additional setup after loading the view.
}
-(UIViewController*)viewControllerWithStoryName:(NSString*)name{
    UIStoryboard *main=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc=[main instantiateViewControllerWithIdentifier:name];
    return vc;
}
/**
 更新cell的展示

 @param cell UITableViewCell
 @param item 数据元素
 */
-(void)updateCell:(UITableViewCell*)cell forItem:(id)item{
    
}

/**
 选中某个cell

 @param cell cell
 @param item 数据元素
 */
-(void)didSelectCell:(UITableViewCell*)cell forItem:(id)item{
    
}

/**
 cell的高度

 @return 高度值
 */
-(CGFloat)cellHeight{
    return  56;
}
#pragma mark tableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _listArr.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"CellIdentifier";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [self updateCell:cell forItem:self.listArr[indexPath.row]];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    id item=self.listArr[indexPath.row];
    UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    [self didSelectCell:cell forItem:item];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self cellHeight];
}

@end
