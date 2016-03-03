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
#import <MJRefresh.h>
#import "WSRecommendUserCell.h"
#import "WSRecommendUserModel.h"


#define WSSelectedCategory self.categories[self.categoryTableView.indexPathForSelectedRow.row]

@interface WSRecommendViewController ()<UITableViewDelegate,UITableViewDataSource>

//左边的类别表格
@property (weak, nonatomic) IBOutlet UITableView *categoryTableView;

//左边表格的数据
@property (strong, nonatomic) NSArray *categories;

//右边的用户表格
@property (weak, nonatomic) IBOutlet UITableView *userTableView;

//右边的用户数据
@property (strong, nonatomic) NSArray *users;

//最新一次的请求
@property(nonatomic,strong)NSMutableDictionary *lastedParams;

//AFN请求manager
@property(nonatomic,strong)AFHTTPSessionManager *manager;

@end



@implementation WSRecommendViewController

static NSString * const WSCategoryId = @"category";
static NSString  *const WSUserId = @"user";

-(AFHTTPSessionManager *)manager
{
    if (!_manager){
        _manager=[AFHTTPSessionManager manager];
    }
    return _manager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self steupTableView];
    [self steupRefresh];
    [self loadCategories];
    
}

//加载左侧表格数据
-(void)loadCategories
{
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
        
//       选中首行后让用户列表进入下拉刷新状态,这样就触发方法loadNewUsers加载最新的用户数据
        [self.userTableView.mj_header beginRefreshing];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // 显示失败信息
        [SVProgressHUD showErrorWithStatus:@"加载推荐信息失败!"];
    }];

}


//初始化底部和头部的刷新控件
-(void)steupRefresh
{
//    header进入刷新状态就触发方法loadNewUsers
    self.userTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewUsers)];
//    footer进入刷新状态就触发方法loadMoreUsers
    self.userTableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreUsers)];
    
//    刚进入推荐页面的时候隐藏底部刷新
    self.userTableView.mj_footer.hidden = YES;
}

//初始化左右两侧表格
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


#pragma mark - 加载用户数据
//加载最新的用户数据
-(void)loadNewUsers
{
    WSRecommendCategoryModel *catergory = WSSelectedCategory;
    
    // 设置当前页码为1，这样进入推荐关注页面就可以显示第一页数据，而不是空的页面
    catergory.currentPage=1;
    
//    请求参数
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"a"] = @"list";
    params[@"c"] = @"subscribe";
    params[@"category_id"] = @(catergory.id);
    params[@"page"] = @(catergory.currentPage);
    
    //    存储最新的用户请求
    self.lastedParams = params;
    
//    加载右侧用户数据
     [self.manager GET:@"http://api.budejie.com/api/api_open.php" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

         // 服务器返回的字典数组--->模型数组
         NSArray *users = [WSRecommendUserModel mj_objectArrayWithKeyValuesArray:responseObject[@"list"]];
         
         /*
         清除以前存储的数据然后显示最新的数据，
         如果不清除，就会导致每次下拉刷新，就把这一次的数据加在前一次的数据后面，不断叠加，导致重复显示
          */
         [catergory.users removeAllObjects];
         
//         存储最新的用户数据
         [catergory.users addObjectsFromArray:users];
         
//         获取每个分类对应的用户总数
         catergory.total = [responseObject[@"total"] integerValue];
         
         /*
          用户每点击一次左边的表格，就会发送一次请求，如果用户连续点击多次，就有可能导致一次请求的应答还没回来进进行了下一次请求，导致混乱
          这个时候我们要做的就是：只处理最后一次请求，其他请求的应答都不处理
          解决办法如下：
          1、每次生成请求参数params的时候，就使用self.Lastedparams = params;这句代码把最新的请求存储起来
          2、假设连续发送了两次请求（请求1，请求2），这个时候self.Lastedparams存储的就是最新的请求2
          3、当请求1的应答完成，来到此处的block，进行下面代码的判断，此时self.params=请求2，params=请求1（每进行一次请求处理，block就引用一次当前的params（parameters:params这句代码引用），所以发送请求1时的params=请求1，所以发送请求2时的params=请求2）
          4、发现self.Lastedparams != params，就直接return。
          5、如果是请求2 的应答完成，此时self.Lastedparams = params =请求2，就进行下一步处理
          */
         if (self.lastedParams != params) return ;
         
//         刷新右侧表格，显示存储的数据
         [self.userTableView reloadData];
         
//         成功收到应答数据就停止头部刷新
         [self.userTableView.mj_header endRefreshing];
         
//         监测底部刷新控件状态
         [self checkFooterState];
            
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         if (self.lastedParams != params )  return;
         
         [SVProgressHUD showErrorWithStatus:@"加载用户数据失败"];
         
//         没有收到应答数据也停止头部刷新
         [self.userTableView.mj_header endRefreshing];
         
     }];
        
    
}

