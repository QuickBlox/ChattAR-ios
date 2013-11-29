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

@interface CreateRoomViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, QBActionStatusDelegate>

@property (strong, nonatomic) IBOutlet UITextField *roomNameField;
@property (strong, nonatomic) IBOutlet AsyncImageView *roomImageView;
@property (strong, nonatomic) IBOutlet UIButton *creatingRoomButton;

- (IBAction)chooseImage:(id)sender;
- (IBAction)createRoom:(id)sender;

@end

@implementation CreateRoomViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.creatingRoomButton.layer.cornerRadius = 5.0f;

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
    // create room:
    NSData *image = UIImageJPEGRepresentation(self.roomImageView.image, 0.5);
    [QBContent TUploadFile:image fileName:@"loool" contentType:@"image/jpg" isPublic:YES delegate:self];
}


#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        // to do:
    }
    switch (buttonIndex) {
        case 0:
        {
            [self.roomNameField resignFirstResponder];
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePickerController.delegate = self;
            imagePickerController.allowsEditing = NO;
            [self presentModalViewController:imagePickerController animated:YES];
        }
        break;
        case 1:
        {
            [self.roomNameField resignFirstResponder];
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePickerController.delegate = self;
            [self presentModalViewController:imagePickerController animated:YES];
            
        }
        break;
            
        default:
            break;
    }
}


#pragma mark - 
#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[@"UIImagePickerControllerOriginalImage"];
    // crop image:
    UIImage *scaledImage =[image imageByScalingProportionallyToMinimumSize:CGSizeMake(200, 200)];
    self.roomImageView.image = scaledImage;
    [self dismissModalViewControllerAnimated:YES];
    [self.roomNameField becomeFirstResponder];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissModalViewControllerAnimated:YES];
    [self.roomNameField becomeFirstResponder];
}


#pragma mark -
#pragma mark QBActionStatusDelegate

-(void)completedWithResult:(Result*)result {
    // Upload file result
    if(result.success && [result isKindOfClass:[QBCFileUploadTaskResult class]]){
        // File uploaded, do something
        
        QBCBlob *uploadedFile  = ((QBCFileUploadTaskResult *)result).uploadedBlob;
        
        // File public url. Will be null if isPublic:NO in query
        NSString *fileUrl = [uploadedFile publicUrl];
    }else{
        NSLog(@"errors=%@", result.errors);
    }
}

@end
