//
//  ChatViewController.m
//  ChattAR
//
//  Created by Igor Alefirenko on 28/08/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//
#import "SASlideMenuRootViewController.h"
#import "ChatViewController.h"
#import "TrendingChatRoomsDataSource.h"
#import "LocalChatRoomsDataSource.h"
#import "FBService.h"
#import "FBStorage.h"
#import "ChatRoomsService.h"
#import "LocationService.h"
#import "Utilites.h"
#import "ChatRoomViewController.h"


@interface ChatViewController ()
@property (nonatomic, strong) IBOutlet UITableView *trendingTableView;
@property (strong, nonatomic) IBOutlet UITableView *locationTableView;

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
    
    _trendings = [[NSArray alloc] initWithArray:[[ChatRoomsService shared] allTrendingRooms]];
    _locals = [[NSMutableArray alloc] initWithArray:[[ChatRoomsService shared] allLocalRooms]];
    
    _trendingTableView.tag = kTrendingTableViewTag;
    _locationTableView.tag = kLocalTableViewTag;
    
    
    if(_trendings.count > 0){
        self.trendingDataSource.chatRooms = _trendings;
    }
    if(_locals.count > 0){
        self.locationDataSource.chatRooms = [[ChatRoomsService shared] allLocalRooms];
        self.locationDataSource.distances = [[ChatRoomsService shared] distances];
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
        if (![[ChatRoomsService shared] endOfList]) {
            [self.trendingPaginator setPageTo:[_trendings count]/10];
            self.trendingFooterLabel.text = [NSString stringWithFormat:@"%d results out of all", [_trendings count]];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadRooms) name:kNotificationDidLogin object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [self.trendingTableView reloadData];
    [self.locationTableView reloadData];
}

- (void)loadRooms{
    [[NSNotificationCenter defaultCenter]  removeObserver:self];
    
    if ([_trendings count] == 0) {
        [self.trendingPaginator fetchFirstPage];
    }
    if ([[ChatRoomsService shared] allLocalRooms] == nil) {
        [self loadLocalRooms];
    }else {
        _locationDataSource.chatRooms = [[ChatRoomsService shared] allLocalRooms];
        _locationDataSource.distances = [self arrayOfDistances:[[ChatRoomsService shared] allLocalRooms]];
    }
}

-(void)loadLocalRooms{
    [QBCustomObjects objectsWithClassName:kChatRoom delegate:self];
}


#pragma marak -
#pragma mark QBActionStatusDelegate

-(void)completedWithResult:(Result *)result{
    if ([result success]) {
        if ([result isKindOfClass:[QBCOCustomObjectPagedResult class]]) {
            // todo:
            QBCOCustomObjectPagedResult *pagedResult = (QBCOCustomObjectPagedResult *)result;
            _locals = [self sortingRoomsByDistance:[LocationService shared].myLocation toChatRooms:pagedResult.objects];
            [[ChatRoomsService shared] setAllLocalRooms:_locals];
            _locationDataSource.chatRooms = _locals;
            _locationDataSource.distances = [self arrayOfDistances:_locals];
            [[ChatRoomsService shared] setDistances:[self arrayOfDistances:[[ChatRoomsService shared] allLocalRooms]]];
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
            self.trendingFooterLabel.text = [NSString stringWithFormat:@"%d results out of all", [paginator.results count]];
            [self.trendingFooterLabel setNeedsDisplay];
        }
    }
}

-(UIView *)creatingTrendingFooter {
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
        [[ChatRoomsService shared] setEndOfList:YES];
        //return;
    }
    // handle new results
        _trendings = [_trendings arrayByAddingObjectsFromArray:results];
        _trendingDataSource.chatRooms = _trendings;
        [[ChatRoomsService shared] setAllTrendingRooms:_trendings];
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


- (TrendingChatRoomsDataSource *)trendingDataSource
{
    if (!_trendingDataSource)
    {
        _trendingDataSource = [TrendingChatRoomsDataSource new];
    }
    
    return _trendingDataSource;
}

- (LocalChatRoomsDataSource *)locationDataSource
{
    if (!_locationDataSource)
    {
        _locationDataSource = [LocalChatRoomsDataSource new];
    }
    
    return _locationDataSource;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"kSegueToChatRoomController"]){
        // passcurrent room to Chat Room controller
        ((ChatRoomViewController *)segue.destinationViewController).currentChatRoom = sender;
        //[segue.sourceViewController pushViewController:segue.destinationViewController animated:YES];
    }
}


