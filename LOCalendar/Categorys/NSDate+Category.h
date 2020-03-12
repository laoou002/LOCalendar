//
//  NSDate+Category.h
//  LOCalendar
//
//  Created by 欧ye on 2020/3/10.
//  Copyright © 2020 老欧. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Category)

- (NSInteger)year;

- (NSInteger)month;

- (NSInteger)day;

- (NSInteger)hour;

- (NSInteger)minute;

- (NSInteger)second;

- (NSInteger)nanosecond;

- (NSInteger)weekday;

- (BOOL)isToday;

- (BOOL)isLeapYear;

- (BOOL) isEarlierThanDate: (NSDate *) aDate;

- (BOOL) isLaterThanDate: (NSDate *) aDate;

- (NSDate *)dateByAddingYears:(NSInteger)years;

- (NSDate *)dateByAddingMonths:(NSInteger)months;

- (NSDate *)dateByAddingWeeks:(NSInteger)weeks;

- (NSDate *)dateByAddingDays:(NSInteger)days;

- (NSDate *)dateByAddingHours:(NSInteger)hours;

- (NSDate *)dateByAddingMinutes:(NSInteger)minutes;

- (NSDate *)dateByAddingSeconds:(NSInteger)seconds;

- (NSString *)stringWithFormat:(NSString *)format;

+ (NSDate *)dateWithString:(NSString *)dateString format:(NSString *)format;

@end
