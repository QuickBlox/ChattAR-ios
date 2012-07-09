//
//  MessagesViewController.m
//  Chattar
//
//  Created by Sonny Black on 03.05.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "MessagesViewController.h"

@implementation MessagesViewController

@synthesize messageTableView = _messageTableView;
@synthesize searchField = _searchField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
	{
		self.title = NSLocalizedString(@"Dialogs", @"Dialogs");
		self.tabBarItem.image = [UIImage imageNamed:@"DockMessages.png"];
		
        // logout
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutDone) name:kNotificationLogout object:nil];
        
        isInitialized = NO;
        
        // init search array
        searchArray = [[NSMutableArray alloc] init];
	}
    return self;
}
	
-(void)dealloc
{	
	[searchArray release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:kNewChatMessageCome 
												  object:nil];
    
     [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationLogout object:nil];
	
	[super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// Register input message
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backgroundMessageReceived:)
												 name:kNewChatMessageCome object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
    // get inbox messages
    if(!isInitialized && [DataManager shared].currentFBUser){
        isInitialized = YES;
        
        // get inboxes messages
        [[FBService shared] inboxMessagesWithDelegate:self];
       
        // show progress
        HUD = [[MBProgressHUD alloc] initWithView:self.tabBarController.view];
        [self.tabBarController.view addSubview:HUD];
        HUD.dimBackground = YES;
        HUD.delegate = self;
        HUD.labelText = NSLocalizedString(@"Loading", nil);
        [HUD show:YES];
    
    }else{
        [self showInboxMessages];
    }
}

- (void)logoutDone{
    isInitialized = NO;
}

- (void)viewDidUnload
{
    self.messageTableView = nil;
    self.searchField = nil;
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)showInboxMessages
{
	// we dont have any friends
    if([[[DataManager shared].historyConversation allValues] count] > 0)
	{
		[[DataManager shared] sortMessagesArray];
        // reload table
        [_messageTableView reloadData];
    }
    
    [HUD hide:YES];
}


