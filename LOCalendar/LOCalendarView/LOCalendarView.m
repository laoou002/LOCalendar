//
//  LOCalendarView.m
//  LOCalendar
//
//  Created by 欧ye on 2020/3/10.
//  Copyright © 2020 老欧. All rights reserved.
//

#import "LOCalendarView.h"
#import "NSDate+Category.h"

//十六进制转换成颜色
#define GTHEXCOLOR(hexValue) ([UIColor colorWithRed:(((hexValue & 0xFF0000) >> 16))/255.0 green:(((hexValue & 0xFF00) >> 8))/255.0 blue:((hexValue & 0xFF))/255.0 alpha:1.0])
//主颜色
#define ColorMain GTHEXCOLOR(0X29CCCC)
//主颜色-深
#define ColorMainDark GTHEXCOLOR(0XECBEBE)
//主颜色-浅
#define ColorMainLight GTHEXCOLOR(0XBEF0F0)
//主颜色-禁用
#define ColorMainDisabled GTHEXCOLOR(0XE9F9F9)
//字体颜色
#define ColorText GTHEXCOLOR(0X646C6C)
//字体颜色-浅
#define ColorTextLight GTHEXCOLOR(0XAAAAAA)
//字体颜色-深
#define ColorTextDark GTHEXCOLOR(0X202828)
//颜色红
#define ColorRed GTHEXCOLOR(0XFF3E3E)
//颜色红-浅
#define ColorRedLight GTHEXCOLOR(0XFFECEC)

@interface LOCalendarView()

@property (nonatomic, strong) NSString *currentDateText;
//当前月份的天数
@property (nonatomic, assign) NSInteger curDayNum;
//是否隐藏（收起）
@property (nonatomic, assign) BOOL isHide;

//当前周的日期
@property (nonatomic, strong) NSMutableArray *weekArray;
//当前日历控件高度
@property (nonatomic, assign) NSInteger height;
//内容视图
@property (nonatomic, strong) UIView *contentView;
//当前内容视图高度
@property (nonatomic, assign) NSInteger contentViewHeight;
//底部视图
@property (nonatomic, strong) UIView *bottomView;
//当前底部视图的y坐标
@property (nonatomic, assign) NSInteger bottomViewY;

@end

@implementation LOCalendarView

- (instancetype)initWithDakaArray:(NSArray *)dakaArray frame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        _dakaArray = [[NSMutableArray alloc] init];
        for (id date in dakaArray) {
            NSString *obj = date;
            if ([date isKindOfClass:[NSDate class]]){
                obj = [(NSDate *)date stringWithFormat:@"yyyy-MM-dd"];
            }
            [_dakaArray addObject:obj];
        }        
        
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds = YES;
        [self initData];
        [self reloadUI];
    }
    return self;
}

- (void)initData{
    self.today = [NSDate date];
    self.currentDate = [NSDate date];
    self.minDate = [self.currentDate dateByAddingYears:-1];
    self.maxDate = [self.currentDate dateByAddingYears:1];
    self.weekArray = [self getWeekArray];
    [self reData];
}

- (void)reData{
    self.currentDateText = [self.currentDate stringWithFormat:@"yyyy年MM月"];
    self.curDayNum = [self daysInMonth:self.currentDate month:self.currentDate.month];
}

