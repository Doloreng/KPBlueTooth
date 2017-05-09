//
//  BaseListViewController.h
//  bluetooth
//
//  Created by Eason on 2017/5/9.
//  Copyright © 2017年 eason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseListViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *listArr;
@property (nonatomic, strong) UITableView *listVc;
/**
 更新cell的展示
 
 @param cell UITableViewCell
 @param item 数据元素
 */
-(void)updateCell:(UITableViewCell*)cell forItem:(id)item;

/**
 选中某个cell
 
 @param cell cell
 @param item 数据元素
 */
-(void)didSelectCell:(UITableViewCell*)cell forItem:(id)item;

/**
 cell的高度
 
 @return 高度值
 */
-(CGFloat)cellHeight;

/**
 根据storyboardid返回 vc

 @param name storyboardid
 @return vc
 */
-(UIViewController*)viewControllerWithStoryName:(NSString*)name;
@end
