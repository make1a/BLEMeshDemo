//
//  WSTTextFieldCell.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/13.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTTextFieldCell.h"

@implementation WSTTextFieldCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField.text.length > 10){
        textField.text = [textField.text substringWithRange:NSMakeRange(0, 9)];
    }

    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField.text.length > 10){
        textField.text = [textField.text substringWithRange:NSMakeRange(0, 9)];
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField.text.length > 10){
        textField.text = [textField.text substringWithRange:NSMakeRange(0, 9)];
    }
}

@end