- (void)reloadUI{
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.contentView.clipsToBounds = YES;
    [self addSubview:self.contentView];
    
    UIImage *arrowRightImg = [UIImage imageNamed:@"arrow_right"];
    UIImage *arrowLeftImg = [UIImage imageNamed:@"arrow_left"];
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0,0, 46, 46);
    [leftButton setImage:arrowLeftImg forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(previousMonthAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:leftButton];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(self.frame.size.width-46,0, 46, 46);
    [rightButton setImage:arrowRightImg forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(nextMonthAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:rightButton];
    
    UILabel *currentDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(56, 0, self.frame.size.width-112, 46)];
    currentDateLabel.text = self.currentDateText;
    currentDateLabel.textColor = ColorTextDark;
    currentDateLabel.font = [UIFont boldSystemFontOfSize:14];
    currentDateLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:currentDateLabel];
    
    //星期标题
    CGFloat weekTitleLabel_y = currentDateLabel.frame.origin.y+currentDateLabel.frame.size.height;
    CGFloat weekTitleLabel_width = 30;
    CGFloat weekTitleLabel_height = 30;
    CGFloat weekTitleLabel_padding = (self.frame.size.width - 210 - 30)/6;
    NSArray *weekTexts = @[@"一",@"二",@"三",@"四",@"五",@"六",@"日"];
    for (NSInteger i=0; i<7; i++) {
        UILabel *weekTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15+i*(weekTitleLabel_width+weekTitleLabel_padding), weekTitleLabel_y, weekTitleLabel_width, weekTitleLabel_height)];
        weekTitleLabel.font = [UIFont systemFontOfSize:12];
        weekTitleLabel.textColor = ColorText;
        weekTitleLabel.text = weekTexts[i];
        weekTitleLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:weekTitleLabel];
    }
    weekTitleLabel_y = weekTitleLabel_y + weekTitleLabel_height + 10;
    
    //排列当月日期
    for (NSInteger i=0; i<self.curDayNum; i++) {
        //获取当前日期星期下标
        NSString *dateString = [NSString stringWithFormat:@"%ld-%ld-%ld",self.currentDate.year,self.currentDate.month,i+1];
        NSDate *date = [NSDate dateWithString:dateString format:@"yyyy-MM-dd"];
        NSInteger weekday = date.weekday;
        if (weekday==1){
            weekday = 7;
        }else{
            weekday = weekday - 1;
        }
        NSInteger index = (weekday-1)%7;
        
        //将每一天逐一布局到对应星期位置
        LODayButton *dayBtn = [LODayButton buttonWithType:UIButtonTypeCustom];
        dayBtn.frame = CGRectMake(15+index*(weekTitleLabel_width+weekTitleLabel_padding), weekTitleLabel_y, weekTitleLabel_width, weekTitleLabel_height);
        dayBtn.layer.cornerRadius = weekTitleLabel_width/2;
        dayBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:dayBtn];
        
        UIColor *dayTextColor = ColorTextDark;
        UIColor *dayBgColor = [UIColor clearColor];
        NSString *dayText = [NSString stringWithFormat:@"%ld",i+1];
        
        //日期样式配置
        dayBtn.type = LODayButtonTypeDisabled;
        if ([date isToday]){
            dayText = @"今";
            if ([self isDakaWithDate:date]){
                dayTextColor = [UIColor whiteColor];
                dayBgColor = ColorMain;
                dayBtn.type = LODayButtonTypeYiDaKa;
            }else{
                dayTextColor = ColorRed;
                dayBgColor = [UIColor clearColor];
                dayBtn.type = LODayButtonTypeBuKa;
            }
        }else if ([self isDakaWithDate:date]){
            dayTextColor = [UIColor whiteColor];
            dayBgColor = ColorMain;
            dayBtn.type = LODayButtonTypeYiDaKa;
        }else if ([self isBukaWithDay:date]){
            dayTextColor = ColorMain;
            dayBgColor = ColorMainDisabled;
            dayText = @"补";
            dayBtn.type = LODayButtonTypeBuKa;
        }
        
        [dayBtn setTitleColor:dayTextColor forState:UIControlStateNormal];
        [dayBtn setBackgroundColor:dayBgColor];
        [dayBtn setTitle:dayText forState:UIControlStateNormal];
        
        dayBtn.tag = date.day;
        [dayBtn addTarget:self action:@selector(selectedDateAction:) forControlEvents:UIControlEventTouchUpInside];
        
        if (index==6){
            weekTitleLabel_y = weekTitleLabel_y + weekTitleLabel_height + 10;
        }
    }
    weekTitleLabel_y = weekTitleLabel_y + weekTitleLabel_height + 10;
    self.contentViewHeight = weekTitleLabel_y;
    self.contentView.frame = CGRectMake(0,0, self.frame.size.width, self.contentViewHeight);
    
    //底部说明视图布局
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, weekTitleLabel_y, self.frame.size.width, 20)];
    [self addSubview:self.bottomView];
    self.bottomViewY = weekTitleLabel_y;
    
    UIView *dakaView = [[UIView alloc] initWithFrame:CGRectMake(15, 4, 14, 14)];
    dakaView.backgroundColor = ColorMain;
    dakaView.layer.cornerRadius = 7;
    [self.bottomView addSubview:dakaView];
    
    UILabel *dakaLabel = [[UILabel alloc] initWithFrame:CGRectMake(dakaView.frame.origin.x+dakaView.frame.size.width+8, 0, 64, 20)];
    dakaLabel.textColor = ColorTextDark;
    dakaLabel.font = [UIFont systemFontOfSize:12];
    dakaLabel.text = @"已打卡";
    [self.bottomView addSubview:dakaLabel];
    
    UIView *weidakaView = [[UIView alloc] initWithFrame:CGRectMake(dakaLabel.frame.origin.x+dakaLabel.frame.size.width, 4, 14, 14)];
    weidakaView.backgroundColor = ColorMainDisabled;
    weidakaView.layer.cornerRadius = 7;
    [self.bottomView addSubview:weidakaView];
    
    UILabel *weidakaLabel = [[UILabel alloc] initWithFrame:CGRectMake(weidakaView.frame.origin.x+weidakaView.frame.size.width+8, 0, 64, 20)];
    weidakaLabel.textColor = ColorTextDark;
    weidakaLabel.font = [UIFont systemFontOfSize:12];
    weidakaLabel.text = @"可补卡";
    [self.bottomView addSubview:weidakaLabel];
    
    //折叠日志视图
    UIButton *showBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    showBtn.frame = CGRectMake(self.frame.size.width-95, 0, 84, 20);
    [showBtn addTarget:self action:@selector(showOrHideAction:) forControlEvents:UIControlEventTouchUpInside];
    showBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [showBtn setTitleColor:ColorTextDark forState:UIControlStateNormal];
    [showBtn setTitle:@"收起日历" forState:UIControlStateNormal];
    [showBtn setImage:[UIImage imageNamed:@"arrow_up"] forState:UIControlStateNormal];
    [showBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 16)];
    [showBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 64, 0, 0)];
    
    [self.bottomView addSubview:showBtn];
    
    self.height = self.bottomView.frame.origin.y + self.bottomView.frame.size.height + 15;
    self.frame = CGRectMake(self.frame.origin.x,self.frame.origin.y, self.frame.size.width, self.height);
    
    if (self.reHeightBlock){
        self.reHeightBlock(self.height);
    }
}

