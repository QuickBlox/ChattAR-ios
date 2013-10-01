//
//  ChatViewController.m
//  ChattAR
//
//  Created by Igor Alefirenko on 28/08/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//
#import "SASlideMenuRootViewController.h"
#import "ChatViewController.h"
#import "TrendingDataSource.h"
#import "LocationDataSource.h"
#import "FBService.h"
#import "DataManager.h"
#import "ChatRooms.h"
#import "GeoData.h"

@interface ChatViewController ()
@property (nonatomic, strong) IBOutlet UITableView *trendingTableView;
@property (strong, nonatomic) IBOutlet UITableView *locationTableView;

@property (nonatomic, strong) NSArray *locations;
@property (nonatomic, strong) TrendingDataSource *trendingDataSource;
@property (nonatomic, strong) LocationDataSource *locationDataSource;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UILabel *footerLabel;
@end

@implementation ChatViewController


#pragma mark - 
#pragma mark LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    _locations = [[NSMutableArray alloc] init];
    self.trendingTableView.dataSource = self.trendingDataSource;
    self.locationTableView.dataSource = self.locationDataSource;
    self.trendingTableView.delegate = self;
    self.locationTableView.delegate = self;
    
    // paginator:
    self.myPaginator = [[MyPaginator alloc] initWithPageSize:10 delegate:self];
    self.trendingTableView.tableFooterView = [self creatingTableViewFooter];
    
    // if iPhone 5
    self.scrollView.pagingEnabled = YES;
    if(IS_HEIGHT_GTE_568){
        self.scrollView.contentSize = CGSizeMake(522, 504);
    } else {
        self.scrollView.contentSize = CGSizeMake(522, 416);
    }
    [self performSegueWithIdentifier:@"Splash" sender:self];
}

-(void)viewWillAppear:(BOOL)animated{
    [self getChatRooms];
    [super viewWillAppear:animated];
    if ([_locations count] == 0) {
        [self.myPaginator fetchFirstPage];
    }
    
    // send presence
    if (self.presenceTimer == nil) {
        self.presenceTimer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:[QBChat instance] selector:@selector(sendPresence) userInfo:nil repeats:YES];
    }
    [self.trendingTableView reloadData];
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setLocationTableView:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Paginator

- (void)fetchNextPage
{
    [self.myPaginator fetchNextPage];
    [self.activityIndicator startAnimating];
}

- (void)updateTableViewFooter
{
    if ([self.myPaginator.results count] != 0)
    {
        self.footerLabel.text = [NSString stringWithFormat:@"%d results out of %d", [self.myPaginator.results count], self.myPaginator.total];
    } else
    {
        self.footerLabel.text = @"";
    }
    
    [self.footerLabel setNeedsDisplay];
}

-(UIView *)creatingTableViewFooter {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
    footerView.backgroundColor = [UIColor clearColor];
    _footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
    _footerLabel.backgroundColor = [UIColor clearColor];
    _footerLabel.textAlignment = UITextAlignmentCenter;
    _footerLabel.textColor = [UIColor lightGrayColor];
    _footerLabel.font = [UIFont systemFontOfSize:16];
    _footerLabel.text = @"10 out of nil";
    [footerView addSubview:_footerLabel];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicator.center = CGPointMake(44.0, 22.0);
    self.activityIndicator.hidesWhenStopped = YES;
    [footerView addSubview:self.activityIndicator];
    return footerView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    // when reaching bottom, load a new page
    if (scrollView.contentOffset.y == scrollView.contentSize.height - scrollView.bounds.size.height)
    {
        // ask next page only if we haven't reached last page
        if(![self.myPaginator reachedLastPage])
        {
            // fetch next page of results
            [self fetchNextPage];
        }
    }
}


#pragma mark -
#pragma mark NMPaginatorDelegate

- (void)paginator:(id)paginator didReceiveResults:(NSArray *)results
{
    [self updateTableViewFooter];
    // handle new results
    NSLog(@"%@",results);
    _locations = [_locations arrayByAddingObjectsFromArray:results];
    [self.activityIndicator stopAnimating];
    [self viewWillAppear:NO];
}

- (void)paginatorDidReset:(id)paginator
{
    [self.trendingTableView reloadData];
    [self updateTableViewFooter];
}


#pragma mark -
#pragma mark Data Sources


- (TrendingDataSource *)trendingDataSource
{
    if (!_trendingDataSource)
    {
        _trendingDataSource = [TrendingDataSource new];
    }
    
    return _trendingDataSource;
}

- (LocationDataSource *)locationDataSource
{
    if (!_locationDataSource)
    {
        _locationDataSource = [LocationDataSource new];
    }
    
    return _locationDataSource;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"kSegue"]){
        
    }
}

#pragma mark -
#pragma mark Table View Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [ChatRooms action].currentPath = indexPath;
    QBCOCustomObject *currentObject = [_locations objectAtIndex:[indexPath row]];
    NSString *room = [currentObject.fields objectForKey:kName];
    [FBService shared].roomName = room;
    [FBService shared].roomID = currentObject.ID;
    [self performSegueWithIdentifier:@"kSegue" sender:nil];
}


#pragma marak -
#pragma mark QBActionStatusDelegate

-(void)completedWithResult:(Result *)result{
    if ([result success]) {
        if ([result isKindOfClass:[QBCOCustomObjectPagedResult class]]) {
            
            // reload tables
            QBCOCustomObjectPagedResult *customObjects = (QBCOCustomObjectPagedResult *)result;
            [[ChatRooms action] setRooms:_locations];
            _trendingDataSource.chatRooms = _locations;
            _locationDataSource.chatRooms = customObjects.objects;
            [self.trendingTableView reloadData];
            [self.locationTableView reloadData];
        }
        if([result isKindOfClass:QBCOCustomObjectResult.class]){
            QBCOCustomObjectResult *createObjectResult = (QBCOCustomObjectResult *)result;
            NSLog(@"Created object: %@", createObjectResult.object);
            [self performSegueWithIdentifier:@"kSegue" sender:nil];
        }
    }
}


#pragma mark - 
#pragma mark Actions

-(void)getChatRooms{
    NSMutableDictionary *extRequest = [NSMutableDictionary dictionary];
    [extRequest setObject:@"rank" forKey:@"sort_desc"];
    [QBCustomObjects objectsWithClassName:kChatRoom extendedRequest:extRequest delegate:self];
}

- (IBAction)createPrivateRoom:(id)sender {
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
                [FBService shared].roomName = alertText;

                NSString *myLatitude = [[NSString alloc] initWithFormat:@"%f",[[GeoData getData] getMyCoorinates].latitude];
                NSString *myLongitude = [[NSString alloc] initWithFormat:@"%f", [[GeoData getData] getMyCoorinates].longitude];
                NSArray *names = [self getNamesOfRooms:[[ChatRooms action] getAllRooms]];
                BOOL flag = NO;
                for (NSString *name in names) {
                    if ([alertText isEqual:name]) {
                        flag = YES;
                    }
                }
                
                if (flag == YES) {
                    UIAlertView *newAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Room has already exists" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
                    [newAlert show];
                } else {
                    QBCOCustomObject *object = [QBCOCustomObject customObject];
                    object.className = kChatRoom;
                    [object.fields setObject:myLatitude forKey:kLatitude];
                    [object.fields setObject:myLongitude forKey:kLongitude];
                    [object.fields setObject:alertText forKey:kName];
                    [object.fields setObject:[NSNumber numberWithInt:0] forKey:kRank];
                    [QBCustomObjects createObject:object delegate:self];
                }
            }
            break;
            
        default:
            break;
    }

}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView{
    return YES;
}

@end
