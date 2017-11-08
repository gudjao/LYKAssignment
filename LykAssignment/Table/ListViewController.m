//
//  ListViewController.m
//  LykAssignment
//
//  Created by Juston Paul Alcantara on 07/11/2017.
//  Copyright © 2017 Juston Paul Alcantara. All rights reserved.
//

#import "ListViewController.h"

@interface ListViewController ()

@end

@implementation ListViewController

- (instancetype)init {
    ASDisplayNode *node = [[ASDisplayNode alloc] init];
    node.backgroundColor = [UIColor flatWhiteColor];
    self = [super initWithNode:node];
    if(self) {
        // Config
        self.node.automaticallyManagesSubnodes = YES;
        
        // Search
        self.searchBarNode = [[ASDisplayNode alloc] initWithViewBlock:^UIView * _Nonnull {
            UISearchBar *searchBar = [[UISearchBar alloc] init];
            searchBar.barStyle = UIBarStyleDefault;
            //searchBar.searchBarStyle = UISearchBarStyleMinimal;
            searchBar.delegate = self;
            return searchBar;
        }];
        
        // Table Node
        self.tableNode = [[ASTableNode alloc] initWithStyle:UITableViewStylePlain];
        self.tableNode.delegate = self;
        self.tableNode.dataSource = self;
        self.tableNode.view.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
        
        __weak typeof(self) weakSelf = self;
        self.node.layoutSpecBlock = ^ASLayoutSpec * _Nonnull(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
            weakSelf.tableNode.style.preferredSize = constrainedSize.max;
            weakSelf.tableNode.style.flexGrow = YES;
            weakSelf.tableNode.style.flexShrink = YES;
            
            CGFloat inset;
            if ((self.edgesForExtendedLayout & UIRectEdgeTop) == 0) {
                inset = 0.0;
            } else {
                inset = CGRectGetHeight(weakSelf.navigationController.navigationBar.frame) + CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
            }
            
            ASLayoutSpec *spacer = [ASLayoutSpec new];
            spacer.style.height = ASDimensionMakeWithPoints(inset);
            
            weakSelf.searchBarNode.style.flexShrink = 1.0f;
            weakSelf.searchBarNode.style.flexGrow = 1.0f;
            weakSelf.searchBarNode.style.height = ASDimensionMake(54.0f);
            
            ASStackLayoutSpec *stackContent = [ASStackLayoutSpec
                                               stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical
                                               spacing:0.0f
                                               justifyContent:ASStackLayoutJustifyContentStart
                                               alignItems:ASStackLayoutAlignItemsStretch
                                               children:@[spacer,
                                                          weakSelf.searchBarNode,
                                                          weakSelf.tableNode]];
            
            return stackContent;
        };
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.hidden = NO;
    
    if (![FBSDKAccessToken currentAccessToken]) {
        //[self.navigationController popViewControllerAnimated:YES];
    }
    
    // Set navbar title.
    self.navigationItem.title = @"List";
    
    // Data
    _willBatchFetch = 0;
    _isFiltered = 0;
    self.dataList = [NSMutableArray new];
    self.googleData = nil;
    
    // Refresh Controller
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(fetchList) forControlEvents:UIControlEventValueChanged];
    [self.tableNode.view addSubview:_refreshControl];
    [_refreshControl layoutIfNeeded];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    // Get data
    [self fetchList];
}

#pragma mark - Fetch

