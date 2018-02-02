
#import "WSTAlarmCell.h"

@implementation WSTAlarmCell
@synthesize titleLabel, infoLabel, actionSwitch;

#pragma mark - Init
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initCell];
    }
    return self;
}

#pragma mark - View
- (void)initCell {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor colorWithRed:33/255.0 green:47/255.0 blue:58/255.0 alpha:1.0];
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(Sp2Pt(8), 0, SCREEN_WIDTH-Sp2Pt(16), Sp2Pt(70))];
    backView.backgroundColor = [UIColor clearColor];
    [self addSubview:backView];
    // 时间
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, Width(backView)*0.75, Height(backView)*0.7)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:Sp2Pt(30)];
    [backView addSubview:titleLabel];
    
    [titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(backView).mas_offset(0);
        make.top.equalTo(backView).mas_offset(0);
    }];
    
    // 名称，周期
    infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, Height(titleLabel)-8, Width(backView)*0.75, Height(backView)*0.3)];
    infoLabel.textColor = [UIColor colorWithRed:239.0 / 255.0 green:239.0 / 255.0 blue:244.0 / 255.0 alpha:1.0f];
    infoLabel.font = [UIFont systemFontOfSize:Sp2Pt(15)];
    [backView addSubview:infoLabel];
    
    
    
    // 开关
    actionSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(Width(backView)-Sp2Pt(60), (Height(backView)-Sp2Pt(30))/2, Sp2Pt(51), Sp2Pt(30))];
    [actionSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    [actionSwitch setOnTintColor:[UIColor colorWithRed:245.0 / 255.0 green:206.0 / 255.0 blue:111.0 / 255.0 alpha:1.0f]];
    [backView addSubview:actionSwitch];
    
    UIView *lineView = ({
        lineView = [UIView new];
        lineView.backgroundColor = BGColor;
        [self.contentView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(self.contentView);
            make.height.mas_equalTo(2);
        }];
        lineView;
    });
    
    self.nameLabel = [UILabel new];
    self.nameLabel.font = [UIFont systemFontOfSize:px750Width(28)];
    self.nameLabel.textColor = [UIColor whiteColor];
    [backView addSubview:self.nameLabel];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleLabel.mas_right);
        make.centerY.equalTo(titleLabel);
    }];
}

- (void)switchAction:(UISwitch *)swit {
    if (self.pressSwitch) {
        self.pressSwitch(swit.isOn);
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)cellRefreshWith:(AlarmInfo *)info allDataSourece:(NSArray *)allArray indexPath:(NSIndexPath *)indexPath{
    
    NSString *amStr;
    NSInteger hour;
    if (info.hour>12) {
        amStr =  LCSTR("PM");
        hour = info.hour -12;
    }else{
        amStr = LCSTR("AM");
        hour = info.hour;
    }
    NSString *binary = [NSString decimalToBinary:info.actionAndModel];
    NSString *bit03 = [binary substringWithRange:NSMakeRange(5, 3)];
    NSString *on; //开关
    if ([bit03 intValue] == 0) {
        on = LCSTR("off");
    }else{
        on = LCSTR("on");
    }
    
    
    NSString *enableBinary = [NSString decimalToBinary:info.actionAndModel];
    NSString *bit7 = [enableBinary substringWithRange:NSMakeRange(0, 1)]; //使能
    [self.actionSwitch setOn:[bit7 intValue] animated:YES];
    
    if (allArray) {
        self.nameLabel.text = [NSString stringWithFormat:@"(%@)",NSLocalizedString(allArray[indexPath.row], nil)];
    }
        self.titleLabel.text = [NSString stringWithFormat:@"%02ld:%02d %@", (long)hour, info.minute, amStr];
    
    self.infoLabel.text = [NSString stringWithFormat:@"%@,%@", [self decimalToBinaryWeekStringWith:info.dayOrCycle],on];
    
}

- (NSString *)decimalToBinaryWeekStringWith:(NSInteger)repeat {
    NSString *binaryWeekString = [NSString decimalToBinary:repeat];
    NSMutableArray *binaryWeekArray = [[NSMutableArray alloc] init];
    for (int i = 0; i<7; i++) {
        NSString *tempStr = [binaryWeekString substringWithRange:NSMakeRange(7 - i, 1)];
        [binaryWeekArray addObject:tempStr];
    }
    
    NSMutableString *weekString = [NSMutableString new];
    for (int i = 7; i > 0; i--) {
        NSString *string = [binaryWeekString substringWithRange:NSMakeRange(i, 1)];
        if ([string intValue] == 1) {
            NSString *str = [AlarmInfo binaryToWeekStr:i];
            [weekString appendString:@" "];
            [weekString appendString:str];
        }
    }
    return weekString;
}


@end
