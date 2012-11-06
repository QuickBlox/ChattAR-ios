//
//  ViewTouch.h
//  FB_Radar
//
//  Created by Sonny Black on 11.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewTouch : UIView 
{
    id target;
	SEL selector;
}

-(id) initWithFrame:(CGRect)frame selector:(SEL)sel target:(id)tar;

@end

