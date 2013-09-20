//
//  ChatRoomViewController.m
//  ChattAR
//
//  Created by Igor Alefirenko on 11/09/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//
#import "ChatViewController.h"
#import "ChatRoomViewController.h"
#import "ChatRoomCell.h"
#import "DataManager.h"
#import "FBService.h"
#import <CoreLocation/CoreLocation.h>

//definitions
#define kLatitude       @"latitude"
#define kLongitude      @"longitude"

@interface ChatRoomViewController ()
@property (strong, nonatomic) CLLocationManager *currentLocation;
@property (assign, nonatomic) CLLocationCoordinate2D myCoordinates;
@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) QBChatRoom *currentRoom;
@property (strong, nonatomic) QBChatMessage *userMessage;
@property (strong, nonatomic) IBOutlet UIView *inputTextView;
@property (strong, nonatomic) IBOutlet UITextField *inputMessageField;
@property (strong, nonatomic) NSMutableArray *chatHistory;
@property (strong, nonatomic) NSIndexPath *cellPath;
@property CGFloat cellSize;


-(IBAction)textEditDone:(id)sender;
- (IBAction)backToRooms:(id)sender;
- (IBAction)sendMessageButton:(id)sender;

//parsing...
- (NSString *)gettingLocationFromString:(NSString *)string;
- (CLLocationCoordinate2D)stringToCoordinates:(NSString *)subString;

@end

@implementation ChatRoomViewController
@synthesize cellPath;

#pragma mark LifeCycle

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    self.title = @"Default";
    self.chatHistory = [[NSMutableArray alloc] init];
    self.inputTextView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.inputTextView.layer.shadowRadius = 7.0f;
    self.inputTextView.layer.masksToBounds = NO;
    self.inputTextView.layer.shadowOffset = CGSizeMake(0.0f, 4.0f);
    self.inputTextView.layer.shadowOpacity = 1.0f;
    self.inputTextView.layer.borderWidth = 0.1f;
    //NSLog(@"Me fb id: %@", [[DataManager shared].currentFBUser objectForKey:kId]);
	// Do any additional setup after loading the view.
    self.cashedUser = [[CachedUser alloc] init];
    // getting my location...
    self.currentLocation = [[CLLocationManager alloc] init];
    self.currentLocation.delegate = self;
    [self.currentLocation setDistanceFilter:1];
    [self.currentLocation setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.currentLocation startUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setChatRoomTable:nil];
    [self setBackButton:nil];
    [self setInputTextView:nil];
    [self setInputMessageField:nil];
    [super viewDidUnload];
}

-(void)viewWillAppear:(BOOL)animated{
    self.title = [FBService shared].roomName;
    [self creatingOrJoiningRoom];
    [_chatRoomTable reloadData];
    [super viewWillAppear:animated];
}

#pragma mark -
#pragma mark Table View Data Source

