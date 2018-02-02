

#import <UIKit/UIKit.h>




@interface WSTAlarmCell : UITableViewCell


@property (nonatomic, strong) UILabel                   *titleLabel;
@property (nonatomic, strong) UILabel                   *infoLabel;
@property (nonatomic, strong) UISwitch                  *actionSwitch;
@property (nonatomic,strong) UILabel *nameLabel;
/**开关 */
@property (nonatomic,copy) void(^pressSwitch)(BOOL isOn);
- (void)cellRefreshWith:(AlarmInfo *)info allDataSourece:(NSArray *)allArray indexPath:(NSIndexPath *)indexPath;
@end
