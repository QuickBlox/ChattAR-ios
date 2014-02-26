//
//  CaptureSessionService.m
//  ChattAR
//
//  Created by Igor Alefirenko on 24/12/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "CaptureSessionService.h"

@implementation CaptureSessionService

+ (instancetype)shared {
    static id defaultData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultData = [[self alloc] init];
    });
    return defaultData;
}

- (id)init {
    self = [super init];
    if (self) {
        AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] error:nil];

        _captureSession = [[AVCaptureSession alloc] init];
        
        /*We add input and output*/
        [self.captureSession addInput:captureInput];
        
        // show Camera capture preview
        _prewiewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
        [_prewiewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        
        /*We start the capture*/
        [self.captureSession startRunning];
    }
    return self;
}

- (void)enableCaptureSession:(BOOL)isEnabled{
    if(isEnabled){
        if(![self.captureSession isRunning]){
            [self.captureSession startRunning];
        }
    }else{
        if([self.captureSession isRunning]){
            [self.captureSession stopRunning];
        }
    }
}

@end