#pragma mark - Set
- (void)setCurrentDate:(NSDate *)currentDate{
    _currentDate = currentDate;
    [self reData];
    [self reloadUI];
}

#pragma mark - 添加打卡日期
- (void)addDate:(id)date{
    NSString *obj = date;
    if ([date isKindOfClass:[NSDate class]]){
        obj = [(NSDate *)date stringWithFormat:@"yyyy-MM-dd"];
    }
    [_dakaArray addObject:obj];
    
    [self reloadUI];
}

#pragma mark - 移除打卡日期
- (void)removeDate:(id)date{
    NSString *obj = date;
    if ([date isKindOfClass:[NSDate class]]){
        obj = [(NSDate *)date stringWithFormat:@"yyyy-MM-dd"];
    }
    [_dakaArray removeObject:obj];
    
    [self reloadUI];
}

#pragma mark - Action
//上一个月
- (void)previousMonthAction{
    self.currentDate = [self.currentDate dateByAddingMonths:-1];
    
    if (self.currentDate.year<self.minDate.year || (self.currentDate.year==self.minDate.year&&self.currentDate.month<self.minDate.month)){
        self.currentDate = self.maxDate;
    }
    
    [self reData];
    [self reloadUI];
    
    if (self.changeBlock){
        self.changeBlock(self.currentDate);
    }
}

//下个月
- (void)nextMonthAction{
    self.currentDate = [self.currentDate dateByAddingMonths:1];
    
    if (self.currentDate.year>self.maxDate.year || (self.currentDate.year==self.maxDate.year && self.currentDate.month>self.maxDate.month)){
        self.currentDate = self.minDate;
    }
    
    [self reData];
    [self reloadUI];
    
    if (self.changeBlock){
        self.changeBlock(self.currentDate);
    }
}

