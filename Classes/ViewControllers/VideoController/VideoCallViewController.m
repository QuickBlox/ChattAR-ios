//
//  VideoCallViewController.m
//  Chattar
//
//  Created by Andrey Kozlov on 07/01/2014.
//  Copyright (c) 2014 Stefano Antonelli. All rights reserved.
//

#import "VideoCallViewController.h"
#import "QBStorage.h"

@interface VideoCallViewController () <QBChatDelegate, AVAudioPlayerDelegate, UIAlertViewDelegate>

@property (nonatomic) IBOutlet UIButton *closeButton;
@property (nonatomic) IBOutlet UIButton *callButton;
@property (nonatomic) IBOutlet UIImageView *opponentVideoView;
@property (nonatomic) IBOutlet UIImageView *myVideoView;
@property (nonatomic) IBOutlet UIView *controllLayerView;
@property (nonatomic) IBOutlet UIView *callInProgressLayerView;
@property (nonatomic) IBOutlet UISegmentedControl *audioOutput;
@property (nonatomic) IBOutlet UISegmentedControl *videoOutput;
@property (nonatomic) IBOutlet UILabel *ringigngLabel;
@property (nonatomic) IBOutlet UIActivityIndicatorView *callingActivityIndicator;

@property (nonatomic) AVAudioPlayer *ringingPlayer;
@property (nonatomic) QBVideoChat *videoChat;
@property (nonatomic) NSUInteger videoChatOpponentID;
@property (nonatomic) enum QBVideoChatConferenceType videoChatConferenceType;
@property (nonatomic) NSString *sessionID;
@property (nonatomic) UIAlertView *callAlert;

- (IBAction)callButtonTap:(id)sender;
- (IBAction)closeButtonTap:(id)sender;
- (IBAction)audioOutputDidChange:(UISegmentedControl *)sender;
- (IBAction)videoOutputDidChange:(UISegmentedControl *)sender;

@end

@implementation VideoCallViewController

- (NSInteger)opponentId {
    
    if (self.destinationUser != nil) {
        return [self.destinationUser[@"quickbloxID"] integerValue];
    }
    
    return -1;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.closeButton.layer.cornerRadius = 5;
    self.closeButton.layer.masksToBounds = YES;
    
//    [[QBStorage shared] me];
//    self.destinationUser;
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    
    // Start sending chat presence
    //
    [QBChat instance].delegate = self;
    [NSTimer scheduledTimerWithTimeInterval:30 target:[QBChat instance] selector:@selector(sendPresence) userInfo:nil repeats:YES];
}


#pragma mark - Controll Buttons

- (IBAction)closeButtonTap:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)callButtonTap:(id)sender {
    
    // Call
    if (self.callButton.tag == 101) {

        self.callButton.tag = 102;
        
        // Setup video chat
        //
        if (self.videoChat == nil) {
            
            self.videoChat = [[QBChat instance] createAndRegisterVideoChatInstance];
            self.videoChat.viewToRenderOpponentVideoStream = self.opponentVideoView;
            self.videoChat.viewToRenderOwnVideoStream = self.myVideoView;
        }
        
        // Set Audio & Video output
        //
        self.videoChat.useHeadphone = self.audioOutput.selectedSegmentIndex;
        self.videoChat.useBackCamera = self.videoOutput.selectedSegmentIndex;
        
        self.opponentVideoView.contentMode = UIViewContentModeScaleAspectFit;
        
        // Call user by ID
        //
        [self.videoChat callUser:[self opponentId] conferenceType:QBVideoChatConferenceTypeAudioAndVideo];
        
        self.callButton.hidden = YES;
        self.callInProgressLayerView.hidden = NO;
        self.ringigngLabel.text = @"Calling...";
        [self.callingActivityIndicator startAnimating];
        
        // Finish
    } else {
        self.callButton.tag = 101;
        
        // Finish call
        //
        [self.videoChat finishCall];
        
        self.myVideoView.hidden = YES;
        
        self.opponentVideoView.layer.contents = (id)[[UIImage imageNamed:@"human.png"] CGImage];
        self.opponentVideoView.image = [UIImage imageNamed:@"human.png"];
        self.opponentVideoView.contentMode = UIViewContentModeCenter;
        
        [self.callButton setTitle:@"Start Call" forState:UIControlStateNormal];
        
        [self.callingActivityIndicator stopAnimating];
        
        // release video chat
        //
        [[QBChat instance] unregisterVideoChatInstance:self.videoChat];
        self.videoChat = nil;
    }
}

