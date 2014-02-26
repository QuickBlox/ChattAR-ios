//
//  QBService.m
//  ChattAR
//
//  Created by Igor Alefirenko on 25/10/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import "FBService.h"
#import "QBService.h"
#import "FBStorage.h"
#import "QBStorage.h"
#import "Utilites.h"
#import "MBProgressHUD.h"
#import "LocationService.h"
#import "ChatRoomStorage.h"
#import "AppSettingsService.h"
#import "ChattARAppDelegate+PushNotifications.h"
#import "ProcessStateService.h"
#import "NSString+Parsing.h"


@implementation QBService

+ (instancetype)defaultService {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        [QBChat instance].delegate = self;
        self.userIsJoinedChatRoom = NO;
    }
    return self;
}


#pragma mark -
#pragma mark Requests

- (void)usersWithFacebookIDs:(NSArray *)facebookIDs  {
    [QBUsers usersWithFacebookIDs:facebookIDs delegate:self];
}


#pragma mark -
#pragma mark Loading and handling Facebook users

- (void)loadAndHandleOtherFacebookUsers:(NSArray *)userIDs {
    if([userIDs count] == 0){
        [[NSNotificationCenter defaultCenter] postNotificationName:CAStateDataLoadedNotification object:nil userInfo:@{kUsersLoaded:@YES}];
        return;
    }
    
    // get facebook profiles of other users
    [[FBService shared] usersProfilesWithIDs:userIDs resultBlock:^(id result) {
        
        // set other users
        NSMutableDictionary *searchResult = (FBGraphObject *)result;
        NSMutableArray *users = [NSMutableArray arrayWithArray:[searchResult allValues]];
        [QBStorage shared].otherUsers = users;

        NSMutableArray *facebookUsersIDs = [[NSMutableArray alloc] init];
        
        // add photos to other user, collect ids
        for (NSMutableDictionary *user in users) {
            // add photo
            NSString *photoURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?access_token=%@", [user objectForKey:kId], [FBStorage shared].accessToken];
            [user setObject:photoURL forKey:kPhoto];
            
            // collect id
            NSString *userID = user[kId];
            [facebookUsersIDs addObject:userID];
            
            // last message date
            QBChatMessage *message = [([QBStorage shared].allQuickBloxHistoryConversation[userID])[kMessage] lastObject];
            NSString *createdTime = [[Utilites shared].dateFormatter stringFromDate:message.datetime];
            if (createdTime != nil) {
                user[kLastMessageDate] = createdTime;
            }
        }
        
        if(facebookUsersIDs.count == 0){
            [[NSNotificationCenter defaultCenter] postNotificationName:CAStateDataLoadedNotification object:nil userInfo:@{kUsersLoaded:@YES}];
            return;
        }

        // qb users will come here:
        void (^usersResultBlock) (Result *) = ^(Result *result) {
            if ([result isKindOfClass:[QBUUserPagedResult class]]) {
                QBUUserPagedResult *pagedResult = (QBUUserPagedResult *)result;
                NSArray *qbUsers = pagedResult.users;
                
                // put quickbloxIDs to facebook users
                for (QBUUser *quickbloxUser in qbUsers) {
                    NSMutableDictionary *otherUser = [QBStorage shared].otherUsersAsDictionary[quickbloxUser.facebookID];
                    otherUser[kQuickbloxID] = [@(quickbloxUser.ID) stringValue];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:CAStateDataLoadedNotification object:nil userInfo:@{kUsersLoaded:@YES}];
            }
        };
        
        // search QB users by Facebook ids
        PagedRequest *pagedRequest = [PagedRequest request];
        pagedRequest.perPage = 100;
        [QBUsers usersWithFacebookIDs:facebookUsersIDs pagedRequest:pagedRequest delegate:[QBEchoObject instance] context:[QBEchoObject makeBlockForEchoObject:usersResultBlock]];
    }];
}

#pragma mark -
#pragma mark LogIn & Log Out

- (void)loginWithUser:(QBUUser *)user {
    [[QBChat instance] loginWithUser:user];
}

