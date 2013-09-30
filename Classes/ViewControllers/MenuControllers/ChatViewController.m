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

@interface ChatViewController ()
@property (nonatomic, strong) IBOutlet UITableView *trendingTableView;
@property (strong, nonatomic) IBOutlet UITableView *locationTableView;

@property (nonatomic, strong) NSArray *locations;
@property (nonatomic, strong) TrendingDataSource *trendingDataSource;
@property (nonatomic, strong) LocationDataSource *locationDataSource;
@end

@implementation ChatViewController


#pragma mark - 
#pragma mark LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.trendingTableView.dataSource = self.trendingDataSource;
    self.locationTableView.dataSource = self.locationDataSource;
    self.trendingTableView.delegate = self;
    self.locationTableView.delegate = self;
    
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
    QBCOCustomObject *currentObject = [_locations objectAtIndex:[indexPath row]];
    NSString *room = [currentObject.fields objectForKey:kName];
    [FBService shared].roomName = room;
    [FBService shared].roomID = currentObject.ID;
    [self performSegueWithIdentifier:@"kSegue" sender:nil];
}

#pragma mark -
#pragma mark Custom Objects

-(void)getChatRooms{
    NSMutableDictionary *extRequest = [NSMutableDictionary dictionary];
    [extRequest setObject:@"rank" forKey:@"sort_desc"];
    [QBCustomObjects objectsWithClassName:kChatRoom extendedRequest:extRequest delegate:self];
}


#pragma marak -
#pragma mark QBActionStatusDelegate

-(void)completedWithResult:(Result *)result{
    if ([result success]) {
        if ([result isKindOfClass:[QBCOCustomObjectPagedResult class]]) {
            
            // reload tables
            QBCOCustomObjectPagedResult *customObjects = (QBCOCustomObjectPagedResult *)result;
            _locations = customObjects.objects;
            _trendingDataSource.chatRooms = _locations;
            _locationDataSource.chatRooms = customObjects.objects;
            [self.trendingTableView reloadData];
            [self.locationTableView reloadData];
        }
    }
}


//#pragma mark - Sort
//
//-(NSArray *)sortingCustomObjects:(NSArray *)rooms{
//    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"fields.rank" ascending:NO selector:@selector(localizedCompare:)];
//    NSArray *sortedRooms = [rooms sortedArrayUsingDescriptors:@[descriptor]];
//    return sortedRooms;
//}


#pragma mark - 
#pragma mark Private Room

- (IBAction)createPrivateRoom:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Creating room" message:@"Name of Room:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}


#pragma mark - 
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 1:
            if (![[[alertView textFieldAtIndex:0] text] isEqual:@""]) {
                [FBService shared].roomName = [[alertView textFieldAtIndex:0] text];
                [self performSegueWithIdentifier:@"kSegue" sender:nil];
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
