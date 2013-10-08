//
//  Utilites.h
//  ChattAR
//
//  Created by Igor Alefirenko on 26/09/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utilites : NSObject
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

+(Utilites *)action;
-(NSString *)distanceFormatter:(CLLocationDistance)distance;
-(void)checkAndPutStatusBarColor;

@end
