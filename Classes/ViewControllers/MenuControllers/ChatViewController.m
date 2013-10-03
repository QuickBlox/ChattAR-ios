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

@property (nonatomic, strong) NSArray *trendings;
@property (nonatomic, strong) NSArray *locations;

@property (nonatomic, strong) TrendingDataSource *trendingDataSource;
@property (nonatomic, strong) LocationDataSource *locationDataSource;

@property (nonatomic, strong) UIActivityIndicatorView *trendingActivityIndicator;
@property (nonatomic, strong) UILabel *trendingFooterLabel;
@property (nonatomic, strong) UIActivityIndicatorView *localActivityIndicator;
@property (nonatomic, strong) UILabel *localFooterLabel;

@end

@implementation ChatViewController


#pragma mark - 
#pragma mark LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    _trendings = [[NSArray alloc] init];
    _locations = [[NSArray alloc] init];
    
    _trendingTableView.tag = kTrendingTableViewTag;
    _locationTableView.tag = kLocalTableViewTag;
    
    self.trendingTableView.dataSource = self.trendingDataSource;
    self.locationTableView.dataSource = self.locationDataSource;
    
    self.trendingTableView.delegate = self;
    self.locationTableView.delegate = self;
    
    // paginator:
    self.trendingPaginator = [[MyPaginator alloc] initWithPageSize:10 delegate:self];
    self.localPaginator = [[MyPaginator alloc] initWithPageSize:10 delegate:self];

    self.trendingPaginator.tag = kTrendingPaginatorTag;
    self.localPaginator.tag = kLocalPaginatorTag;
    
    self.trendingTableView.tableFooterView = [self creatingTrendingFooter];
    self.locationTableView.tableFooterView = [self creatingLocalFooter];
    
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
    [super viewWillAppear:animated];
    if ([_trendings count] == 0) {
        [self.trendingPaginator fetchFirstPage];
    }
    if ([_locations count] == 0) {
        [self.localPaginator fetchFirstPage];
    }
    
    // send presence
    if (self.presenceTimer == nil) {
        self.presenceTimer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:[QBChat instance] selector:@selector(sendPresence) userInfo:nil repeats:YES];
    }
    [self.trendingTableView reloadData];
    [self.locationTableView reloadData];
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

- (void)fetchNextPage:(MyPaginator *)paginator
{
    [paginator fetchNextPage];
    if (paginator.tag == kTrendingPaginatorTag) {
        [self.trendingActivityIndicator startAnimating];
    }
    if (paginator.tag == kLocalPaginatorTag) {
        [self.localActivityIndicator startAnimating];
    }
}

- (void)updateTableViewFooterWithPaginator:(MyPaginator *)paginator
{
    if ([paginator.results count] != 0)
    {
        if (paginator.tag == kTrendingPaginatorTag) {
            self.trendingFooterLabel.text = [NSString stringWithFormat:@"%d results out of %d", [paginator.results count], paginator.total];
            [self.trendingFooterLabel setNeedsDisplay];
        }
        if (paginator.tag == kLocalPaginatorTag) {
            self.localFooterLabel.text = [NSString stringWithFormat:@"%d results out of %d", [paginator.results count], paginator.total];
            [self.localFooterLabel setNeedsDisplay];
        }
    } else
    {
        self.trendingFooterLabel.text = @"";
        self.localFooterLabel.text = @"";
        [self.trendingFooterLabel setNeedsDisplay];
        [self.localFooterLabel setNeedsDisplay];
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

-(UIView *)creatingLocalFooter {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _locationTableView.frame.size.width, 44.0f)];
    footerView.backgroundColor = [UIColor clearColor];
    _localFooterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _locationTableView.frame.size.width, 44.0f)];
    _localFooterLabel.backgroundColor = [UIColor clearColor];
    _localFooterLabel.textAlignment = UITextAlignmentCenter;
    _localFooterLabel.textColor = [UIColor lightGrayColor];
    _localFooterLabel.font = [UIFont systemFontOfSize:16];
    [footerView addSubview:_localFooterLabel];
    
    self.localActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.localActivityIndicator.center = CGPointMake(40.0, 22.0);
    self.localActivityIndicator.hidesWhenStopped = YES;
    [footerView addSubview:self.localActivityIndicator];
    
    UIImageView *shadow = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 13, 44)];
    shadow.image = [UIImage imageNamed:@"shadow_main.png"];
    [footerView addSubview:shadow];
    return footerView;
}


#pragma mark - 
#pragma mark ScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    // when reaching bottom, load a new page
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
        if (scrollView.tag == kLocalTableViewTag) {
        // ask next page only if we haven't reached last page
        if(![self.localPaginator reachedLastPage])
            {
                // fetch next page of results
                [self fetchNextPage:self.localPaginator];
            }
        }
    }
}


#pragma mark -
#pragma mark NMPaginatorDelegate

- (void)paginator:(id)paginator didReceiveResults:(NSArray *)results
{
    [self updateTableViewFooterWithPaginator:paginator];
    // handle new results
    if ([paginator tag] == kTrendingPaginatorTag) {
        _trendings = [_trendings arrayByAddingObjectsFromArray:results];
        _trendingDataSource.chatRooms = _trendings;
        [self.trendingActivityIndicator stopAnimating];
    }
    
    if ([paginator tag] == kLocalPaginatorTag) {
        _locations = [_locations arrayByAddingObjectsFromArray:results];
        _locationDataSource.chatRooms = _locations;
        [self.localActivityIndicator stopAnimating];
    }
    
    [self updateTableViewFooterWithPaginator:paginator];
    //reload tables:
    [self.trendingTableView reloadData];
    [self.locationTableView reloadData];
}

- (void)paginatorDidReset:(id)paginator
{
    [self.trendingTableView reloadData];
    [self.locationTableView reloadData];
    [self updateTableViewFooterWithPaginator:paginator];
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
    [ChatRooms action].tableViewTag = tableView.tag;
    [ChatRooms action].currentPath = indexPath;
    QBCOCustomObject *currentObject;
    if (tableView.tag == kTrendingTableViewTag) {
        [[ChatRooms action] setTrendingRooms:_trendings];
       currentObject =  [_trendings objectAtIndex:[indexPath row]];
    }
    if (tableView.tag == kLocalTableViewTag) {
        [[ChatRooms action] setLocalRooms:_locations];
       currentObject = [_locations objectAtIndex:[indexPath row]];
    }
    
    NSString *room = [currentObject.fields objectForKey:kName];
    [FBService shared].roomName = room;
    [FBService shared].roomID = currentObject.ID;
    [self performSegueWithIdentifier:@"kSegue" sender:nil];
}


#pragma marak -
#pragma mark QBActionStatusDelegate

-(void)completedWithResult:(Result *)result{
    if ([result success]) {
        if([result isKindOfClass:QBCOCustomObjectResult.class]){
            QBCOCustomObjectResult *createObjectResult = (QBCOCustomObjectResult *)result;
            NSLog(@"Created object: %@", createObjectResult.object);
            [self performSegueWithIdentifier:@"kSegue" sender:nil];
        }
    }
}


#pragma mark - 
#pragma mark Actions

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
                NSArray *names = [self getNamesOfRooms:[[ChatRooms action] getTrendingRooms]];
#warning Change rooms!!!
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
