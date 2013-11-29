//
//  ChatViewController.m
//  ChattAR
//
//  Created by Igor Alefirenko on 28/08/2013.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import "SASlideMenuRootViewController.h"
#import "ChatViewController.h"
#import "TrendingChatRoomsDataSource.h"
#import "LocalChatRoomsDataSource.h"
#import "FBService.h"
#import "FBStorage.h"
#import "ChatRoomStorage.h"
#import "LocationService.h"
#import "Utilites.h"
#import "ChatRoomViewController.h"


@interface ChatViewController () <UITableViewDataSource, UITableViewDelegate, QBActionStatusDelegate, QBChatDelegate, UIAlertViewDelegate, NMPaginatorDelegate, UIScrollViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) IBOutlet UITableView *trendingTableView;
@property (strong, nonatomic) IBOutlet UITableView *locationTableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic, strong) NSArray *trendings;
@property (nonatomic, strong) NSMutableArray *locals;

@property (nonatomic, strong) TrendingChatRoomsDataSource *trendingDataSource;
@property (nonatomic, strong) LocalChatRoomsDataSource *locationDataSource;

@property (nonatomic, strong) UIActivityIndicatorView *trendingActivityIndicator;
@property (nonatomic, strong) UILabel *trendingFooterLabel;

@end

@implementation ChatViewController


#pragma mark - 
#pragma mark LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchForResults) name:CAChatDidReceiveSearchResults object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadRooms) name:kNotificationDidLogin object:nil];
    
    _trendings = [[NSArray alloc] initWithArray:[[ChatRoomStorage shared] allTrendingRooms]];
    _locals = [[NSMutableArray alloc] initWithArray:[[ChatRoomStorage shared] allLocalRooms]];
    
    _trendingTableView.tag = kTrendingTableViewTag;
    _locationTableView.tag = kLocalTableViewTag;
    
    
    if(_trendings.count > 0){
        self.trendingDataSource.chatRooms = _trendings;
    }
    if(_locals.count > 0){
        self.locationDataSource.chatRooms = [[ChatRoomStorage shared] allLocalRooms];
        self.locationDataSource.distances = [[ChatRoomStorage shared] distances];
    }
    
    self.trendingTableView.dataSource = self.trendingDataSource;
    self.locationTableView.dataSource = self.locationDataSource;
    
    self.trendingTableView.delegate = self;
    self.locationTableView.delegate = self;
    
    // paginator:
    self.trendingPaginator = [[ChatRoomsPaginator alloc] initWithPageSize:10 delegate:self];
    self.trendingPaginator.tag = kTrendingPaginatorTag;
    self.trendingTableView.tableFooterView = [self creatingTrendingFooter];
    if(_trendings.count > 0 ){
        if (![[ChatRoomStorage shared] endOfList]) {
            [self.trendingPaginator setPageTo:[_trendings count]/10];
            self.trendingFooterLabel.text = [NSString stringWithFormat:@"Load more..."];
            [self.trendingFooterLabel setNeedsDisplay];
        } else {
            self.trendingTableView.tableFooterView = nil;
        }
    }
    
    // if iPhone 5
    self.scrollView.pagingEnabled = YES;
    if(IS_HEIGHT_GTE_568){
        self.scrollView.contentSize = CGSizeMake(500, 504);
    } else {
        self.scrollView.contentSize = CGSizeMake(500, 416);
    }
    // hard code
    if (![[Utilites shared] isUserLoggedIn]) {
        [self performSegueWithIdentifier:@"Splash" sender:self];
        [[Utilites shared] setUserLogIn];
    }
    [self configureSearchIndicatorView];
}

- (void)configureSearchIndicatorView
{
    if (!self.searchIndicatorView) {
        self.searchIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.searchIndicatorView.frame = CGRectMake(self.view.frame.size.width/2 - 10, self.view.frame.size.height/2 -10, 20 , 20);
        [self.searchIndicatorView hidesWhenStopped];
        [self.view addSubview:self.searchIndicatorView];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.trendingTableView reloadData];
    [self.locationTableView reloadData];
}

- (void)loadLocalRooms {
    [QBCustomObjects objectsWithClassName:kChatRoom delegate:self];
}


#pragma mark -
#pragma mark Notifications

- (void)loadRooms {
    [[NSNotificationCenter defaultCenter]  removeObserver:self name:kNotificationDidLogin object:nil];
    
    if ([_trendings count] == 0) {
        [self.trendingPaginator fetchFirstPage];
    }
    if ([[ChatRoomStorage shared] allLocalRooms] == nil) {
        [self loadLocalRooms];
    }else {
        _locationDataSource.chatRooms = [[ChatRoomStorage shared] allLocalRooms];
        _locationDataSource.distances = [self arrayOfDistances:[[ChatRoomStorage shared] allLocalRooms]];
    }
}