-(void)loadMoreUsers
{
    WSRecommendCategoryModel *catergory = WSSelectedCategory;
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"a"] = @"list";
    params[@"c"] = @"subscribe";
    params[@"category_id"] = @(catergory.id);
    params[@"page"] = @(++catergory.currentPage);
    
    //    存储最新的用户请求
    self.lastedParams = params;
    
    //    加载右侧用户数据
    [self.manager GET:@"http://api.budejie.com/api/api_open.php" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
       
        //  服务器返回的字典数组--->模型数组
        NSArray *users = [WSRecommendUserModel mj_objectArrayWithKeyValuesArray:responseObject[@"list"]];
        
        // 把后续得到的应答数据都添加到当前类别对应的用户数组中
        [catergory.users addObjectsFromArray:users];
        
        // 用户可能连续点击左边表格，导致一个请求的应答还没有回来，就发送了另外一个请求，这个时候我们只处理最后一次请求。
        if (self.lastedParams != params) return ;
        
        [self.userTableView reloadData];
        
        
        [self checkFooterState];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (self.lastedParams != params )  return;
        
        [SVProgressHUD showErrorWithStatus:@"加载用户数据失败"];
        
        [self.userTableView.mj_header endRefreshing];
        
    }];
    
    
}


-(void)checkFooterState
{
    WSRecommendCategoryModel *c = WSSelectedCategory;
    
    // 右侧表格没有数据的时候隐藏底部刷新，不然每次点击左侧表格发送请求，在请求返回之前，右侧一片空白，还显示一个底部刷新控件很难看，需要隐藏起来
    self.userTableView.mj_footer.hidden = (c.users.count == 0);
    
    // 分类对应的用户数据已经加载完毕，进入“没有数据可以加载”状态
    if (c.users.count == c.total) {
        [self.userTableView.mj_footer endRefreshingWithNoMoreData];
    }else{
        // 分类对应的用户数据还没有加载完毕，就先停止刷新状态，进入提示“刷新可加载更多数据”状态
        [self.userTableView.mj_footer endRefreshing];
    }
}


#pragma mark - <UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _categoryTableView) {
        return self.categories.count;
    }
    else {
        [self checkFooterState];
        return [WSSelectedCategory users].count;
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
        cells.user = [ WSSelectedCategory users][indexPath.row];
        return cells;
    }
    
}


#pragma mark - <UITableViewDelegate>
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView==self.categoryTableView) {
        
//每次点击左边的表格，先停止右边表格的顶部和底部刷新控件
        [self.userTableView.mj_header endRefreshing];
        [self.userTableView.mj_footer endRefreshing];
        
        WSRecommendCategoryModel *category = self.categories[indexPath.row];

//  如果左边的category对应的右边的用户数据已经存在，说明之前已经请求加载过了，那么就不需要重复发送请求再去加载，而是直接从WSRecommendCategoryModel取出users数据加载就可以了
        if (category.users.count) {
            
//  加载已经存储在WSRecommendCategoryModel中的users数据,刷新右边usertableview就会触发dataSource方法，从而重新加载数据
            [self.userTableView reloadData];
            
        }else{
            
            // 赶紧刷新表格,目的是: 马上显示当前category的用户数据, 不让用户看见上一个category的残留数据(网速慢导致看到上一个表格的数据)
            [self.userTableView reloadData];
            
            // 每次点击左边分类表格，右边表格就进入下拉刷新状态，然后就会触发loadNewUsers方法，加载最新（page=1）的用户数据
            [self.userTableView.mj_header beginRefreshing];
        }
        
    }else{
        WSLog(@"####");
    }

}

- (void)dealloc
{
    /*
    有可能用户在请求应答还没有返回，就退出了控制器，那么当请求返回的时候，就可能导致崩溃
    正确的做法是当用户退出控制器，就取消所有的操作。这里的self.manager使用了懒加载，保证全局的manager都是同一个，所以可以使用该manager取消所有操作
     */
    [self.manager.operationQueue cancelAllOperations];
}

@end