- (void)fetchList {
    if(_isFiltered) {
        return;
    }
    
    [_refreshControl beginRefreshing];
    
    dispatch_group_t group = dispatch_group_create();
    
    __block NSArray *oldData = [self.dataList copy];
    _willBatchFetch = 0;
    
    dispatch_group_enter(group);
    [self fetchFacebook:^(BOOL finish) {
        dispatch_group_leave(group);
    }];
    
    dispatch_group_enter(group);
    [self fetchGoogle:^(BOOL finish) {
        dispatch_group_leave(group);
    }];
    
    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            _willBatchFetch = 1;
            
            [self.tableNode performBatchUpdates:^{
                NSMutableArray *insertIndexPaths = [NSMutableArray array];
                NSMutableArray *deleteIndexPaths = [NSMutableArray array];
                
                for(id oldObject in oldData) {
                    NSInteger oldItem = [oldData indexOfObject:oldObject];
                    [self.dataList removeObject:oldObject];
                    [deleteIndexPaths addObject:[NSIndexPath indexPathForItem:oldItem inSection:0]];
                }
                
                for(id newObject in self.dataList ) {
                    NSInteger item = [self.dataList indexOfObject:newObject];
                    [insertIndexPaths addObject:[NSIndexPath indexPathForItem:item inSection:0]];
                }
                
                [self.tableNode insertRowsAtIndexPaths:insertIndexPaths
                                      withRowAnimation:UITableViewRowAnimationFade];
                [self.tableNode deleteRowsAtIndexPaths:deleteIndexPaths
                                      withRowAnimation:UITableViewRowAnimationNone];
            } completion:nil];
            
            [_refreshControl endRefreshing];
        });
    });
}

- (void)fetchGoogle:(void (^)(BOOL finish))completion {
    GIDSignIn *signIn = [GIDSignIn sharedInstance];
    
    NSString *accessToken = signIn.currentUser.authentication.accessToken;
    NSString *urlString = [NSString stringWithFormat:@"https://people.googleapis.com/v1/people/me/connections?pageSize=10&personFields=photos,emailAddresses,names,phoneNumbers&access_token=%@", accessToken];
    NSString *urlEncoded = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    __weak typeof(self) weakSelf = self;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:urlEncoded
      parameters:nil
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             if([responseObject isKindOfClass:[NSDictionary class]]) {
                 NSError *modelErr;
                 GoogleModel *data = [[GoogleModel alloc] initWithDictionary:responseObject
                                                                       error:&modelErr];
                 if(!modelErr) {
                     weakSelf.googleData = data;
                     
                     for(GoogleConnectionModel *connection in data.connections) {
                         [weakSelf.dataList addObject:connection];
                     }
                     
                     completion(1);
                 } else {
                     completion(0);
                 }
             } else {
                 completion(0);
             }
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             completion(0);
         }];
}

- (void)fetchFacebook:(void (^)(BOOL finish))completion { 
    // Facebook friends
    NSDictionary *params = @{
                             @"fields" : @"id,name,email,picture"
                             };
    
    NSString *userId = [FBSDKAccessToken currentAccessToken].userID;
    
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:[NSString stringWithFormat:@"/%@/friends", userId]
                                  parameters:params
                                  HTTPMethod:@"GET"];
    
    __weak typeof(self) weakSelf = self;
    
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                          id result,
                                          NSError *error) {
        // Handle the result
        if(![result isKindOfClass:[NSDictionary class]] || error) {
            completion(0);
            return;
        }
        
        NSError *modelErr;
        FacebookModel *facebook = [[FacebookModel alloc] initWithDictionary:result
                                                                      error:&modelErr];
        
        if(modelErr) {
            completion(0);
            return;
        }
        
        for(FacebookDataModel *fbData in facebook.data) {
            [weakSelf.dataList addObject:fbData];
        }
        
        completion(1);
    }];
}

#pragma mark - ASTableDataSource

- (NSInteger)numberOfSectionsInTableNode:(ASTableNode *)tableNode {
    return 1;
}

- (NSInteger)tableNode:(ASTableNode *)tableNode numberOfRowsInSection:(NSInteger)section {
    if(_isFiltered) {
        return self.filteredDataList.count;
    } else {
        return self.dataList.count;
    }
}

