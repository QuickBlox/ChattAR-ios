     

//
//  ContactsController.m
//  FB_Radar
//
//  Created by md314 on 3/10/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "ContactsController.h"
#import "MessagesViewController.h"
#import "FBChatViewController.h"
#import "AsyncImageView.h"

#define kFavoritiesFriends [NSString stringWithFormat:@"kFavoritiesFriends_%@", [DataManager shared].currentFBUserId]

@interface ContactsController ()

@end

@implementation ContactsController

@synthesize friendListTableView = _friendListTableView;
@synthesize searchField = _searchField;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
	{
        self.title = NSLocalizedString(@"Friends", nil);
		self.tabBarItem.image = [UIImage imageNamed:@"DockContacts.png"];
        
        searchArray = [[NSMutableArray alloc] init];
        
        onlineFriends = [[NSMutableArray alloc] init];
        offlineFriends = [[NSMutableArray alloc] init];
        favoriteFriends = [[NSMutableArray alloc] init];
        
        isInitialized = NO;
        
        // logout
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutDone) name:kNotificationLogout object:nil];

    }
    return self;
}

-(void)dealloc
{
	[searchArray release];
    [onlineFriends release];
	[offlineFriends release];
	[favoriteFriends release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationLogout object:nil];
	
	[super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusMessageReceived:)
												 name:kReceivedOnlineStatus object:nil];
	
	[_searchField setFrame:CGRectMake(0, 0, 320, 44)];
	[_friendListTableView setFrame:CGRectMake(0, 44, 320, 420)];   
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(!isInitialized && [DataManager shared].currentFBUser){
        isInitialized = YES;

        // show friends
        [self showFriends];
    }
}

- (void)viewDidUnload
{
	self.friendListTableView = nil;
    self.searchField = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
													name:kReceivedOnlineStatus 
												  object:nil];
  
	// Release any retained subviews of the main view.
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)logoutDone{
    isInitialized = NO;
}

- (void)touchOnView:(UIView *)view
{
    [_searchField resignFirstResponder];
}

- (void)showFriends{
    // we dont have any friends
    if([[DataManager shared].myFriends count] == 0)
	{
        return;
    }
    
	//refresh friends
    if([_searchField.text length] == 0){
        [searchArray removeAllObjects];
    }
    
	[offlineFriends removeAllObjects];
	[onlineFriends removeAllObjects];
	[favoriteFriends removeAllObjects];
    

    // set favs
    for(NSString *favFriendId in [[DataManager shared] favoritiesFriends]){
        NSMutableDictionary *favFriend = [[DataManager shared].myFriendsAsDictionary objectForKey:favFriendId];
        [favFriend setObject:[NSNumber numberWithBool:YES] forKey:kFavorites];
        
        // online
        if([[favFriend objectForKey:kOnOffStatus] intValue] == 1){
            [favoriteFriends insertObject:favFriend atIndex:0]; 
        }else{
            [favoriteFriends addObject:favFriend];
        }
    }
	
	// set online/offline
	for (int i = 0; i < [[DataManager shared].myFriends count]; i++){
        
        NSDictionary *friend = [[DataManager shared].myFriends objectAtIndex:i];
        
        // if friend in favs - continue
        if([favoriteFriends containsObject:friend]){
            continue;
        }
        
		if ([[friend objectForKey:kFavorites] boolValue] == NO){
            if ([[friend objectForKey:kOnOffStatus] intValue] == 1){
                [onlineFriends addObject:friend];
            }else{
                [offlineFriends addObject:friend];
            }
        }
	}
	
    // reload table
    [_friendListTableView reloadData];
}


