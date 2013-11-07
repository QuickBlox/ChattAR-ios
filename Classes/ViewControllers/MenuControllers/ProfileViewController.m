//
//  ProfileViewController.m
//  ChattAR
//
//  Created by Igor Alefirenko on 06/11/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "ProfileViewController.h"
#import "FBStorage.h"
#import "FBService.h"


@interface ProfileViewController ()

@property (nonatomic, strong) NSMutableDictionary *friendProfile;
@property (strong, nonatomic) IBOutlet UIImageView *friendPhotoView;
@property (strong, nonatomic) IBOutlet UIView *photoFrame;
@property (strong, nonatomic) IBOutlet UIImageView *coverView;
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
    [self getUserProfile:self.myFriend];
    
    [self configureCoverImageLayer];
    [self gettingFriendAvatar];
    [self gettingCoverImage];
    self.friendName.text = [self.friendProfile objectForKey:kName];
}

- (void)getUserProfile:(NSMutableDictionary *)user {
    [[FBService shared] userProfileWithID:[user objectForKey:kId] withBlock:^(id result) {
        self.friendProfile = result;
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
    NSData *urlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
    UIImage *friendAvatar = [UIImage imageWithData:urlData];
    self.friendPhotoView.image = friendAvatar;
}

- (void)gettingCoverImage {
    NSString *coverString = [NSString stringWithFormat:@"https://graph.facebook.com/%@?fields=cover", [self.friendProfile objectForKey:kId]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:coverString]];

    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
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
        
        //adding cover image:
        NSData *urlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:coverPhotoURL]];
        UIImage *friendCover = [UIImage imageWithData:urlData];
        self.coverView.image = friendCover;
    } ];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
