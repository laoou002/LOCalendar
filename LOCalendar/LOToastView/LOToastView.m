//
//  LOToastView.m
//  LOCalendar
//
//  Created by 欧ye on 2020/3/10.
//  Copyright © 2020 老欧. All rights reserved.
//

#import "LOToastView.h"

@interface LOToastView()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *msgLabel;

@end

@implementation LOToastView

+ (void)showWithMsg:(NSString *)msg{
    //切回主线程
    dispatch_async(dispatch_get_main_queue(), ^{
        LOToastView *toastView = [[LOToastView alloc] init];
        [toastView setupUI];
        [toastView showWithMsg:msg];
    });
}

- (void)setupUI{
    self.backgroundColor = [UIColor blackColor];
    self.layer.cornerRadius = 6;
    self.userInteractionEnabled = NO;
    
    self.msgLabel = [[UILabel alloc] init];
    self.msgLabel.font = [UIFont systemFontOfSize:13];
    self.msgLabel.textColor = [UIColor whiteColor];
    self.msgLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.msgLabel];
}

- (void)showWithMsg:(NSString *)msg{
    self.alpha = 0;
    self.msgLabel.text = msg;
    
    //根据text的font和字符串自动算出size
    CGSize size = [self.msgLabel.text sizeWithAttributes:@{NSFontAttributeName:self.msgLabel.font}];
    self.msgLabel.center = self.center;
    
    CGFloat maxWidth = [UIScreen mainScreen].bounds.size.width-120;
    CGFloat labelWidth = size.width>maxWidth?maxWidth:size.width;
    self.frame = CGRectMake(
                            ([UIScreen mainScreen].bounds.size.width-labelWidth-60)/2,
                            -100,
                            labelWidth+60, 36);
    self.msgLabel.frame = CGRectMake(30, 0, labelWidth, self.frame.size.height);
    
    UIView *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
    [window bringSubviewToFront:self];
    
    [UIView animateWithDuration:0.8 animations:^{
        self.frame = CGRectMake(self.frame.origin.x,44,self.frame.size.width, self.frame.size.height);
        
        self.alpha = 1;
    }];
    
    //两秒后自动消失
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hide];
    });
}

- (void)hide{
    [UIView animateWithDuration:0.8 animations:^{
        self.frame = CGRectMake(self.frame.origin.x,-100,self.frame.size.width, self.frame.size.height);
        
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