- (void)loginToChatFromBackground {
    [self chatCreateOrJoinRoomWithName:[QBStorage shared].chatRoomName andNickName:[[FBStorage shared].me objectForKey:kId]];
}


#pragma mark -
#pragma mark Messages

- (void)sendMessage:(NSString *)message toUser:(NSUInteger)userID option:(id)option {
    QBChatMessage *msg = [QBChatMessage message];

    NSDate *date = [NSDate date];
    msg.datetime = date;
    
    msg.recipientID = userID;
    NSDictionary *currentUser = [FBStorage shared].me;
    NSString *urlString = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@/picture?access_token=%@", [currentUser objectForKey:kId], [FBStorage shared].accessToken];
    NSString *facebookID = [[FBStorage shared].me objectForKey:kId];
    NSString *quickbloxID = [NSString stringWithFormat:@"%i", [QBStorage shared].me.ID];
    // create message:
    NSMutableDictionary *messageDictionary = [[NSMutableDictionary alloc] init];
    [messageDictionary setObject:message forKey:kMessage];
    [messageDictionary setObject:[currentUser objectForKey:kName] forKey:kUserName];
    [messageDictionary setObject:urlString forKey:kPhoto];
    [messageDictionary setObject:facebookID forKey:kId];
    [messageDictionary setObject:quickbloxID forKey:kQuickbloxID];
    // formatting to JSON:
    NSString *jsonString = [self archiveMessageData:messageDictionary];
    msg.text = jsonString;
    
    [[QBChat instance] sendMessage:msg];
    [Flurry logEvent:kFlurryEventDialogMessageWasSent withParameters:@{@"type":@"QuickBlox"}];
    [self cachingMessage:msg forUserID:option received:NO];
}

- (void)cachingMessage:(QBChatMessage *)message forUserID:(NSString *)userID received:(BOOL)received{
    
    NSString *dateTime = [[Utilites shared].dateFormatter stringFromDate:message.datetime];
    
    NSMutableDictionary *user = [QBStorage shared].otherUsersAsDictionary[userID];
    if (user != nil) {
        user[kLastMessageDate] = dateTime;
    } else {
        NSDictionary *messageData = [[QBService defaultService] unarchiveMessageData:message.text];
        
        user = [NSMutableDictionary new];
        NSString *fullName = messageData[kUserName];
        user[kName] = fullName;
        user[kFirstName] = [fullName firstNameFromNameField];
        user[kLastName] = [fullName lastNameFromNameField];
        user[kId] = messageData[kId];
        user[kQuickbloxID] = messageData[kQuickbloxID];
        user[kPhoto] = messageData[kPhoto];
        
        [[QBStorage shared].otherUsers addObject:user];
        [QBStorage shared].otherUsersAsDictionary[userID] = user;
    }
    
    NSMutableDictionary *temporary = [QBStorage shared].allQuickBloxHistoryConversation[userID];
    if (temporary != nil) {
        // unread messages count:
        if (received) {
            if (![ControllerStateService shared].isInDialog && ![[ProcessStateService shared].inDialogWithUserID isEqualToString:user[kId]]) {
                int numb = [temporary[kUnread] integerValue];
                numb++;
                temporary[kUnread] = @(numb);
            }
        }
        NSMutableArray *messages = temporary[kMessage];
        [messages addObject:message];
    } else {
        NSMutableArray *messages = [[NSMutableArray alloc] initWithObjects:message, nil];
        temporary = [@{kMessage: messages} mutableCopy];
        if (received) {
            if (![ControllerStateService shared].isInDialog && ![[ProcessStateService shared].inDialogWithUserID isEqualToString:user[kId]]) {
                temporary[kUnread] = @(1);
            }
        }
        [QBStorage shared].allQuickBloxHistoryConversation[userID] = temporary;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:CAChatDidReceiveOrSendMessageNotification object:nil];
}