- (void)searchForResults {
    self.trendings = [ChatRoomStorage shared].searchedRooms;
    self.trendingDataSource.chatRooms = [ChatRoomStorage shared].searchedRooms;
    [self.trendingTableView reloadData];
    self.trendingFooterLabel.text = nil;
    [self.searchIndicatorView stopAnimating];
}

#pragma mark -
#pragma mark QBActionStatusDelegate

- (void)completedWithResult:(Result *)result {
    if ([result success]) {
        if ([result isKindOfClass:[QBCOCustomObjectPagedResult class]]) {
            // todo:
            QBCOCustomObjectPagedResult *pagedResult = (QBCOCustomObjectPagedResult *)result;
            _locals = [[ChatRoomStorage shared] sortingRoomsByDistance:[LocationService shared].myLocation toChatRooms:pagedResult.objects];
            [[ChatRoomStorage shared] setAllLocalRooms:_locals];
            _locationDataSource.chatRooms = _locals;
            _locationDataSource.distances = [self arrayOfDistances:_locals];
            [[ChatRoomStorage shared] setDistances:[self arrayOfDistances:[[ChatRoomStorage shared] allLocalRooms]]];
            [self.locationTableView reloadData];
        }
    }
}

#pragma mark - Paginator

- (void)fetchNextPage:(ChatRoomsPaginator *)paginator
{
    [paginator fetchNextPage];
    if (paginator.tag == kTrendingPaginatorTag) {
        [self.trendingActivityIndicator startAnimating];
    }
}

- (void)updateTableViewFooterWithPaginator:(ChatRoomsPaginator *)paginator
{
    if ([paginator.results count] != 0)
    {
        if (paginator.tag == kTrendingPaginatorTag) {
            self.trendingFooterLabel.text = [NSString stringWithFormat:@"Load more..."];
            [self.trendingFooterLabel setNeedsDisplay];
        }
    }
}

- (UIView *)creatingTrendingFooter {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _trendingTableView.frame.size.width, 44.0f)];
    footerView.backgroundColor = [UIColor clearColor];
    _trendingFooterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _trendingTableView.frame.size.width, 44.0f)];
    _trendingFooterLabel.backgroundColor = [UIColor clearColor];
    _trendingFooterLabel.textAlignment = UITextAlignmentCenter;
    _trendingFooterLabel.textColor = [UIColor lightGrayColor];
    _trendingFooterLabel.font = [UIFont systemFontOfSize:16];
    [footerView addSubview:_trendingFooterLabel];
    
    self.trendingActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.trendingActivityIndicator.center = CGPointMake(40.0, 22.0);
    self.trendingActivityIndicator.hidesWhenStopped = YES;
    [footerView addSubview:self.trendingActivityIndicator];
    return footerView;
}


#pragma mark - 
#pragma mark ScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (self.trendingTableView.tableFooterView  != nil) {
        if (scrollView.contentOffset.y == (scrollView.contentSize.height - scrollView.bounds.size.height))
        {
            if (scrollView.tag == kTrendingTableViewTag) {
                // ask next page only if we haven't reached last page
                if(![self.trendingPaginator reachedLastPage])
                {
                    // fetch next page of results
                    [self fetchNextPage:self.trendingPaginator];
                }
            }
        }
    }
}


#pragma mark -
#pragma mark NMPaginatorDelegate

- (void)paginator:(id)paginator didReceiveResults:(NSArray *)results
{
    if(results.count != 10){
        self.trendingTableView.tableFooterView  = nil;
        [[ChatRoomStorage shared] setEndOfList:YES];
        //return;
    }
    // handle new results
        _trendings = [_trendings arrayByAddingObjectsFromArray:results];
        _trendingDataSource.chatRooms = _trendings;
        [[ChatRoomStorage shared] setAllTrendingRooms:_trendings];
        [self.trendingActivityIndicator stopAnimating];
    
    [self updateTableViewFooterWithPaginator:paginator];
    //reload table
    [self.trendingTableView reloadData];
}

- (void)paginatorDidReset:(id)paginator
{
    [self.trendingTableView reloadData];
    [self.locationTableView reloadData];
    [self updateTableViewFooterWithPaginator:paginator];
}


#pragma mark -
#pragma mark Data Sources


- (TrendingChatRoomsDataSource *)trendingDataSource {
    if (!_trendingDataSource){
        _trendingDataSource = [TrendingChatRoomsDataSource new];
    }
    return _trendingDataSource;
}

- (LocalChatRoomsDataSource *)locationDataSource {
    if (!_locationDataSource){
        _locationDataSource = [LocalChatRoomsDataSource new];
    }
    return _locationDataSource;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kChatToChatRoomSegueIdentifier]){
        // passcurrent room to Chat Room controller
        ((ChatRoomViewController *)segue.destinationViewController).currentChatRoom = sender;
    }
}