- (IBAction)audioOutputDidChange:(UISegmentedControl *)sender {

    if (self.videoChat != nil) {
        self.videoChat.useHeadphone = sender.selectedSegmentIndex;
    }
}

- (IBAction)videoOutputDidChange:(UISegmentedControl *)sender {
    
    if (self.videoChat != nil) {
        self.videoChat.useBackCamera = sender.selectedSegmentIndex;
    }
}

#pragma mark - Other Actions

- (void)reject {
    
    // Reject call
    //
    if (self.videoChat == nil) {
        
        self.videoChat = [[QBChat instance] createAndRegisterVideoChatInstanceWithSessionID:self.sessionID];
    }
    
    [self.videoChat rejectCallWithOpponentID:self.videoChatOpponentID];
    //
    //
    [[QBChat instance] unregisterVideoChatInstance:self.videoChat];
    self.videoChat = nil;
    
    // update UI
    self.callButton.hidden = NO;
    self.callInProgressLayerView.hidden = YES;
    
    // release player
    self.ringingPlayer = nil;
}

- (void)accept {
    
    NSLog(@"accept");
    
    // Setup video chat
    //
    if (self.videoChat == nil) {
        
        self.videoChat = [[QBChat instance] createAndRegisterVideoChatInstanceWithSessionID:self.sessionID];
        self.videoChat.viewToRenderOpponentVideoStream = self.opponentVideoView;
        self.videoChat.viewToRenderOwnVideoStream = self.myVideoView;
    }
    
    // Set Audio & Video output
    //
    self.videoChat.useHeadphone = self.audioOutput.selectedSegmentIndex;
    self.videoChat.useBackCamera = self.videoOutput.selectedSegmentIndex;
    
    self.opponentVideoView.contentMode = UIViewContentModeScaleAspectFit;
    
    // Accept call
    //
    [self.videoChat acceptCallWithOpponentID:self.videoChatOpponentID conferenceType:self.videoChatConferenceType];
    
    self.callInProgressLayerView.hidden = YES;
    self.callButton.hidden = NO;
    [self.callButton setTitle:@"Hang up" forState:UIControlStateNormal];
    self.callButton.tag = 102;
    
    self.myVideoView.hidden = NO;
    
    self.ringingPlayer = nil;
}

- (void)hideCallAlert {
    
    [self.callAlert dismissWithClickedButtonIndex:-1 animated:YES];
    self.callAlert = nil;
    
    self.callButton.hidden = NO;
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{

    self.ringingPlayer = nil;
}

#pragma mark - QBChatDelegate

- (void)chatDidReceiveCallRequestFromUser:(NSUInteger)userID withSessionID:(NSString *)sessionID conferenceType:(enum QBVideoChatConferenceType)conferenceType {
    NSLog(@"chatDidReceiveCallRequestFromUser %d", userID);
    
    // save  opponent data
    self.videoChatOpponentID = userID;
    self.videoChatConferenceType = conferenceType;
    self.sessionID = sessionID;
    
    self.callButton.hidden = YES;
    
    // show call alert
    //
    if (self.callAlert == nil) {
        
        NSString *message = [NSString stringWithFormat:@"%@ is calling. Would you like to answer?", @"Other User"];
        self.callAlert = [[UIAlertView alloc] initWithTitle:@"Call" message:message delegate:self cancelButtonTitle:@"Decline" otherButtonTitles:@"Accept", nil];
        [self.callAlert show];
    }
    
    // hide call alert if opponent has canceled call
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideCallAlert) object:nil];
    [self performSelector:@selector(hideCallAlert) withObject:nil afterDelay:4];
    
    // play call music
    //
    if (self.ringingPlayer == nil) {

        NSString *path = [[NSBundle mainBundle] pathForResource:@"ringing" ofType:@"wav"];
        NSURL *url = [NSURL fileURLWithPath:path];
        self.ringingPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:NULL];
        self.ringingPlayer.delegate = self;
        [self.ringingPlayer setVolume:1.0];
        [self.ringingPlayer play];
    }
}