//收起或展开
- (void)showOrHideAction:(UIButton *)sender {
    UIImage *arrowDownImg = [UIImage imageNamed:@"arrow_down"];
    UIImage *arrowUpImg = [UIImage imageNamed:@"arrow_up"];
    self.isHide = !self.isHide;
    [sender setTitle:self.isHide?@"展开日历":@"收起日历" forState:UIControlStateNormal];
    [sender setImage:self.isHide?arrowDownImg:arrowUpImg forState:UIControlStateNormal];
    
    CGFloat contentViewHeight = self.isHide?0:self.contentViewHeight;
    CGFloat bottomViewY = self.isHide?15:self.bottomViewY;
    CGFloat height = self.isHide?30+self.bottomView.frame.size.height:self.height;
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
        self.contentView.frame = CGRectMake(0,0, self.frame.size.width, contentViewHeight);
        self.bottomView.frame = CGRectMake(0,bottomViewY, self.frame.size.width, self.bottomView.frame.size.height);
    }];
    if (self.reHeightBlock){
        self.reHeightBlock(height);
    }
}

//判断是否已打卡
- (BOOL)isDakaWithDate:(NSDate *)date{
    BOOL isDaka = NO;
    for (NSString *dateString in self.dakaArray) {
        NSDate *dakaDate = [NSDate dateWithString:dateString format:@"yyyy-MM-dd"];
        if (dakaDate.year==date.year && dakaDate.month==date.month && dakaDate.day==date.day){
            isDaka = YES;
            break;
        }
    }
    return isDaka;
}

//判断是否可补卡
- (BOOL)isBukaWithDay:(NSDate *)date{
    if (self.bukaRange>0){
        NSDate *minBukaDate = [self.today dateByAddingDays:-self.bukaRange-1];
        return ([date isLaterThanDate:minBukaDate] && [date isEarlierThanDate:self.today]);
    }
    
    return ([self.weekArray containsObject:@(date.day)] && date.day<self.today.day && self.currentDate.year==self.today.year && self.currentDate.month==self.today.month);
}

//获取月份的天数
- (NSUInteger)daysInMonth:(NSDate *)date month:(NSUInteger)month
{
    switch (month) {
        case 1: case 3: case 5: case 7: case 8: case 10: case 12:
            return 31;
        case 2:
            return [date isLeapYear] ? 29 : 28;
    }
    return 30;
}

//  获取当前时间一周的日期数组
- (NSMutableArray *)getWeekArray
{
    NSMutableArray *weekArray = [[NSMutableArray alloc] initWithCapacity:7];
    NSDate *firstDayOfWeek = [self getFirstDayOfWeek];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    for (NSInteger i=0; i<7; i++) {
        NSDate *addDayDate = [firstDayOfWeek dateByAddingDays:i];
        [weekArray addObject:@(addDayDate.day)];
    }
    return weekArray;
}

//  根据当前时间计算周一的日期
- (NSDate *)getFirstDayOfWeek
{
    NSDate *currentDate = [NSDate new];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal
                               components:NSCalendarUnitYear| NSCalendarUnitMonth| NSCalendarUnitWeekday | NSCalendarUnitWeekday | NSCalendarUnitWeekdayOrdinal
                               fromDate:currentDate];
    NSDate *firstDay = nil;
    if (comps.weekday == 1) {
        //周天
        firstDay = [currentDate dateByAddingTimeInterval:-6*24*3600];
    } else if (comps.weekday == 2) {
        //周一
        firstDay = [currentDate dateByAddingTimeInterval:6*24*3600];
    } else {
        //不是周一和周天，减去之间的天数
        firstDay = [currentDate dateByAddingTimeInterval:-(comps.weekday-2)*24*3600];
    }
    
    return firstDay;
}

- (void)selectedDateAction:(LODayButton *)sender{
    if (self.selectBlock){
        NSString *dateString = [NSString stringWithFormat:@"%ld-%ld-%ld",self.currentDate.year,self.currentDate.month,sender.tag];
        NSDate *date = [NSDate dateWithString:dateString format:@"yyyy-MM-dd"];
        self.selectBlock(date,sender.type);
    }
}
@end
