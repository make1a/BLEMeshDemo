//
//  WSTAddAlarmContainerView.h
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/13.
//  Copyright © 2017年 make. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSTAddAlarmContainerView : UIView
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UILabel *onLabel;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttonArray;
@property (weak, nonatomic) IBOutlet UILabel *leftLabel;

/**按钮点击回调 */
@property (nonatomic,copy) void (^pressButton)(void);

/**日期*/
@property (nonatomic,copy) void (^pressWeekButton)(NSInteger index);

- (int)getWeekStr;
- (void)refreshViewWith:(AlarmInfo*)info;
@end