- (void)sendMessage:(NSString *)message toChatRoom:(QBChatRoom *)room quote:(id)quote {
    CLLocationCoordinate2D currentLocation = [LocationService shared].myLocation.coordinate;
    
    NSString *myLatitude = [@(currentLocation.latitude) stringValue];
    NSString *myLongitude = [@(currentLocation.longitude) stringValue];
    NSString *userName =  [FBStorage shared].me[kName];
    NSString *urlString = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@/picture?access_token=%@", [FBStorage shared].me[kId], [FBStorage shared].accessToken];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[kLatitude] = myLatitude;
    dict[kLongitude] = myLongitude;
    dict[kPhoto] = urlString;
    dict[kUserName] = userName;
    
    dict[kId] = [FBStorage shared].me[kId];
    dict[kQuickbloxID] = [FBStorage shared].me[kQuickbloxID];
    
    NSString *isQuoted = @"No";
    if (quote != nil) {
        isQuoted = @"Yes";
        [dict setValue:quote forKey:kQuote];
        quote = nil;
    }
    [dict setValue:message forKey:kMessage];
    [dict setValue:[[FBStorage shared].me objectForKey:kId] forKey:kId];
    NSString *quickbloxID = [NSString stringWithFormat:@"%i",[QBStorage shared].me.ID];
    [dict setValue:quickbloxID forKey:kQuickbloxID];
    // formatting to JSON:
    NSString* jsonString = [[QBService defaultService] archiveMessageData:dict];
    
    [[QBChat instance] sendMessage:jsonString toRoom:room];
    [Flurry logEvent:kFlurryEventRoomMessageWasSent withParameters:@{@"room_name":room.name, kQuote:isQuoted}];
}

- (void)sendPushNotificationWithMessage:(NSString *)message toUser:(NSString *)quickbloxUserID roomName:(NSString *)roomName
{
    if (quickbloxUserID == nil) {
        return;
    }
    NSMutableDictionary *payload = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *aps = [[NSMutableDictionary alloc] init];
    aps[QBMPushMessageSoundKey] = @"default";
    aps[QBMPushMessageAlertKey] = message;
    aps[kId] = [FBStorage shared].me[kId];
    aps[kQuickbloxID] = [FBStorage shared].me[kQuickbloxID];
    if (roomName != nil) {
        aps[kRoomName] = roomName;
    }
    payload[QBMPushMessageApsKey] = aps;
    QBMPushMessage *pushMessage = [[QBMPushMessage alloc] initWithPayload:payload];
    [QBMessages TSendPush:pushMessage toUsers:quickbloxUserID delegate:nil];
}


#pragma mark -
#pragma mark Operations

- (void)chatCreateOrJoinRoomWithName:(NSString *)roomName andNickName:(NSString *)nickname
{
    NSString *encodedString = [Utilites urlencode:roomName];
    [[QBChat instance] createOrJoinRoomWithName:encodedString nickname:nickname membersOnly:NO persistent:YES];
}

- (NSMutableDictionary *)findConversationToUserWithMessage:(QBChatMessage *)message
{
    NSMutableDictionary *messageData = [[QBService defaultService] unarchiveMessageData:message.text];
    NSString *userID = [messageData objectForKey:kId];
    NSMutableDictionary *conversation = [[QBStorage shared].allQuickBloxHistoryConversation objectForKey:userID];
    if (conversation == nil) {
        NSMutableArray *messages = [[NSMutableArray alloc] init];
        conversation = [[NSMutableDictionary alloc] init];
        [conversation setObject:messages forKey:kMessage];
    }
    return conversation;
}

- (NSMutableDictionary *)findConversationWithUser:(NSMutableDictionary *)aFriend
{
    NSString *friendID = [aFriend objectForKey:kId];
    NSMutableDictionary *conversation = [[QBStorage shared].allQuickBloxHistoryConversation objectForKey:friendID];
    if (conversation == nil) {
        NSMutableArray *messages = [[NSMutableArray alloc] init];
        conversation = [[NSMutableDictionary alloc] init];
        [conversation setObject:messages forKey:kMessage];
    }
    return conversation;
}

- (NSMutableDictionary *)findUserWithID:(NSString *)ID
{
    NSArray *users = [QBStorage shared].otherUsers;
    NSMutableDictionary *currentUser = nil;
    for (NSMutableDictionary *user in users) {
        if ([ID isEqualToString:user[kId]]) {
            currentUser = user;
            break;
        }
    }
    return currentUser;
}


