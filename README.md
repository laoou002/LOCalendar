# LOCalendar
打卡日历、可做签到等功能的参考

### 图例：

<img src="https://github.com/laoou002/LOCalendar/blob/master/boke001.png"  height="667" width="320">

### 使用方法：
```objc
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
```
