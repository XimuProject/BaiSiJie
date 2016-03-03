//
//  WSRecommandTagsCell.m
//  仿写-百思不得姐
//
//  Created by Mia on 16/3/3.
//  Copyright © 2016年 Mia. All rights reserved.
//

#import "WSRecommandTagsCell.h"
#import "WSRecommandTagModel.h"
#import <UIImageView+WebCache.h>

@interface WSRecommandTagsCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageListImageView;
@property (weak, nonatomic) IBOutlet UILabel *themeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *subNumberLabel;

@end

@implementation WSRecommandTagsCell


-(void)setRecommendTag:(WSRecommandTagModel *)recommendTag
{
    _recommendTag = recommendTag;
    
    [self.imageListImageView sd_setImageWithURL:[NSURL URLWithString:recommendTag.image_list] placeholderImage:[UIImage imageNamed:@"defaultUserIcon"]];
    
    self.themeNameLabel.text=recommendTag.theme_name;
    
    NSString *subNumber = nil;
    if (recommendTag.sub_number < 10000) {
        subNumber = [NSString stringWithFormat:@"%zd人订阅", recommendTag.sub_number];
    }else{
//        .1f表示保留一位小数
        subNumber = [NSString stringWithFormat:@"%.1f万人订阅", recommendTag.sub_number / 10000.0];
    }
    self.subNumberLabel.text = subNumber;
    
}

//cell的frame最终的frame 是由该方法确定的，可以在这里修改cell的frame，下面的修改效果是让cell之间有间隙
-(void)setFrame:(CGRect)frame
{
    frame.origin.x = 5;
    frame.size.width -= 2 * frame.origin.x;
    frame.size.height -= 1;
    
//    调用父类的setFrame方法设置上面设定的值
    [super setFrame:frame];
}


@end
