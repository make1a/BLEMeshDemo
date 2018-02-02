//
//  WSTTimePickerView.h
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/18.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTBaseAlertView.h"

@interface WSTTimePickerView : WSTBaseAlertView<UIPickerViewDelegate,UIPickerViewDataSource>
@property (nonatomic,strong) UIPickerView *timePikerView;
/**当前选中的数据 */
@property (nonatomic,copy,readonly) id currentTime;
@end
