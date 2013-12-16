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


@interface CreateRoomViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, QBActionStatusDelegate>

@property (strong, nonatomic) IBOutlet UITextField *roomNameField;
@property (strong, nonatomic) IBOutlet AsyncImageView *roomImageView;
@property (strong, nonatomic) IBOutlet UIButton *creatingRoomButton;
@property (strong, nonatomic) MBProgressHUD *progressHUD;

@property (weak, nonatomic) UIImage *cachedImage;

- (IBAction)chooseImage:(id)sender;
- (IBAction)createRoom:(id)sender;

@end

@implementation CreateRoomViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.creatingRoomButton.layer.cornerRadius = 5.0f;
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
    self.progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].windows lastObject] animated:YES];
    self.roomNameField.enabled = NO;
    self.creatingRoomButton.alpha = 0.4;
    self.creatingRoomButton.enabled = NO;
    
    NSData *imageData = UIImageJPEGRepresentation(self.cachedImage, 0.5);
    [[ChatRoomStorage shared] createChatRoomWithName:trimmedString imageData:imageData];
}

- (void)switchToRoom:(NSNotification *)notification {
    [self.progressHUD hide:YES];
    self.roomNameField.enabled = YES;
    self.creatingRoomButton.enabled = YES;
    self.creatingRoomButton.alpha = 1.0;
    QBCOCustomObject *room = notification.object;
    
    //[Flurry logEvent:kFlurryEventNewRoomWasCreated withParameters:params];
    
    [self performSegueWithIdentifier:kCreateRoomToChatRoomIdentifier sender:room];
}


#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != 2) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [self.roomNameField resignFirstResponder];
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.delegate = self;
            imagePickerController.allowsEditing = NO;
            
            switch (buttonIndex) {
                case 0:
                    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                    break;
                case 1:
                    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    break;
                    
                default:
                    break;
            }
            [self presentModalViewController:imagePickerController animated:YES];
        }
    }
}


#pragma mark - 
#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // receiving image from delegate:
    UIImage *image = info[@"UIImagePickerControllerOriginalImage"];
    // crop image:
    UIImage *scaledImage =[image imageByScalingProportionallyToMinimumSize:CGSizeMake(200, 200)];
    self.roomImageView.image = scaledImage;
    self.cachedImage = scaledImage;
    [self dismissModalViewControllerAnimated:YES];
    [self.roomNameField becomeFirstResponder];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissModalViewControllerAnimated:YES];
    [self.roomNameField becomeFirstResponder];
}



#pragma mark -
#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ((ChatRoomViewController *)segue.destinationViewController).controllerName = @"Create Room View";
    ((ChatRoomViewController *)segue.destinationViewController).currentChatRoom = sender;
}

@end
