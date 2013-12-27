//
//  CreateRoomViewController.m
//  ChattAR
//
//  Created by Igor Alefirenko on 28/11/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import "CreateRoomViewController.h"
#import "UIImage+Cropper.h"
#import "AsyncImageView.h"
#import "ChatRoomStorage.h"
#import "ChatRoomViewController.h"
#import "MBProgressHUD.h"
#import "CaptureSessionService.h"


@interface CreateRoomViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, QBActionStatusDelegate>

@property (strong, nonatomic) IBOutlet UITextField *roomNameField;
@property (strong, nonatomic) IBOutlet AsyncImageView *roomImageView;
@property (strong, nonatomic) IBOutlet UIButton *creatingRoomButton;
@property (strong, nonatomic) MBProgressHUD *progressHUD;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;
@property (weak, nonatomic) UIImage *cachedImage;

- (IBAction)chooseImage:(id)sender;
- (IBAction)createRoom:(id)sender;

@end

@implementation CreateRoomViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchToRoom:) name:CAChatRoomDidCreateNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.roomNameField becomeFirstResponder];
}


#pragma mark -
#pragma mark Actions

- (IBAction)back:(id)sender {
    [sender resignFirstResponder];
    [[CaptureSessionService shared] enableCaptureSession:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)chooseImage:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Take Photo",@"Find in Gallery", nil];
    [actionSheet showInView:self.view];
}

- (IBAction)createRoom:(id)sender {
    // deleting spaces in begining and the end string:
    NSString *trimmedString = [self.roomNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([trimmedString isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"You need to add room name for creating"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    if (trimmedString.length > 30) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Too long name"
                                                        message:@"Please, choose another name"
                                                       delegate:nil
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    [self activateHUD];
    [[CaptureSessionService shared] enableCaptureSession:YES];
    self.roomNameField.enabled = NO;
    self.creatingRoomButton.alpha = 0.4;
    self.creatingRoomButton.enabled = NO;
    
    NSData *imageData = UIImageJPEGRepresentation(self.cachedImage, 0.5);
    [[ChatRoomStorage shared] createChatRoomWithName:trimmedString imageData:imageData];
}

-(void)activateHUD {
    UIWindow *currentWindow = [[UIApplication sharedApplication].windows lastObject];
    MBProgressHUD *currentHUD = [MBProgressHUD HUDForView:currentWindow];
    if (currentHUD == nil) {
        [Utilites shared].progressHUD = [MBProgressHUD showHUDAddedTo:currentWindow animated:YES];
        [[Utilites shared].progressHUD setLabelText:@"Uploading avatar..."];
    } else {
        [currentHUD setLabelText:@"Uploading avatar..."];
        [currentHUD performSelector:@selector(show:) withObject:nil];
    }
}

#pragma mark -
#pragma mark Notifications

- (void)switchToRoom:(NSNotification *)notification {
    [[Utilites shared].progressHUD performSelector:@selector(hide:) withObject:nil];
    self.roomNameField.enabled = YES;
    self.creatingRoomButton.enabled = YES;
    self.creatingRoomButton.alpha = 1.0;
    QBCOCustomObject *room = notification.object;
    
    [self performSegueWithIdentifier:kCreateRoomToChatRoomIdentifier sender:room];
}


#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != 2) {
        
        // stop AR video session:
        [[CaptureSessionService shared] enableCaptureSession:NO];
        // Image Picker call:
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [self.roomNameField resignFirstResponder];
            _imagePickerController = [[UIImagePickerController alloc] init];
            _imagePickerController.delegate = self;
            _imagePickerController.allowsEditing = NO;
            
            switch (buttonIndex) {
                case 0:
                    _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                    break;
                case 1:
                    _imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    break;
                    
                default:
                    break;
            }
            
            [self presentViewController:_imagePickerController animated:YES completion:nil];
        }
    }
}


#pragma mark - 
#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // receiving image from delegate:
    UIImage *image = info[@"UIImagePickerControllerOriginalImage"];
    // crop image:
    UIImage *scaledImage =[image imageByScalingProportionallyToMinimumSize:CGSizeMake(200, 200)];
    self.roomImageView.image = scaledImage;
    self.cachedImage = scaledImage;
    [self dismissViewControllerAnimated:YES completion:^{
        _imagePickerController = nil;
        [self.roomNameField becomeFirstResponder];
    }];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:^{
        _imagePickerController = nil;
        [self.roomNameField becomeFirstResponder];
    }];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}


#pragma mark -
#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ((ChatRoomViewController *)segue.destinationViewController).controllerName = @"Create Room View";    //Flurry tracking
    ((ChatRoomViewController *)segue.destinationViewController).currentChatRoom = sender;
}

@end