#pragma mark -
#pragma mark Archiving

- (NSString *)archiveMessageData:(NSMutableDictionary *)messageData
{
    NSError *error = nil;
    NSData* nsdata = [NSJSONSerialization dataWithJSONObject:messageData options:NSJSONWritingPrettyPrinted error:&error];
    NSString* jsonString =[[NSString alloc] initWithData:nsdata encoding:NSUTF8StringEncoding];
    return jsonString;
}

- (NSMutableDictionary *)unarchiveMessageData:(NSString *)messageData {
    NSData *dictData = [messageData dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *tempDict = [NSJSONSerialization JSONObjectWithData:dictData options:NSJSONReadingAllowFragments error:nil];
    return tempDict;
}


#pragma mark -
#pragma mark QBChatDelegate

- (void)chatDidLogin
{
    NSLog(@"Chat login success");
    self.presenceTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:[QBChat instance] selector:@selector(sendPresence) userInfo:nil repeats:YES];
    [[LocationService shared] startUpdateLocation];
    [[Utilites shared].progressHUD performSelector:@selector(hide:) withObject:nil];
    NSDictionary *aps = [QBStorage shared].pushNotification[@"aps"];
    
    if ([QBStorage shared].pushNotification != nil) {
        if ([QBService defaultService].userIsJoinedChatRoom) {
            [[Utilites shared].progressHUD performSelector:@selector(show:) withObject:nil];
            if (aps[kRoomName] == nil) {
                [[QBService defaultService] loginToChatFromBackground];
            }
            if (![[QBStorage shared].chatRoomName isEqualToString:aps[kRoomName]]) {
                [(ChattARAppDelegate *)[UIApplication sharedApplication].delegate processRemoteNotification:[QBStorage shared].pushNotification];
            } else {
                [[QBService defaultService] loginToChatFromBackground];
            }
        } else {
            [(ChattARAppDelegate *)[UIApplication sharedApplication].delegate processRemoteNotification:[QBStorage shared].pushNotification];
        }
        [QBStorage shared].pushNotification = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidLogin object:nil];
        return;
    } else {
        if ([QBService defaultService].userIsJoinedChatRoom) {
            [[Utilites shared].progressHUD performSelector:@selector(show:) withObject:nil];
            [[QBService defaultService] loginToChatFromBackground];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidLogin object:nil];
}

- (void)chatDidReceiveMessage:(QBChatMessage *)message
{
    NSMutableDictionary *messageData = [self unarchiveMessageData:message.text];   // JSON parsing
    NSString *facebookID = messageData[kId];
    if ([facebookID isEqualToString:[FBStorage shared].me[kId]]) {
        return;
    }
    [self cachingMessage:message forUserID:facebookID received:YES];
    
    // play sound and vibrate:
    AppSettingsService *settingService = [AppSettingsService shared];
    [Utilites playSound:settingService.soundEnabled vibrate:settingService.vibrationEnabled];
}

- (void)chatRoomDidReceiveMessage:(QBChatMessage *)message fromRoom:(NSString *)roomName
{
    [[QBStorage shared].chatHistory addObject:message];
    [[NSNotificationCenter defaultCenter] postNotificationName:CAChatRoomDidReceiveOrSendMessageNotification object:nil];
}

- (void)chatRoomDidEnter:(QBChatRoom *)room
{
    [room addUsers:@[@34]];
    
    [QBService defaultService].userIsJoinedChatRoom = YES;
    NSLog(@"Chat Room is opened");
    
    [[QBStorage shared] setJoinedChatRoom:room];
    //get room
    [[NSNotificationCenter defaultCenter] postNotificationName:CAChatRoomDidEnterNotification object:nil];
}

- (void)chatRoomDidNotEnter:(NSString *)roomName error:(NSError *)error
{
    NSLog(@"Error:%@", error);
}


- (void)chatRoomDidLeave:(NSString *)roomName
{
    NSLog(@"Did  Leave worked");
    [[QBStorage shared] setJoinedChatRoom:nil];
}

@end
