//
//  WSRecommendCategoryModel.m
//  仿写-百思不得姐
//
//  Created by Mia on 16/2/28.
//  Copyright © 2016年 Mia. All rights reserved.
//

#import "WSRecommendCategoryModel.h"

@implementation WSRecommendCategoryModel

//必须实现懒加载，不然每次都会生成新的users，导致前面保存的数据被清空
-(NSMutableArray *)users
{
    if (!_users) {
        _users=[NSMutableArray array];
    }
    return _users;
}

@end