#pragma mark -
#pragma mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{    
    if([[_searchField text] length] > 0)
    {
        return NSLocalizedString(@"Search Results", nil);
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if([[_searchField text] length] > 0)
    {
        return [searchArray count];
    }else{
        return [[DataManager shared].historyConversationAsArray count];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MessagesCell";
        
    UILabel			*name;					// name of friend
    UILabel			*currentMessage;		// last message
    AsyncImageView			*photo;			// photo of opponent
	UILabel			*lastMessageDate;		// last message's date
    UIImageView		*replyArrow;			// reply arrow
	UIImageView		*onlineDot;				// online status
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        
        //create photo
        photo = [[AsyncImageView alloc] initWithFrame:CGRectMake(2, 2, 46, 46)];
        photo.tag = 1101;
        [cell.contentView addSubview:photo];
        [photo release];
        
        UITapGestureRecognizer *photoTap = [[UITapGestureRecognizer alloc] init];
        photoTap.numberOfTapsRequired = 1;
        [photoTap addTarget:self action:@selector(tapOnPhoto:)];
        [photo addGestureRecognizer:photoTap];
        [photoTap release];
        
        //create name of friend
        name = [[UILabel alloc] initWithFrame:CGRectMake(60, 2, 200, 20)];
        name.tag = 1102;
        [name setFont:[UIFont boldSystemFontOfSize:15]];
        [name setTextColor:[UIColor colorWithRed:0.172 green:0.278 blue:0.521 alpha:1]];
        [name setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:name];
        [name release];
        
        // create status
        currentMessage = [[UILabel alloc] init];
        currentMessage.tag = 1103;
        [currentMessage setFont:[UIFont systemFontOfSize:14]];
        [currentMessage setTextColor:[UIColor grayColor]];
        [currentMessage setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:currentMessage];
        [currentMessage release];
        
		// last message's date
		lastMessageDate = [[UILabel alloc] initWithFrame:CGRectMake(220, 7, 100, 13)];
		lastMessageDate.tag = 1104;
		[lastMessageDate setFont:[UIFont systemFontOfSize:12]];
		[lastMessageDate setTextColor:[UIColor grayColor]];
		[lastMessageDate setBackgroundColor:[UIColor clearColor]];
		[cell.contentView addSubview:lastMessageDate];
		[lastMessageDate release];
		
		// reply arrow
		replyArrow = [[UIImageView alloc] initWithFrame:CGRectMake(60, 27, 20, 16)];
		[replyArrow setImage:[UIImage imageNamed:@"grey_arrow.png"]];
		[replyArrow setHidden:YES];
		[replyArrow setTag:1105];
		[cell.contentView addSubview:replyArrow];
		[replyArrow release];
		
		// online status
		onlineDot = [[UIImageView alloc] initWithFrame:CGRectMake(264, 20, 12, 12)];
		[onlineDot setTag:1106];
		[cell.contentView addSubview:onlineDot];
		[onlineDot release];
    }else{
        photo = (AsyncImageView *)[cell.contentView viewWithTag:1101];
        name = (UILabel *)[cell.contentView viewWithTag:1102];
        currentMessage = (UILabel *)[cell.contentView viewWithTag:1103];
		lastMessageDate = (UILabel *)[cell.contentView viewWithTag:1104];
		replyArrow = (UIImageView*)[cell.contentView viewWithTag:1105];
		onlineDot = (UIImageView*)[cell.contentView viewWithTag:1106];
    }
    cell.contentView.tag = indexPath.row;
    
    // get conversation
    Conversation *conversation;
    //  search  mode
    if([[_searchField text] length] > 0) {
        conversation = [searchArray objectAtIndex:indexPath.row];
    }else{
        conversation = [[DataManager shared].historyConversationAsArray objectAtIndex:indexPath.row];
    }
	
	if ([[[[DataManager shared].myFriendsAsDictionary objectForKey:[conversation.to objectForKey:kId]] objectForKey:kOnOffStatus] intValue] == 0) // offline status
	{
		[onlineDot setImage:[UIImage imageNamed:@"offLine.png"]];
	}
	else // online
	{
		[onlineDot setImage:[UIImage imageNamed:@"onLine.png"]];
	}
	
    // set name & last message & photo
    currentMessage.text = [[conversation.messages lastObject] objectForKey:kMessage];
    name.text = [conversation.to objectForKey:kName];
    [photo loadImageFromURL:[NSURL URLWithString:[[[DataManager shared].myFriendsAsDictionary objectForKey:[conversation.to objectForKey:kId]] objectForKey:kPicture]]];
	
	if ([[[[conversation.messages lastObject] objectForKey:kFrom] objectForKey:kId] isEqualToString:[DataManager shared].currentFBUserId]) // last message is mine
	{
		[currentMessage setFrame:CGRectMake(90, 25, 170, 20)];
		
		[replyArrow setHidden:NO];
	}
	else 
	{
		[currentMessage setFrame:CGRectMake(60, 25, 200, 20)];
		
		[replyArrow setHidden:YES];
	}
	
	// set last message's date
	NSString* date = [[conversation.messages lastObject] objectForKey:@"created_time"];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setLocale:[NSLocale currentLocale]];
	[formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"];
	NSDate *timeStamp = [formatter dateFromString:date];
	[formatter release];
	
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setLocale:[NSLocale currentLocale]];
	NSString* dateVal;
    [dateFormat setDateFormat:@"d MMMM"];
	dateVal = [dateFormat stringFromDate:timeStamp];
	if ([timeStamp timeIntervalSinceNow] > -86400)
	{
		dateVal = NSLocalizedString(@"Today", nil);
	}
	else if (([timeStamp timeIntervalSinceNow] < -86400) && ([timeStamp timeIntervalSinceNow] > -172800))
	{
		dateVal = NSLocalizedString(@"Yesterday", nil);
	}
    [dateFormat release];
	
	lastMessageDate.text = dateVal;

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    // get conversation
    Conversation *conversation;
    //  search  mode
    if([[_searchField text] length] > 0) {
        conversation = [searchArray objectAtIndex:indexPath.row];
    }else{
        conversation = [[DataManager shared].historyConversationAsArray objectAtIndex:indexPath.row];
    }
    
    // set read state
    if(conversation.isUnRead){
        [cell setBackgroundColor:[UIColor colorWithRed:0.905 green:0.917 blue:0.945 alpha:1]];    
    } else {
        [cell setBackgroundColor:[UIColor whiteColor]];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Conversation *conversation;
    if([[_searchField text] length] > 0) {
        conversation = [searchArray objectAtIndex:indexPath.row];
    }else {
        conversation = [[DataManager shared].historyConversationAsArray objectAtIndex:indexPath.row];
    }
    
    
    // show chat
    FBChatViewController *chatController = [[FBChatViewController alloc] initWithNibName:@"FBChatViewController" bundle:nil];
    chatController.chatHistory = conversation;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController pushViewController:chatController animated:YES];
    [chatController release];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    [self tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)tapOnPhoto:(UITapGestureRecognizer *)gesture{
    NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:gesture.view.superview.tag inSection:0];
    [self tableView:_messageTableView didSelectRowAtIndexPath:cellIndexPath];
}