#pragma mark -
#pragma mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	if ([[_searchField text] length] > 0)
	{
		return 1;
	}

    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{    
	if ([[_searchField text] length] > 0)
	{
		return NSLocalizedString(@"Search Results", nil);
	}
	
	switch (section)
	{
		case 0:
		{
			return NSLocalizedString(@"Favorites", nil);
		}
		case 1:
		{
			return NSLocalizedString(@"Online ", nil);
			
		}
		case 2:
		{
			return NSLocalizedString(@"Offline", nil);
		}
	}
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	if ([[_searchField text] length] > 0)
	{
		return [searchArray count];
	}
	else if (section == 0) 
	{
		return [favoriteFriends count];
	}
	else if (section == 1)
	{
		return [onlineFriends count];
	}
	else if (section == 2)
	{
		return [offlineFriends count];
	}
    
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	
	NSMutableArray	*tableData = nil;
	
	// searching
	if([[_searchField text] length] > 0) 
	{
		tableData = searchArray;
		
	}else {	
		if (indexPath.section == 0)
		{
			tableData = favoriteFriends;
		}
		else if (indexPath.section == 1)
		{
			tableData = onlineFriends;
		}
		else if (indexPath.section == 2)
		{
			tableData = offlineFriends;
		}
	}
	
	UILabel			*name;
	UILabel			*currentStatus;
	AsyncImageView	*photo;
	UIImageView			*onlineBadge;
	UIButton		*favorites;
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) 
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		[cell setBackgroundColor:[UIColor clearColor]];
		
		// create photo
		photo = [[AsyncImageView alloc] initWithFrame:CGRectMake(2, 2, 39, 39)];
		photo.tag = 1101;
		[cell.contentView addSubview:photo];
		[photo release];
		
        
        UITapGestureRecognizer *photoTap = [[UITapGestureRecognizer alloc] init];
        photoTap.numberOfTapsRequired = 1;
        [photoTap addTarget:self action:@selector(tapOnPhoto:)];
        [photo addGestureRecognizer:photoTap];
        [photoTap release];

        
		// create name of friend
		name = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, 200, 20)];
		name.tag = 1102;
		[name setFont:[UIFont systemFontOfSize:15]];
		[name setTextColor:[UIColor darkGrayColor]];
		[name setBackgroundColor:[UIColor clearColor]];
		[cell.contentView addSubview:name];
		[name release];
		
		// create status
		currentStatus = [[UILabel alloc] initWithFrame:CGRectMake(60, 20, 200, 20)];
		currentStatus.tag = 1103;
		[currentStatus setFont:[UIFont systemFontOfSize:12]];
		[currentStatus setTextColor:[UIColor darkGrayColor]];
		[currentStatus setBackgroundColor:[UIColor clearColor]];
		[cell.contentView addSubview:currentStatus];
		[currentStatus release];
		
		// create online badge
		onlineBadge = [[UIImageView alloc] initWithFrame:CGRectMake(255, 18, 9, 9)];
		onlineBadge.tag = 1104;
		[onlineBadge setBackgroundColor:[UIColor clearColor]];
		[cell.contentView addSubview:onlineBadge];
		[onlineBadge release];	
		
		// create favorites
		favorites = [UIButton buttonWithType:UIButtonTypeCustom];
		[favorites addTarget:self action:@selector(addFavoriteFriend:) forControlEvents:UIControlEventTouchDown];
		[favorites setFrame:CGRectMake(280, 5, 30, 30)];
		favorites.backgroundColor = [UIColor clearColor];
		UIImage *backImageUnFav = [UIImage imageNamed:@"GrayStar.png"];
		[favorites setBackgroundImage:backImageUnFav forState:UIControlStateNormal];
		[favorites setBackgroundImage:[UIImage imageNamed:@"YellowStar.png"] forState:UIControlStateSelected];
		favorites.tag = 1105;
		[cell.contentView addSubview:favorites];
	}
	else
	{
		photo = (AsyncImageView *)[cell.contentView viewWithTag:1101];
		name = (UILabel *)[cell.contentView viewWithTag:1102];
		currentStatus = (UILabel *)[cell.contentView viewWithTag:1103];
		onlineBadge = (UIImageView *)[cell.contentView viewWithTag:1104];
		favorites = (UIButton *)[cell.contentView viewWithTag:1105];
	}
	
	cell.contentView.tag = indexPath.row; // store row
	cell.tag = indexPath.section; // store section
	
	id picture = [[tableData objectAtIndex:indexPath.row] objectForKey:kPicture];
	if ([picture isKindOfClass:[NSString class]])
	{
		[photo loadImageFromURL:[NSURL URLWithString:[[tableData objectAtIndex:indexPath.row] objectForKey:kPicture]]];
	}
	else
	{
		NSDictionary* pic = (NSDictionary*)picture;
		NSString* url = [[pic objectForKey:kData] objectForKey:kUrl];
		[photo loadImageFromURL:[NSURL URLWithString:url]];
		[[tableData objectAtIndex:indexPath.row] setObject:url forKey:kPicture];
	}
	
	name.text = [[tableData objectAtIndex:indexPath.row] objectForKey:kName];
	currentStatus.text = [[[[[tableData objectAtIndex:indexPath.row] objectForKey:kStatuses] objectForKey:kData] objectAtIndex:0] objectForKey:kMessage];
    
    int isOnline = [[[tableData objectAtIndex:indexPath.row] objectForKey:kOnOffStatus] intValue];
	onlineBadge.image = isOnline == 1 ? [UIImage imageNamed:@"onLine.png"] : [UIImage imageNamed:@"offLine.png"];
	
    
	if([[[tableData objectAtIndex:indexPath.row] objectForKey:kFavorites] boolValue] == YES)
	{
		[favorites setSelected:YES];
	}
	else 
	{
		[favorites setSelected:NO];
	}
			
	return cell;
	
}