static CGFloat padding = 20.0;

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_chatHistory count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *roomCellIdentifier = @"RoomCellIdentifier";
    ChatRoomCell *roomCell = [tableView dequeueReusableCellWithIdentifier:roomCellIdentifier];
    if (roomCell == nil)
    {
        roomCell = [[ChatRoomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:roomCellIdentifier];
        
        [roomCell.contentView addSubview:roomCell.userPhoto];
        [roomCell.contentView addSubview:roomCell.colorBuble];
        [roomCell.contentView addSubview:roomCell.message];
        [roomCell.contentView addSubview:roomCell.userName];
        [roomCell.contentView addSubview:roomCell.postMessageDate];
        [roomCell.contentView addSubview:roomCell.distance];
    }
    //Custom Initialization Room Cell
    
    
    // Buble
    if ([indexPath row] % 2 == 0) {
        roomCell.bubleImage = [UIImage imageNamed:@"01_green_chat_bubble.png"];
    } else {
        roomCell.bubleImage = [UIImage imageNamed:@"01_blue_chat_bubble.png"];
    }
    UIImage *img = [roomCell.bubleImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
    roomCell.colorBuble.image = img;
    
    
    
    
    
    
    
    CGSize textSize = { 225.0, 10000.0 };
    
    // user message

    QBChatMessage *currentMessage = [self.chatHistory objectAtIndex:[indexPath row]];
    //getting location of a message sender
    NSString *temp = [self gettingLocationFromString:currentMessage.text];
    CLLocationCoordinate2D userCoordinates = [self stringToCoordinates:temp];
    CLLocation *userLocation = [[CLLocation alloc] initWithLatitude:userCoordinates.latitude longitude:userCoordinates.longitude];
    CLLocationDistance distanceToMe = [self.currentLocation.location distanceFromLocation:userLocation];
    roomCell.distance.text = [self distanceFormatter:distanceToMe];
    
    //
    NSRange range = [currentMessage.text rangeOfString:@"}"];
    NSUInteger index = range.location+1;
    temp = [currentMessage.text substringFromIndex:index];
    
    roomCell.message.text = temp;

    // searching user in cache
    NSArray *keys = [[DataManager shared].fbUsersLoggedIn allKeys];
    for (NSString *key in keys) {
        if ( key.length > 7){ // not facebook
        if ([key isEqualToString:currentMessage.senderNick]) {
            NSDictionary *facebookUser = [[DataManager shared].fbUsersLoggedIn objectForKey:key];
            NSString *firstName = [facebookUser objectForKey:kFirstName];
            NSString *lastName = [facebookUser objectForKey:kLastName];
            
            roomCell.userName.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
            
            // getting userAvatar
            NSString *urlString = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@/picture?access_token=%@", currentMessage.senderNick, [DataManager shared].accessToken];
            NSURL *url = [NSURL URLWithString:urlString];
            [roomCell.userPhoto loadImageFromURL:url];
        } else {
            NSString *senderID = [@"/" stringByAppendingString:currentMessage.senderNick];
            [[FBService shared] userProfileWithID:senderID withBlock:^(id result) {
                FBGraphObject *fbUser = (FBGraphObject *)result;
                
                NSString *firstName = [fbUser objectForKey:kFirstName];
                NSString *lastName = [fbUser objectForKey:kLastName];
                roomCell.userName.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
                
                // getting UserAvatar
                NSString *urlString = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@/picture?access_token=%@", currentMessage.senderNick , [DataManager shared].accessToken];
                NSURL *url = [NSURL URLWithString:urlString];
                [roomCell.userPhoto loadImageFromURL:url];
                
                // cashe user
                NSMutableDictionary *tempDict = [NSMutableDictionary dictionary];
                tempDict = fbUser;
                [[DataManager shared].fbUsersLoggedIn setObject:tempDict forKey:currentMessage.senderNick];
            }];
        }
        } else roomCell.userName.text = currentMessage.senderNick;
    }
    [CLLocationManager locationServicesEnabled];
    //changing hight
    CGSize size = [[roomCell.message text] sizeWithFont:[UIFont systemFontOfSize:17.0f] constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
    
    [roomCell.message setFrame:CGRectMake(75, 43, 225, size.height)];
    [roomCell.colorBuble setFrame:CGRectMake(55, 10, 255, size.height+padding*2)];

    
    // post message date
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    NSString *time = [dateFormatter stringFromDate:currentMessage.datetime];
    
    roomCell.postMessageDate.text = time;
    
    return roomCell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGSize textSize = { 225.0, 10000.0 };
    QBChatMessage *message = [self.chatHistory objectAtIndex:[indexPath row]];
    NSString *currentMessage = [message text];
    
    NSRange range = [currentMessage rangeOfString:@"}"];
    NSUInteger index = range.location+1;
    currentMessage = [currentMessage substringFromIndex:index];
    
    //changing hight
    CGSize size = [currentMessage sizeWithFont:[UIFont systemFontOfSize:17.0f] constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
    size.height += padding*2;
    
    return size.height+10;
}


#pragma mark -
#pragma mark CoreLocationDelegate

- (void) locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
    NSLog(@"Error: %@", error);
}

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *lastLocation = [locations lastObject];
    self.myCoordinates = lastLocation.coordinate;
}


#pragma mark -
#pragma mark Table View Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.chatRoomTable deselectRowAtIndexPath:indexPath animated:YES];
    cellPath = indexPath;
    NSString *title = [[NSString alloc] initWithFormat:@"What do you want?"];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Reply", nil];
    [actionSheet showInView:self.view];
}

#pragma mark -
#pragma mark UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"Button whith number %i was clicked", buttonIndex);
    switch (buttonIndex) {
        case 0:
            // do something
            NSLog(@"REPLY");
            ChatRoomCell *getCell = [self.chatRoomTable cellForRowAtIndexPath:cellPath];
            //saving user...
            self.cashedUser.userPhotography = getCell.userPhoto.image;
            self.cashedUser.userName = getCell.userName.text;
            self.cashedUser.userMessage = getCell.message.text;
            self.cashedUser.dateTime = getCell.postMessageDate.text;
            
            NSLog(@"Username: %@",self.cashedUser.userName);
            NSLog(@"Message: %@", self.cashedUser.userMessage);
            NSLog(@"Date Time: %@", self.cashedUser.dateTime);
            break;
    }
}

#pragma mark -
#pragma mark ChatRoom

-(void)creatingOrJoiningRoom{
    if ([QBChat instance].delegate == self) {
        //nothing
    } else {
    [QBChat instance].delegate = self;
    }
    [[QBChat instance] createOrJoinRoomWithName:[FBService shared].roomName nickname:[[DataManager shared].currentFBUser objectForKey:kId] membersOnly:NO persistent:YES];
    [_chatRoomTable reloadData];
}


#pragma mark -
#pragma mark QBActionStatusDelegate

