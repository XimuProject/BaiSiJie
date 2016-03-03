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
    [self setupTableview];
    [self laodTags];

}

-(void)setupTableview
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