- (ASCellNodeBlock)tableNode:(ASTableNode *)tableNode nodeBlockForRowAtIndexPath:(NSIndexPath *)indexPath {
    id data;
    if(_isFiltered) {
        data = [self.filteredDataList objectAtIndex:indexPath.row];
    } else {
        data = [self.dataList objectAtIndex:indexPath.row];
    }
    return ^{
        ListCellNode *cellNode = [[ListCellNode alloc] init];
        
        if([data isKindOfClass:[GoogleConnectionModel class]]) {
            GoogleConnectionModel *googleData = (GoogleConnectionModel *)data;
            
            GooglePhotoModel *photo = googleData.photos.firstObject;
            GoogleNameModel *name = googleData.names.firstObject;
            GoogleEmailModel *email = googleData.emailAddresses.firstObject;
            GooglePhoneModel *number = googleData.phoneNumbers.firstObject;
            
            cellNode.profileImageNode.URL = [NSURL URLWithString:photo.url];
            cellNode.nameText = name.displayNameLastFirst;
            cellNode.emailText = email.value;
            cellNode.phoneText = number.value;
        } else if([data isKindOfClass:[FacebookDataModel class]]) {
            FacebookDataModel *facebookData = (FacebookDataModel *)data;
            
            cellNode.profileImageNode.URL = [NSURL URLWithString:facebookData.pictureUrl];
            cellNode.nameText = facebookData.name;
            cellNode.emailText = @"";
            cellNode.phoneText = @"";
        }
        
        return cellNode;
    };
}

#pragma mark - ASTAbleDelegate

- (void)tableNode:(ASTableNode *)tableNode willBeginBatchFetchWithContext:(ASBatchContext *)context {
    [context beginBatchFetching];
    
    GIDSignIn *signIn = [GIDSignIn sharedInstance];
    
    NSString *accessToken = signIn.currentUser.authentication.accessToken;
    NSString *pageToken = self.googleData.nextPageToken ? self.googleData.nextPageToken : @"";
    NSString *urlString = [NSString stringWithFormat:@"https://people.googleapis.com/v1/people/me/connections?pageSize=10&personFields=photos,emailAddresses,names,phoneNumbers&pageToken=%@&access_token=%@", pageToken, accessToken];
    NSString *urlEncoded = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    __weak typeof(self) weakSelf = self;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:urlEncoded
      parameters:nil
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             if([responseObject isKindOfClass:[NSDictionary class]]) {
                 NSError *modelErr;
                 GoogleModel *data = [[GoogleModel alloc] initWithDictionary:responseObject
                                                                       error:&modelErr];
                 if(!modelErr) {
                     weakSelf.googleData = data;
                     
                     [weakSelf.tableNode performBatchUpdates:^{
                         NSMutableArray *insertIndexPaths = [NSMutableArray array];
                         
                         [weakSelf.dataList addObjectsFromArray:data.connections];
                         
                         for(GoogleConnectionModel *connection in data.connections) {
                             NSInteger item = [weakSelf.dataList indexOfObject:connection];
                             [insertIndexPaths addObject:[NSIndexPath indexPathForItem:item inSection:0]];
                         }
                         
                         [tableNode insertRowsAtIndexPaths:insertIndexPaths
                                          withRowAnimation:UITableViewRowAnimationFade];
                     } completion:nil];
                 }
             }
             [context completeBatchFetching:YES];
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             [context completeBatchFetching:YES];
         }];
}

- (BOOL)shouldBatchFetchForTableNode:(ASTableNode *)tableNode {
    if(_isFiltered) {
        return 0;
    }
    
    if(self.googleData.nextPageToken && self.dataList.count > 0) {
        if(_willBatchFetch) {
            return 1;
        } else {
            return 0;
        }
    }
    return 0;
}

#pragma mark - UISearchBar DataSource and Delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if(searchText.length == 0)
    {
        _isFiltered = false;
    }
    else
    {
        _isFiltered = true;
        self.filteredDataList = [[NSMutableArray alloc] init];
        NSMutableArray *searchArray = [NSMutableArray new];
        for (id object in self.dataList)
        {
            if([object isKindOfClass:[GoogleConnectionModel class]]) {
                NSDictionary *dataDict = [(GoogleConnectionModel *)object toDictionary];
                [searchArray addObject:dataDict];
            }
        }
        
        NSString *str = searchText;
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"ANY names.displayName CONTAINS %@", str];
        NSArray *result = [searchArray filteredArrayUsingPredicate:pred];
        
        for (NSDictionary *filteredDataDict in result) {
            GoogleConnectionModel *connection = [[GoogleConnectionModel alloc] initWithDictionary:filteredDataDict
                                                                                            error:nil];
            [self.filteredDataList addObject:connection];
        }
    }
    [self.tableNode reloadData];
}

#pragma mark - Memory Warning

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
