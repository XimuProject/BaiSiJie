//
//  WSRecommendCategoryModel.h
//  仿写-百思不得姐
//
//  Created by Mia on 16/2/28.
//  Copyright © 2016年 Mia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSRecommendCategoryModel : NSObject
/** id */
@property (nonatomic, assign) NSInteger id;
/** 总数 */
@property (nonatomic, assign) NSInteger count;
/** 名字 */
@property (nonatomic, copy) NSString *name;


//类别对应的用户数据的总数（服务器返回的数据里面）
@property (nonatomic ,assign)NSInteger total;

//当前页码
@property (nonatomic ,assign)NSInteger currentPage;

//存储这个类别对应的用户总数
@property(nonatomic,strong)NSMutableArray *users;

@end


