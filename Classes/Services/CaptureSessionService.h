//
//  CaptureSessionService.h
//  ChattAR
//
//  Created by Igor Alefirenko on 24/12/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface CaptureSessionService : NSObject

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *prewiewLayer;

+ (instancetype)shared;

- (void)enableCaptureSession:(BOOL)isEnabled;

@end
