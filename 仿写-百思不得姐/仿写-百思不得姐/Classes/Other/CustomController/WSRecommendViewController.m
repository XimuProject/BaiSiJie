//
//  WSRecommendViewController.m
//  仿写-百思不得姐
//
//  Created by Mia on 16/2/28.
//  Copyright © 2016年 Mia. All rights reserved.
//

#import "WSRecommendViewController.h"
#import "WSRecommendViewController.h"
#import "WSRecommendCategoryCell.h"
#import "WSRecommendCategoryModel.h"
#import "AFNetworking.h"
#import <MJExtension.h>
#import <SVProgressHUD.h>
#import "WSRecommendUserCell.h"
#import "WSRecommendUserModel.h"

@interface WSRecommendViewController ()<UITableViewDelegate,UITableViewDataSource>

//左边的类别表格
@property (weak, nonatomic) IBOutlet UITableView *categoryTableView;
//左边表格的数据
@property (strong, nonatomic) NSArray *categories;


//右边的用户表格
@property (weak, nonatomic) IBOutlet UITableView *userTableView;
//右边的用户数据
@property (strong, nonatomic) NSArray *users;

@end



@implementation WSRecommendViewController

static NSString * const WSCategoryId = @"category";
static NSString  *const WSUserId = @"user";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
//    初始化两个tableview
    [self steupTableView];
    
    
    // 显示指示器
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    
    // 发送请求
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"a"] = @"category";
    params[@"c"] = @"subscribe";
    [[AFHTTPSessionManager manager] GET:@"http://api.budejie.com/api/api_open.php" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        // 隐藏指示器
        [SVProgressHUD dismiss];
        
        // 服务器返回的JSON数据
        self.categories = [WSRecommendCategoryModel mj_objectArrayWithKeyValuesArray:responseObject[@"list"]];
        
        // 刷新表格
        [self.categoryTableView reloadData];
        
        // 默认选中首行
        [self.categoryTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // 显示失败信息
        [SVProgressHUD showErrorWithStatus:@"加载推荐信息失败!"];
    }];
}



- (void)steupTableView
{
    // 注册左右两个tableview的cell
    [self.categoryTableView registerNib:[UINib nibWithNibName:NSStringFromClass([WSRecommendCategoryCell class]) bundle:nil] forCellReuseIdentifier:WSCategoryId];
    
    [self.userTableView registerNib:[UINib nibWithNibName:NSStringFromClass([WSRecommendUserCell class]) bundle:nil] forCellReuseIdentifier:WSUserId];
    
//    关闭scrollview的自动设置inset
    self.automaticallyAdjustsScrollViewInsets = NO;
    
//    设置tableviewd的inset，这样才不至于让导航栏挡住了tableviewd的头部
    self.categoryTableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    self.userTableView.contentInset =  self.categoryTableView.contentInset;
    self.userTableView.rowHeight = 70;
    
    
    self.title = @"推荐关注";
    
    // 设置背景色
    self.view.backgroundColor = WSGlobalBackgroundColor;

}

#pragma mark - <UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _categoryTableView) {
        return self.categories.count;
    }
    else {
        WSRecommendCategoryModel *c=self.categories[self.categoryTableView.indexPathForSelectedRow.row];
        return c.users.count;
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.categoryTableView) {
        WSRecommendCategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:WSCategoryId];
        cell.category = self.categories[indexPath.row];
        return cell;
    }else{

        WSRecommendUserCell *cells = [tableView dequeueReusableCellWithIdentifier:WSUserId];
        WSRecommendCategoryModel *c=self.categories[self.categoryTableView.indexPathForSelectedRow.row];
        cells.user=c.users[indexPath.row];
        return cells;
    }
    
}


#pragma mark - <UITableViewDelegate>
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView==self.categoryTableView) {
        
        WSRecommendCategoryModel *category = self.categories[indexPath.row];

//        如果左边的category对应的右边的用户数据已经存在，说明之前已经请求加载过了，那么就不需要重复发送请求再去加载，而是直接从WSRecommendCategoryModel取出users数据加载就可以了
        if (category.users.count) {
//            加载已经存储在WSRecommendCategoryModel中的users数据,刷新右边usertableview就会触发dataSource方法，从而重新加载数据
            [self.userTableView reloadData];
            
        }else{
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        params[@"a"] = @"list";
        params[@"c"] = @"subscribe";
        params[@"category_id"] = @(category.id);
        
        [[AFHTTPSessionManager manager] GET:@"http://api.budejie.com/api/api_open.php" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
            NSArray *users = [WSRecommendUserModel mj_objectArrayWithKeyValuesArray:responseObject[@"list"]];
            
//            把请求的数据存储到WSRecommendCategoryModel的users模型中
            [category.users addObjectsFromArray:users];
            
            // 刷新右边的表格
            [self.userTableView reloadData];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
        }];
        }
        
    }

}

@end