- (void)tapOnPhoto:(UITapGestureRecognizer *)gesture{
    NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:gesture.view.superview.tag inSection:gesture.view.superview.superview.tag];
    [self tableView:_friendListTableView didSelectRowAtIndexPath:cellIndexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *selectedFriend;
    
	if ([[_searchField text] length] > 0){
		selectedFriend = [searchArray objectAtIndex:indexPath.row];
    }else{
		if (indexPath.section == 0)
        {
			selectedFriend = [favoriteFriends objectAtIndex:indexPath.row];
		}
		else if (indexPath.section == 1)
		{
			selectedFriend = [onlineFriends objectAtIndex:indexPath.row];
		}
		else
		{
			selectedFriend = [offlineFriends objectAtIndex:indexPath.row];
		}
	}
	
    
    NSString *selectedFriendId = [selectedFriend objectForKey:kId];

    // get conversation
    Conversation *conversation = [[DataManager shared].historyConversation objectForKey:selectedFriendId];
    if(conversation == nil){
        // 1st message -> create conversation
        
        Conversation *newConversation = [[Conversation alloc] init];
        
        // add to
        NSMutableDictionary *to = [NSMutableDictionary dictionary];
        [to setObject:selectedFriendId forKey:kId];
        [to setObject:[selectedFriend objectForKey:kName] forKey:kName];
        newConversation.to = to;
        
        // add messages
        NSMutableArray *emptryArray = [[NSMutableArray alloc] init];
        newConversation.messages = emptryArray;
        [emptryArray release];
        
        [[DataManager shared].historyConversation setObject:newConversation forKey:selectedFriendId];
        [newConversation release];
        
        conversation = newConversation;
    }
    
    [DataManager shared].historyConversationAsArray = [[[[DataManager shared].historyConversation allValues] mutableCopy] autorelease];
	
    // show Chat
    FBChatViewController *chatController = [[FBChatViewController alloc] initWithNibName:@"FBChatViewController" bundle:nil];
	chatController.chatHistory = conversation;
	[self.navigationController pushViewController:chatController animated:YES];
	[chatController release];
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
    
	[_friendListTableView reloadData];
}

- (void) searchTableView 
{
	NSString *searchText = _searchField.text;
	
	for (NSDictionary *dict in [DataManager shared].myFriends)
	{
		
        NSMutableArray *patterns = [[NSMutableArray alloc] init];
		[patterns addObject:[dict objectForKey:kFirstName]];
		[patterns addObject:[dict objectForKey:kLastName]];
        
        for (NSString *sTemp in patterns)
		{
            NSRange titleResultsRange = [sTemp rangeOfString:searchText options:NSCaseInsensitiveSearch];
            
            if (titleResultsRange.length > 0) 
			{
                [searchArray addObject:dict];
                break;
            }    
        }
        
        [patterns release];
	}
}


#pragma mark -
#pragma mark Statuses

- (void) statusMessageReceived:(NSNotification *)textMessage			
{
    [self showFriends];
}


#pragma mark -
#pragma mark Favorites

-(void) addFavoriteFriend:(UIButton *)sender
{
	int row = [sender superview].tag;
	int section= [[sender superview] superview].tag;

    NSMutableArray *onOffFriends = nil;
    if ([[_searchField text] length] > 0){
        onOffFriends = searchArray;
    }else{
        if(section == 0){
            onOffFriends = favoriteFriends;
        }else if(section == 1){
            onOffFriends = onlineFriends;
        }else if (section == 2){
            onOffFriends = offlineFriends;
        }
    }
    NSMutableDictionary *friend = [onOffFriends objectAtIndex:row];
    NSString *friendID = [friend objectForKey:kId];
    
    BOOL isAddedToFavs = NO;
    if([[DataManager shared] friendIDInFavorities:friendID]){
        // remove
        [friend setObject:[NSNumber numberWithBool:NO] forKey:kFavorites];
        [[DataManager shared] removeFavoriteFriend:friendID];
    }else{
        // add
        [friend setObject:[NSNumber numberWithBool:YES] forKey:kFavorites];
        [[DataManager shared] addFavoriteFriend:friendID];
        
        isAddedToFavs = YES;
    }

    
    
    if ([[_searchField text] length] > 0){
        if(isAddedToFavs){
            [favoriteFriends addObject:friend];
            
            [searchArray removeObject:friend];
            if([[friend objectForKey:kOnOffStatus] intValue] == 1){
                [onlineFriends removeObject:friend];
            }else{
                [offlineFriends removeObject:friend];
            }
        }else{
            [favoriteFriends removeObject:friend];
            
            [searchArray removeObject:friend];
            if([[friend objectForKey:kOnOffStatus] intValue] == 1){
                [onlineFriends addObject:friend];
            }else{
                [offlineFriends addObject:friend];
            }
        }
        
        // reload table
        [_friendListTableView reloadData];
    }else{
        // refresh table
        [self showFriends];
    }
}

@end
