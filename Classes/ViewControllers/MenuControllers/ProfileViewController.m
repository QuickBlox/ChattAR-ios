//
//  ProfileViewController.m
//  ChattAR
//
//  Created by Igor Alefirenko on 06/11/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import "ProfileViewController.h"
#import "AsyncImageView.h"
#import "FBStorage.h"
#import "FBService.h"
#import "ProfileCell.h"
#import "DetailProfileCell.h"
#import "Utilites.h"


@interface ProfileViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableDictionary *friendProfile;
@property (strong, nonatomic) IBOutlet AsyncImageView *friendPhotoView;
@property (strong, nonatomic) IBOutlet UIView *photoFrame;
@property (strong, nonatomic) IBOutlet AsyncImageView *coverView;
@property (strong, nonatomic) IBOutlet UILabel *friendName;
@property (strong, nonatomic) IBOutlet UITableView *userInfoTable;
@property (strong, nonatomic) NSArray *userInfo;

- (IBAction)back:(id)sender;

@end


@implementation ProfileViewController


#pragma mark -
#pragma mark UIViewController Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [Flurry logEvent:kFlurryEventProfileScreenWasOpened withParameters:@{kFrom:self.controllerTitle}];
    
    self.photoFrame.layer.borderColor = [[UIColor blackColor] CGColor];
    self.photoFrame.layer.borderWidth = 0.7f;
    [self getUserProfile:self.currentUser];
    
    [self configureCoverImageLayer];
}

- (void)getUserProfile:(NSMutableDictionary *)user {
    [[FBService shared] userProfileWithID:[user objectForKey:kId] withBlock:^(id result) {
        
        self.friendProfile = result;
        [self informationAboutUser:result];
        
        self.friendName.text = [self.friendProfile objectForKey:kName];
        [self gettingFriendAvatar];
        [self gettingCoverImage];
    }];
}

- (void)informationAboutUser:(NSMutableDictionary *)user {

    NSMutableArray *info = [[NSMutableArray alloc] init];
    // work:
    NSDictionary *work = [[user[@"work"] lastObject] objectForKey:@"employer"];
    if (work != nil) {
        NSString *workName = work[kName];
        NSDictionary *dict = @{@"work": workName, @"type":@"image"};
        [info addObject:dict];
    }
    // education:
    NSDictionary *education = [[user[@"education"] lastObject] objectForKey:@"school"];
    if (education != nil) {
        NSString *educationName = education[kName];
        NSDictionary *dict = @{@"education":educationName, @"type":@"image"};
        [info addObject:dict];
    }
    // location:
    NSDictionary *location = user[@"location"];
    if (location != nil) {
        NSString *locationName = location[kName];
        NSDictionary *dict = @{@"location":locationName, @"type":@"image"};
        [info addObject:dict];
    }
    // gender:
    NSString *gender = user[@"gender"];
    if (gender != nil) {
        NSDictionary *dict = @{@"Gender":gender};
        [info addObject:dict];
    }
    // birthday:
    NSString *birthday = user[@"birthday"];
    if (birthday != nil) {
        NSInteger age = [[Utilites shared] yearsFromDate:birthday];
        
        NSDictionary *dict = @{@"Age": [@(age) stringValue]};
        [info addObject:dict];
    }
    // likes:
    NSString *interest = [user[@"interested_in"] lastObject];
    if (interest != nil) {
        NSDictionary *dict = @{@"Likes": interest};
        [info addObject:dict];
    }
    // 
    
    self.userInfo = info;
    [self.userInfoTable reloadData];
}

- (void)configureCoverImageLayer
{
    self.coverView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
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
        if (coverPhotoURL != nil) {
            [self.coverView setImageURL:[NSURL URLWithString:coverPhotoURL]];
        }
    } ];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   return [_userInfo count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ProfileViewCellIdentifier = @"ProfileViewCell";
    static NSString *DetailProfileCellIdentifier = @"DetailProfileCell";
    
    UITableViewCell *cell = nil;
    NSDictionary *content = _userInfo[indexPath.row];
    if ([content[@"type"] isEqualToString:@"image"]) {
        cell =  (ProfileCell *)[tableView dequeueReusableCellWithIdentifier:ProfileViewCellIdentifier];
    } else {
        cell = (DetailProfileCell *)[tableView dequeueReusableCellWithIdentifier:DetailProfileCellIdentifier];
    }
    if ([cell isKindOfClass:[ProfileCell class]]) {
        [(ProfileCell *)cell handleCellWithContent:content];
    } else {
        [(DetailProfileCell *)cell handleCellWithContent:content];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30;
}

@end
