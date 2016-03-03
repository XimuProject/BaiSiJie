//
//  WSRecommandTagsController.m
//  仿写-百思不得姐
//
//  Created by Mia on 16/3/3.
//  Copyright © 2016年 Mia. All rights reserved.
//

#import "WSRecommandTagsController.h"
#import "WSRecommandTagsCell.h"
#import "WSRecommandTagModel.h"
#import <MJExtension.h>
#import <SVProgressHUD.h>
#import <AFNetworking.h>


@interface WSRecommandTagsController ()

//标签的数据
@property(nonatomic, strong) NSArray *tags;
@end

static NSString *const WSTagsId = @"tag";
@implementation WSRecommandTagsController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTableView];
    [self loadTags];

}

- (void)loadTags
{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    
    // 请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"a"] = @"tag_recommend";
    params[@"action"] = @"sub";
    params[@"c"] = @"topic";
    
    // 发送请求
    [[AFHTTPSessionManager manager] GET:@"http://api.budejie.com/api/api_open.php" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        self.tags = [WSRecommandTagModel mj_objectArrayWithKeyValuesArray:responseObject];
        [self.tableView reloadData];
        
        [SVProgressHUD dismiss];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"加载标签数据失败!"];
    }];
}

- (void)setupTableView
{
    self.title = @"推荐标签";
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([WSRecommandTagsCell class]) bundle:nil] forCellReuseIdentifier:WSTagsId];
    self.tableView.rowHeight = 70;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = WSGlobalBackgroundColor;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tags.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WSRecommandTagsCell *cell = [tableView dequeueReusableCellWithIdentifier:WSTagsId];
    
    cell.recommendTag = self.tags[indexPath.row];
    
    return cell;
}


@end
