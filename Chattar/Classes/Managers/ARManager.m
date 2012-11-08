//
//  ARManager.m
//  ChattAR for Facebook
//
//  Created by QuickBlox developers on 3/26/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "ARManager.h"


@implementation ARManager

+(BOOL)deviceSupportsAR{
	
	//Detect camera, if not there, return NO
	if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
		return NO;
	}
	
	//Detect compass, if not there, return NO
	if(![CLLocationManager headingAvailable]){
		return NO;
	}
	
	//cannot detect presence of GPS
	//I could look at location accuracy, but the GPS takes too long to
	//initialize to be effective for a quick check
	//I'll assume if you made it this far, it's there
	
	return YES;
}

@end