#pragma mark -
#pragma mark UISearchBarDelegate

- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar 
{
    
    // show back view
    if(backView == nil)
	{
        backView = [[ViewTouch alloc] initWithFrame:CGRectMake(0, 45, 320, 175) selector:@selector(touchOnView:) target:self];
        [self.view addSubview:backView];
        [backView release];
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [backView removeFromSuperview];
    backView = nil;
}

- (void)touchOnView:(UIView *)view
{
    [_searchField resignFirstResponder];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar
{
    [theSearchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText 
{
	//Remove all objects first.
	[searchArray removeAllObjects];
	
	if([searchText length] > 0) {
        // search friends
		[self searchTableView];
	}
    
	[_messageTableView reloadData];
}

- (void) searchTableView 
{
	NSString *searchText = _searchField.text;

	for (Conversation *conversation in [DataManager shared].historyConversationAsArray)
	{
        // patterns
        NSMutableArray *patterns = [[NSMutableArray alloc] init];
        [patterns addObject:[conversation.to objectForKey:kName]];
        for(NSDictionary *comment in conversation.messages){
            [patterns addObject:[[comment objectForKey:kFrom] objectForKey:kName]];
        }

	
        // add to searcj array
        for (NSString *pattern in patterns){
            NSRange titleResultsRange = [pattern rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if (titleResultsRange.length > 0) {
                [searchArray addObject:conversation];
                break;
            }    
        }
        
		[patterns release];
	}
}

- (void) backgroundMessageReceived:(NSNotification *)textMessage			
{
	// reload last message in table 
	[_messageTableView reloadData];
}

#pragma mark -
#pragma mark FBServiceResultDelegate

-(void)completedWithFBResult:(FBServiceResult *)result{

    // get inbox messages
    if (result.queryType == FBQueriesTypesGetInboxMessages){
        
        NSArray *resultData = [result.body objectForKey:kData];
        
        // each inbox message
		for(NSDictionary *inboxConversation in resultData)
		{
            if([inboxConversation objectForKey:kComments] == nil){
                continue;
            }
            
            // crop own id and name
            NSMutableArray *to = [[[[inboxConversation objectForKey:kTo] objectForKey:kData] mutableCopy] autorelease];
            
            // skip multiple conversations
            if ([to count] > 2){
                continue;
            }
            
            // remove self from 'To'
            for(int i = 0; i<[to count]; i++){
                if([[[to objectAtIndex:i] objectForKey:kId] isEqualToString:[DataManager shared].currentFBUserId]){
                    [to removeObject:[to objectAtIndex:i]];
                }
            }
            if([to count] == 0){
                continue;
            }
            
            // create and add conversation
            Conversation *conersation = [[Conversation alloc] init];
            conersation.to = [to objectAtIndex:0];
            
            // add comments
            if([inboxConversation objectForKey:kComments]){
                conersation.messages = [[[[inboxConversation objectForKey:kComments] objectForKey:kData] mutableCopy] autorelease];
            }else{
                NSMutableArray *emptryArray = [[NSMutableArray alloc] init];
                conersation.messages = emptryArray;
                [emptryArray release];
            }
            
            // save to cache
            [[DataManager shared].historyConversation setObject:conersation forKey:[conersation.to objectForKey:kId]];
            [DataManager shared].historyConversationAsArray = [[[[DataManager shared].historyConversation allValues] mutableCopy] autorelease];
            [conersation release];
		}
        
        
        // get friends
        [[FBService shared] friendsGetWithDelegate:self];
        
    // get friends
    }else if (result.queryType ==FBQueriesTypesFriendsGet){
		// save friends
		[DataManager shared].myFriends = [result.body objectForKey:kData];
		
        // add online/offline & favs keys
		for(int i=0; i<[[DataManager shared].myFriends count]; i++){
			[[[DataManager shared].myFriends objectAtIndex:i] setObject:kOffline forKey:kOnOffStatus];
			[[[DataManager shared].myFriends objectAtIndex:i] setObject:[NSNumber numberWithBool:NO] forKey:kFavorites];
		}
        
        // make friends as dictionary
        [[DataManager shared] makeFriendsDictionary];
        
        // show messages
        [self showInboxMessages];
	}
}


#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[HUD removeFromSuperview];
	[HUD release];
	HUD = nil;
}


@end
