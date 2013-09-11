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

@interface ChatViewController ()
@property (nonatomic, strong) IBOutlet UITableView *trendingTableView;
@property (strong, nonatomic) IBOutlet UITableView *locationTableView;
@property (nonatomic, strong) NSArray *names;
@property (nonatomic, strong) NSArray *geoDataArray;
@property (nonatomic, strong) TrendingDataSource *trendingDataSource;
@property (nonatomic, strong) LocationDataSource *locationDataSource;
@end

@implementation ChatViewController


#pragma mark - 
#pragma mark LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSArray *array = [[NSArray alloc] initWithObjects:@"Andrey", @"Anton", @"Alex", @"Alexey",@"Alexandr", @"Bob", @"Bogdan", @"Denis", @"Dmitriy", @"Evgeniy", @"Elisey",@"Fillipp",@"Greg", @"Georg", @"Gleb", @"Igor",@"Illya", @"John", @"Job", @"Konstantin",@"Mitya", nil];
    self.names = array;
    
    self.trendingTableView.dataSource = self.trendingDataSource;
    self.locationTableView.dataSource = self.locationDataSource;
    
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


#pragma mark -
#pragma mark Custom Objects

-(void)getChatRooms{
    [QBCustomObjects objectsWithClassName:kChatRoom delegate:self];
}


#pragma marak -
#pragma mark QBActionStatusDelegate

-(void)completedWithResult:(Result *)result{
    if ([result success]) {
        if ([result isKindOfClass:[QBCOCustomObjectPagedResult class]]) {
            
            // reload tables
            QBCOCustomObjectPagedResult *customObject = (QBCOCustomObjectPagedResult *)result;
            _trendingDataSource.chatRooms = customObject.objects;
            _locationDataSource.chatRooms = customObject.objects;
            [self.trendingTableView reloadData];
            [self.locationTableView reloadData];
        }
    }
}

@end