#pragma mark -
#pragma mark Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.searchBar resignFirstResponder];
    [self.searchBar setShowsCancelButton:NO animated:NO];
    // get current chat room
    QBCOCustomObject *currentRoom;
    if (tableView.tag == kTrendingTableViewTag) {
       currentRoom =  [_trendings objectAtIndex:[indexPath row]];
    
    }else if (tableView.tag == kLocalTableViewTag) {
       currentRoom = [[[ChatRoomStorage shared] allLocalRooms] objectAtIndex:[indexPath row]];
    }
    
    // Open CHat Controller
    [self performSegueWithIdentifier:kChatToChatRoomSegueIdentifier sender:currentRoom];
}


#pragma mark -
#pragma mark Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NewIdentifier"];
    return cell;
}


#pragma mark - 
#pragma mark Actions

- (IBAction)createChatRoom:(id)sender {
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Creating room" message:@"Name of Room:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create", nil];
//    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
//    [alert show];
    
    [self performSegueWithIdentifier:kCreateChatRoomIdentifier sender:nil];
}

- (NSArray *)getNamesOfRooms:(NSArray *)rooms {
    NSMutableArray *names = [[NSMutableArray alloc] init];
    for (int i=0; i<[rooms count]; i++) {
        QBCOCustomObject *object = [rooms objectAtIndex:i];
        [names addObject:[object.fields objectForKey:kName]];
    }
    return names;
}


#pragma mark - 
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 1:
            if (![[[alertView textFieldAtIndex:0] text] isEqual:@""]) {
                NSString *alertText = [[alertView textFieldAtIndex:0] text];
                NSString *myLatitude = [[NSString alloc] initWithFormat:@"%f",[[LocationService shared] getMyCoorinates].latitude];
                NSString *myLongitude = [[NSString alloc] initWithFormat:@"%f", [[LocationService shared] getMyCoorinates].longitude];

                QBCOCustomObject *object = [QBCOCustomObject customObject];
                object.className = kChatRoom;
                [object.fields setObject:myLatitude forKey:kLatitude];
                [object.fields setObject:myLongitude forKey:kLongitude];
                [object.fields setObject:alertText forKey:kName];
                [object.fields setObject:[NSNumber numberWithInt:0] forKey:kRank];
                [QBCustomObjects createObject:object delegate:self];
                [_locals insertObject:object atIndex:0];
                _locals = [[ChatRoomStorage shared] sortingRoomsByDistance:[LocationService shared].myLocation toChatRooms:_locals];
                [[ChatRoomStorage shared] setAllLocalRooms:_locals];
                [[ChatRoomStorage shared].distances insertObject:[NSNumber numberWithInt:[self distanceFromNewRoom:object]] atIndex:0];
                
                // put to datasource
                _locationDataSource.chatRooms = [[ChatRoomStorage shared] allLocalRooms];
                _locationDataSource.distances = [[ChatRoomStorage shared] distances];
                
                [self performSegueWithIdentifier:kChatToChatRoomSegueIdentifier sender:object];
                
            }
            break;
            
        default:
            break;
    }
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    return YES;
}


// distances for local rooms
- (NSMutableArray *)arrayOfDistances:(NSArray *)objects {
    NSMutableArray *chatRoomDistances = [NSMutableArray array];
    for (QBCOCustomObject *object in objects) {
        CLLocation *room = [[CLLocation alloc] initWithLatitude:[[[object fields] objectForKey:kLatitude] doubleValue] longitude:[[[object fields] objectForKey:kLongitude] doubleValue]];
        NSInteger distance = [[LocationService shared].myLocation distanceFromLocation:room];
        [chatRoomDistances addObject:[NSNumber numberWithInt:distance]];
    }
    return chatRoomDistances;
}

- (NSInteger)distanceFromNewRoom:(QBCOCustomObject *)room {
    CLLocation *newRoom = [[CLLocation alloc] initWithLatitude:[[[room fields] objectForKey:kLatitude] doubleValue] longitude:[[[room fields] objectForKey:kLongitude] doubleValue]];
    NSInteger distance = [[LocationService shared].myLocation distanceFromLocation:newRoom];
    return distance;
}


#pragma mark -
#pragma mark UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    ChatRoomStorage *chatRoomService = [ChatRoomStorage shared];
    // called when keyboard search button pressed
    NSMutableDictionary *extendedRequest = [[NSMutableDictionary alloc] init];
    [extendedRequest setObject:self.searchBar.text forKey:@"name[ctn]"];
    [QBCustomObjects objectsWithClassName:kChatRoom extendedRequest:extendedRequest delegate:chatRoomService];
    [searchBar resignFirstResponder];
    [self.searchIndicatorView startAnimating];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText isEqualToString:@""]) {
        self.trendings = [ChatRoomStorage shared].allTrendingRooms;
        self.trendingDataSource.chatRooms = _trendings;
        [self.trendingTableView reloadData];
        self.trendingFooterLabel.text = [NSString stringWithFormat:@"Load more..."];
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar{
    self.trendings = [ChatRoomStorage shared].allTrendingRooms;
    self.trendingDataSource.chatRooms = _trendings;
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    self.trendingFooterLabel.text = @"Load more...";
    [self.trendingTableView reloadData];
}

@end
