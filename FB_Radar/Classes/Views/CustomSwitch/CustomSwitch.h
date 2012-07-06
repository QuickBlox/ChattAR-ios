//
//  CustomSwitch.h
//  FB_Radar
//
//  Created by Igor Khomenko on 6/6/12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomSwitch : UISlider{
    BOOL on;
    UIColor *tintColor;
    UIView *clippingView;
    UILabel *rightLabel;
    UILabel *leftLabel;

    // private member
    BOOL m_touchedSelf;
}

@property(nonatomic,getter=isOn) BOOL on;
@property (nonatomic,retain) UIColor *tintColor;
@property (nonatomic,retain) UIView *clippingView;
@property (nonatomic,retain) UILabel *rightLabel;
@property (nonatomic,retain) UILabel *leftLabel;
@property (nonatomic,retain) UILabel *centerLabel;


+ (CustomSwitch *) switchWithLeftText: (NSString *) tag1 andRight: (NSString *) tag2;

- (void)setOn:(BOOL)on animated:(BOOL)animated;
- (void)scaleSwitch:(float)newSize;

- (void)valueDidChange;

@end