- (void)chatCallUserDidNotAnswer:(NSUInteger)userID {

    NSLog(@"chatCallUserDidNotAnswer %d", userID);
    
    self.callButton.hidden = NO;
    self.callInProgressLayerView.hidden = YES;
    [self.callingActivityIndicator stopAnimating];
    self.callButton.tag = 101;
    
    [[[UIAlertView alloc] initWithTitle:@"QuickBlox VideoChat" message:@"User isn't answering. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

- (void)chatCallDidRejectByUser:(NSUInteger)userID {

    NSLog(@"chatCallDidRejectByUser %d", userID);
    
    self.callButton.hidden = NO;
    self.callInProgressLayerView.hidden = YES;
    [self.callingActivityIndicator stopAnimating];
    
    self.callButton.tag = 101;
    
    [[[UIAlertView alloc] initWithTitle:@"QuickBlox VideoChat" message:@"User has rejected your call." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

- (void)chatCallDidAcceptByUser:(NSUInteger)userID {
    NSLog(@"chatCallDidAcceptByUser %d", userID);
    
    [self.callingActivityIndicator stopAnimating];
    self.callInProgressLayerView.hidden = YES;
    
    self.callButton.hidden = NO;
    [self.callButton setTitle:@"Hang up" forState:UIControlStateNormal];
    self.callButton.tag = 102;
    
    self.myVideoView.hidden = NO;
    
//    [self.startingCallActivityIndicator startAnimating];
}

- (void)chatCallDidStopByUser:(NSUInteger)userID status:(NSString *)status {
    
    NSLog(@"chatCallDidStopByUser %d purpose %@", userID, status);
    
    if ([status isEqualToString:kStopVideoChatCallStatus_OpponentDidNotAnswer]) {
        
        self.callAlert.delegate = nil;
        [self.callAlert dismissWithClickedButtonIndex:0 animated:YES];
        self.callAlert = nil;
        
        self.callInProgressLayerView.hidden = YES;
        
        self.ringingPlayer = nil;
    } else {
        
        self.myVideoView.hidden = YES;
        
        self.opponentVideoView.layer.contents = (id)[[UIImage imageNamed:@"human.png"] CGImage];
        self.opponentVideoView.image = [UIImage imageNamed:@"human.png"];
        self.opponentVideoView.contentMode = UIViewContentModeCenter;
        
        [self.callButton setTitle:@"Start Call" forState:UIControlStateNormal];
        self.callButton.tag = 101;
    }
    
    self.callButton.hidden = NO;
    
    // release video chat
    //
    [[QBChat instance] unregisterVideoChatInstance:self.videoChat];
    self.videoChat = nil;
}

- (void)chatCallDidStartWithUser:(NSUInteger)userID sessionID:(NSString *)sessionID {
//    [startingCallActivityIndicator stopAnimating];
}

- (void)didStartUseTURNForVideoChat {
    //    NSLog(@"_____TURN_____TURN_____");
}


#pragma mark - UIAlertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
            // Reject
        case 0:
            [self reject];
            break;
            // Accept
        case 1:
            [self accept];
            break;
            
        default:
            break;
    }
    
    self.callAlert = nil;
}

@end
