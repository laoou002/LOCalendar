//
//  LODayButton.h
//  LOCalendar
//
//  Created by 欧ye on 2020/3/10.
//  Copyright © 2020 老欧. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LODayButtonType) {
    LODayButtonTypeDefault = 0,
    LODayButtonTypeBuKa,    //可补卡
    LODayButtonTypeYiDaKa,    //已打卡
    LODayButtonTypeDisabled, //无效
};

@interface LODayButton : UIButton

@property (nonatomic) LODayButtonType type;

@end
