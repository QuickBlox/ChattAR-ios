//
//  ProvisionManager.m
//  Chattar
//
//  Created by Ruslan on 11/5/12.
//
//

#import "ProvisionManager.h"

@implementation ProvisionManager

+(BOOL)isDevelopmentProvision{
    
    BOOL isDev = NO;
    
    NSString *profilePath = [[NSBundle mainBundle] pathForResource:@"embedded.mobileprovision" ofType:nil];
    NSString *profileAsString = [NSString stringWithContentsOfFile:profilePath encoding:NSISOLatin1StringEncoding error:NULL];
    NSRange apsenvironmentRange = [profileAsString rangeOfString:@"<key>aps-environment</key>"];
    
    if(apsenvironmentRange.location != NSNotFound){
        NSRange apstypeRange = [profileAsString rangeOfString:@"</" options:NSCaseInsensitiveSearch
                                                        range:NSMakeRange(apsenvironmentRange.location+apsenvironmentRange.length, 100)];
        
        isDev = [profileAsString rangeOfString:@"development" options:NSCaseInsensitiveSearch range:NSMakeRange(apsenvironmentRange.location+apsenvironmentRange.length, apstypeRange.location - (apsenvironmentRange.location+apsenvironmentRange.length))].location != NSNotFound;
        
    }
    
    return  isDev;
}

@end
