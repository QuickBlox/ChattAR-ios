//
//  UIImage+ImageExtension.h
//  ChattAR for Facebook
//
//  Created by QuickBlox developers on 3/29/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ImageExtension)

+ (UIImage *)imageFromResource:(NSString *)filename;
+ (UIImage *)rotateImageFromCamera:(UIImage *)image;

@end
