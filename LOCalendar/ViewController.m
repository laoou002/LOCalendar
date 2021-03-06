//
//  ViewController.m
//  LOCalendar
//
//  Created by 欧ye on 2020/3/10.
//  Copyright © 2020 老欧. All rights reserved.
//

#import "ViewController.h"
#import "LOCalendarView.h"
#import "LOToastView.h"

@interface ViewController ()

@property (nonatomic, strong) LOCalendarView *calendarView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //打卡日期
    NSArray *dakaArray = @[@"2019-12-01",@"2019-12-02",@"2020-01-01"];
    self.calendarView = [[LOCalendarView alloc] initWithDakaArray:dakaArray frame:CGRectMake(15, 80, [UIScreen mainScreen].bounds.size.width-30, 300)];
    [self.view addSubview:self.calendarView];
    
    //圆角及边框样式（根据个人情况调整）
    self.calendarView.layer.cornerRadius = 10;
    self.calendarView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.calendarView.layer.borderWidth = 2;
    
    typeof(self) __weak weakSelf = self;
    //调整高度
    [self.calendarView setReHeightBlock:^(CGFloat height) {
        
    }];
    
    //修改月份
    [self.calendarView setChangeBlock:^(NSDate * _Nonnull date) {
        
    }];
    
    //点击回调
    [self.calendarView setSelectBlock:^(NSDate *date, LODayButtonType type) {
        if (type==LODayButtonTypeDisabled)
        {
            [LOToastView showWithMsg:@"不在打卡范围"];
        }
        else if (type==LODayButtonTypeBuKa)
        {
            //标记为已打卡
            [weakSelf.calendarView addDate:date];
            
            [LOToastView showWithMsg:@"补卡成功"];
        }
        else if (type==LODayButtonTypeYiDaKa)
        {
            [LOToastView showWithMsg:@"已打卡"];
        }
    }];
    //可补卡范围(默认为本周)
    self.calendarView.bukaRange = 30;
    //刷新UI
    [self.calendarView reloadUI];
}


 
@end