-(void)completedWithResult:(Result *)result{
    if (result.success) {
        if ([result isKindOfClass:[QBUUserResult class]]) {
            QBUUserResult *activeResult = (QBUUserResult *)result;
            QBUUser *user = activeResult.user;
            [DataManager shared].currentQBUser = user;
            [[DataManager shared].fbUsersLoggedIn setObject:user forKey:[NSString stringWithFormat:@"%i", user.ID]];
        }
    }
}

#pragma mark -
#pragma mark QBChatDelegate

// if chat room is created or user is joined
-(void)chatRoomDidEnter:(QBChatRoom *)room{
    NSLog(@"Chat Room is opened");
    //get room
    self.currentRoom = room;
}

- (void)chatRoomDidNotEnter:(NSString *)roomName error:(NSError *)error{
    NSLog(@"Error:%@", error);
}
// back button
- (IBAction)backToRooms:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

// action message button
- (IBAction)sendMessageButton:(id)sender {
    if ([self.inputMessageField.text isEqual:@""]) {
        //don't send
    } else {
        NSString *myLatitude = [[NSString alloc] initWithFormat:@"%f",self.myCoordinates.latitude];
        NSString *myLongitude = [[NSString alloc] initWithFormat:@"%f", self.myCoordinates.longitude];
        NSString *coordinateString = [NSString stringWithFormat:@"{%@;%@}", myLatitude, myLongitude];
        self.inputMessageField.text = [coordinateString stringByAppendingString:self.inputMessageField.text];
        
        [[QBChat instance] sendMessage:self.inputMessageField.text toRoom:self.currentRoom];
        self.inputMessageField.text = @"";
    }
    [self.chatRoomTable reloadData];
    [self.inputMessageField resignFirstResponder];
}

//  receiving messages
-(void)chatRoomDidReceiveMessage:(QBChatMessage *)message fromRoom:(NSString *)roomName{
    QBDLogEx(@"message %@", message);
    
    self.userMessage = message;
    [self.chatHistory addObject:message];
    [self.chatRoomTable reloadData];
    
}
#pragma mark -
#pragma mark Show/Hide Keyboard

-(void)showKeyboard{
    CGRect tableViewFrame = self.chatRoomTable.frame;
    CGRect inputPanelFrame = _inputTextView.frame;
    tableViewFrame.origin.y -= 215;
    inputPanelFrame.origin.y -= 215;
    //animation
    [UIView animateWithDuration:0.25f animations:^{
        [self.chatRoomTable setFrame:tableViewFrame];
        [_inputTextView setFrame:inputPanelFrame];
    }];
}

-(void)hideKeyboard{
    CGRect tableViewFrame = self.chatRoomTable.frame;
    CGRect inputPanelFrame = _inputTextView.frame;
    tableViewFrame.origin.y += 215;
    inputPanelFrame.origin.y += 215;
    //animation
    [UIView animateWithDuration:0.25f animations:^{
        [self.chatRoomTable setFrame:tableViewFrame];
        [_inputTextView setFrame:inputPanelFrame];
    }];    
}

#pragma mark -
#pragma mark UITextField

-(IBAction)textEditDone:(id)sender{
    [sender resignFirstResponder];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [self showKeyboard];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [self hideKeyboard];
}


#pragma mark -
#pragma mark Parser

- (NSString *)gettingLocationFromString:(NSString *)string{
    
    NSRange rangeOfBegining = [string rangeOfString:@"{"];
    NSRange rangeOfEnding = [string rangeOfString:@"}"];
    NSUInteger lengthOfSubstring = rangeOfEnding.location - rangeOfBegining.location;
    
    //getting string without characters: ">" & "<"
    NSRange substringRange;
    substringRange.location = rangeOfBegining.location+1;       // without "<"
    substringRange.length = lengthOfSubstring -1;               // without ">"
    NSString *subString = [string substringWithRange:substringRange];
    
    return subString;
}

-(CLLocationCoordinate2D)stringToCoordinates:(NSString *)subString{
    NSRange separatorRange = [subString rangeOfString:@";"];
    NSRange latitudeRange;
    latitudeRange.length = separatorRange.location;
    latitudeRange.location = 0;
    
    NSString *latitude = [subString substringWithRange:latitudeRange];
    NSString *longitude = [subString substringFromIndex:separatorRange.location+1];
    
    CGFloat floatLatitude = [latitude floatValue];
    CGFloat floatLongitude = [longitude floatValue];
    
    CLLocationCoordinate2D userCoordinates;
    userCoordinates.latitude = floatLatitude;
    userCoordinates.longitude = floatLongitude;
    
    return userCoordinates;
}


-(NSString *)distanceFormatter:(CLLocationDistance)distance{
    NSString *formatedDistance;
    NSInteger dist = round(distance);
    if (distance <=999) {
        formatedDistance = [NSString stringWithFormat:@"%d m", dist];
    } else{
        dist = round(dist) / 1000;
        formatedDistance = [NSString stringWithFormat:@"%d km",dist];
    }
    return formatedDistance;
}



@end
