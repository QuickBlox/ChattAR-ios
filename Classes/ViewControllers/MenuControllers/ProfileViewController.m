//
//  ProfileViewController.m
//  ChattAR
//
//  Created by Igor Alefirenko on 06/11/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "ProfileViewController.h"
#import "AsyncImageView.h"
#import "FBStorage.h"
#import "FBService.h"


@interface ProfileViewController ()

@property (nonatomic, strong) NSMutableDictionary *friendProfile;
@property (strong, nonatomic) IBOutlet AsyncImageView *friendPhotoView;
@property (strong, nonatomic) IBOutlet UIView *photoFrame;
@property (strong, nonatomic) IBOutlet AsyncImageView *coverView;
@property (strong, nonatomic) IBOutlet UILabel *friendName;

- (IBAction)back:(id)sender;

@end


@implementation ProfileViewController


#pragma mark -
#pragma mark UIViewController Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Profile";
    
    self.photoFrame.layer.borderColor = [[UIColor blackColor] CGColor];
    self.photoFrame.layer.borderWidth = 0.7f;
    [self getUserProfile:self.currentUser];
    
    [self configureCoverImageLayer];
}

- (void)getUserProfile:(NSMutableDictionary *)user {
    [[FBService shared] userProfileWithID:[user objectForKey:kId] withBlock:^(id result) {
        
        self.friendProfile = result;
        self.friendName.text = [self.friendProfile objectForKey:kName];
        [self gettingFriendAvatar];
        [self gettingCoverImage];
    }];
}

- (void)configureCoverImageLayer
{
    self.coverView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.coverView.layer.shadowRadius = 5.0f;
    self.coverView.layer.masksToBounds = NO;
    self.coverView.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    self.coverView.layer.shadowOpacity = 1.0f;
    self.coverView.layer.borderWidth = 0.1f;
}

- (void)gettingFriendAvatar {
    NSString *urlString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=120&height=120", [self.friendProfile objectForKey:kId]];
    [self.friendPhotoView setImageURL:[NSURL URLWithString:urlString]];
}

- (void)gettingCoverImage {
    NSString *coverString = [NSString stringWithFormat:@"https://graph.facebook.com/%@?fields=cover", [self.friendProfile objectForKey:kId]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:coverString]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            UIAlertView *alert = [[UIAlertView alloc]   initWithTitle:@"Error"
                                                        message:@"Something was wrong with Internet Connnection"
                                                        delegate:nil cancelButtonTitle:@"Cancel"
                                                        otherButtonTitles: nil];
            [alert show];
            return;
        }
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSData *jsonData = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
        NSString *coverPhotoURL = [[jsonDict objectForKey:@"cover"] objectForKey:@"source"];
        [self.coverView setImageURL:[NSURL URLWithString:coverPhotoURL]];
    } ];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
