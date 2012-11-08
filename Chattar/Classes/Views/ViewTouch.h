//
//  ViewTouch.h
//  ChattAR for Facebook
//
//  Created by QuickBlox developers on 11.05.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewTouch : UIView 
{
    id target;
	SEL selector;
}

-(id) initWithFrame:(CGRect)frame selector:(SEL)sel target:(id)tar;

@end

