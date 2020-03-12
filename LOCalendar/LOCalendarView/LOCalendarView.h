//
//  LOCalendarView.h
//  LOCalendar
//
//  Created by 欧ye on 2020/3/10.
//  Copyright © 2020 老欧. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LODayButton.h"

@interface LOCalendarView : UIView

//补卡范围，为0默认本星期内可补卡，大于零为N天前可补卡
@property (nonatomic, assign) NSInteger bukaRange;

//最小日期，默认往前一年
@property (nonatomic, strong) NSDate *minDate;

//最大日期，默认往后一年
@property (nonatomic, strong) NSDate *maxDate;

//当前显示的日期
@property (nonatomic, strong) NSDate *currentDate;

//今日，用于更新服务器返回的今天日期，以防本地时间不准确
@property (nonatomic, strong) NSDate *today;

//当前月份打卡数据数组
@property (nonatomic, strong, readonly) NSMutableArray *dakaArray;

//刷新高度回调
@property (nonatomic) void (^reHeightBlock)(CGFloat height);

//修改日期回调
@property (nonatomic) void (^changeBlock)(NSDate *date);

//选择日期回调
@property (nonatomic) void (^selectBlock)(NSDate *date,LODayButtonType type);

- (void)reloadUI;

/**
初始化

@param dakaArray 已打卡日期数组, 如@[@"2019-12-01",@"2019-12-02",@"2020-01-01"]
*/
- (instancetype)initWithDakaArray:(NSArray *)dakaArray frame:(CGRect)frame;

/**
添加打卡日期

@param date 打卡日期，可为NSDate或NSString类型
*/
- (void)addDate:(id)date;

/**
移除打卡日期

@param date 打卡日期，可为NSDate或NSString类型
*/
- (void)removeDate:(id)date;

@end