#pragma mark -
#pragma mark Table View Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
 
    // get current chat room
    QBCOCustomObject *currentRoom;
    if (tableView.tag == kTrendingTableViewTag) {
       currentRoom =  [_trendings objectAtIndex:[indexPath row]];
    
    }else if (tableView.tag == kLocalTableViewTag) {
       currentRoom = [[[ChatRoomsService shared] allLocalRooms] objectAtIndex:[indexPath row]];
    }
    
    // Open CHat Controller
    [self performSegueWithIdentifier:@"kSegueToChatRoomController" sender:currentRoom];
}


#pragma mark - 
#pragma mark Actions

- (IBAction)createChatRoom:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Creating room" message:@"Name of Room:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

-(NSArray *)getNamesOfRooms:(NSArray *)rooms{
    NSMutableArray *names = [[NSMutableArray alloc] init];
    for (int i=0; i<[rooms count]; i++) {
        QBCOCustomObject *object = [rooms objectAtIndex:i];
        [names addObject:[object.fields objectForKey:kName]];
    }
    return names;
}


#pragma mark - 
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 1:
            if (![[[alertView textFieldAtIndex:0] text] isEqual:@""]) {
                NSString *alertText = [[alertView textFieldAtIndex:0] text];
//                [FBService shared].roomName = alertText;

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
                _locals = [self sortingRoomsByDistance:[LocationService shared].myLocation toChatRooms:_locals];
                [[ChatRoomsService shared] setAllLocalRooms:_locals];
                [[ChatRoomsService shared].distances insertObject:[NSNumber numberWithInt:[self distanceFromNewRoom:object]] atIndex:0];
                
                // put to datasource
                _locationDataSource.chatRooms = [[ChatRoomsService shared] allLocalRooms];
                _locationDataSource.distances = [[ChatRoomsService shared] distances];
                
                [self performSegueWithIdentifier:@"kSegueToChatRoomController" sender:object];
                
            }
            break;
            
        default:
            break;
    }
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView{
    return YES;
}


#pragma mark - Sort

-(NSMutableArray *)sortingRoomsByDistance:(CLLocation *)me toChatRooms:(NSArray *)rooms{
    NSArray *sortedRooms = [rooms sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        CLLocation *room1 = [[CLLocation alloc] initWithLatitude:[[[obj1 fields] objectForKey:kLatitude] doubleValue] longitude:[[[obj1 fields] objectForKey:kLongitude] doubleValue]];
        CLLocation *room2 = [[CLLocation alloc] initWithLatitude:[[[obj2 fields] objectForKey:kLatitude] doubleValue] longitude:[[[obj2 fields] objectForKey:kLongitude] doubleValue]];
        NSInteger distance1 = [me distanceFromLocation:room1];
        NSInteger distance2 = [me distanceFromLocation:room2];
        
        if ( distance1 < distance2) {
            return (NSComparisonResult)NSOrderedAscending;
        } else if ( distance1 > distance2) {
            return (NSComparisonResult)NSOrderedDescending;
        } else {
            return (NSComparisonResult)NSOrderedSame;
        }
        
    }];
    NSMutableArray *neibRooms = [NSMutableArray array];
    for (int i=0; i<30; i++) {
        if ([sortedRooms objectAtIndex:i] != [sortedRooms lastObject]) {
            [neibRooms addObject:[sortedRooms objectAtIndex:i]];
        } else {
            [neibRooms addObject:[sortedRooms objectAtIndex:i]];
            break;
        }
    }
    return neibRooms;
}

// distances for local rooms
-(NSMutableArray *)arrayOfDistances:(NSArray *)objects{
    NSMutableArray *chatRoomDistances = [NSMutableArray array];
    for (QBCOCustomObject *object in objects) {
        CLLocation *room = [[CLLocation alloc] initWithLatitude:[[[object fields] objectForKey:kLatitude] doubleValue] longitude:[[[object fields] objectForKey:kLongitude] doubleValue]];
        NSInteger distance = [[LocationService shared].myLocation distanceFromLocation:room];
        [chatRoomDistances addObject:[NSNumber numberWithInt:distance]];
    }
    return chatRoomDistances;
}

-(NSInteger)distanceFromNewRoom:(QBCOCustomObject *)room{
    CLLocation *newRoom = [[CLLocation alloc] initWithLatitude:[[[room fields] objectForKey:kLatitude] doubleValue] longitude:[[[room fields] objectForKey:kLongitude] doubleValue]];
    NSInteger distance = [[LocationService shared].myLocation distanceFromLocation:newRoom];
    return distance;
}

@end
