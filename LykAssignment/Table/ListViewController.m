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
        
        // Table Node
        self.tableNode = [[ASTableNode alloc] initWithStyle:UITableViewStylePlain];
        self.tableNode.delegate = self;
        self.tableNode.dataSource = self;
        
        __weak typeof(self) weakSelf = self;
        self.node.layoutSpecBlock = ^ASLayoutSpec * _Nonnull(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
            return [ASWrapperLayoutSpec wrapperWithLayoutElement:weakSelf.tableNode];
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
    [_refreshControl beginRefreshing];
    
    
    dispatch_group_t group = dispatch_group_create();

    [self fetchGoogle:nil];
    
//    dispatch_group_enter(group);
//    [self fetchFacebook];
//
//    dispatch_group_enter(group);
//    [self fetchGoogle:^(BOOL finish) {
//
//    }];
//
//    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//        NSLog(@"finally!");
//    });
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
                     
                     [weakSelf.tableNode performBatchUpdates:^{
                         NSMutableArray *insertIndexPaths = [NSMutableArray array];
                         NSMutableArray *deleteIndexPaths = [NSMutableArray array];
                         
                         NSArray *oldData = [weakSelf.dataList copy];
                         for(id oldModel in oldData) {
                             if(![oldModel isKindOfClass:[GoogleConnectionModel class]]) {
                                 return;
                             }
                             NSInteger oldItem = [oldData indexOfObject:oldModel];
                             [weakSelf.dataList removeObject:oldModel];
                             [deleteIndexPaths addObject:[NSIndexPath indexPathForItem:oldItem inSection:0]];
                         }
                         
                         for(GoogleConnectionModel *connection in data.connections) {
                             [weakSelf.dataList addObject:connection];
                             NSInteger item = [weakSelf.dataList indexOfObject:connection];
                             [insertIndexPaths addObject:[NSIndexPath indexPathForItem:item inSection:0]];
                         }
                         
                         [weakSelf.tableNode insertRowsAtIndexPaths:insertIndexPaths
                                                   withRowAnimation:UITableViewRowAnimationFade];
                         [weakSelf.tableNode deleteRowsAtIndexPaths:deleteIndexPaths
                                                   withRowAnimation:UITableViewRowAnimationNone];
                     } completion:nil];
                 }
             }
             [_refreshControl endRefreshing];
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             [_refreshControl endRefreshing];
         }];
}

- (void)fetchFacebook {
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
        if(![result isKindOfClass:[NSDictionary class]]) {
            return;
        }
        
        NSError *modelErr;
        FacebookModel *facebook = [[FacebookModel alloc] initWithDictionary:result
                                                                      error:&modelErr];
        
        [weakSelf.tableNode performBatchUpdates:^{
            NSMutableArray *insertIndexPaths = [NSMutableArray array];
            NSMutableArray *deleteIndexPaths = [NSMutableArray array];
            
            NSArray *oldData = [weakSelf.dataList copy];
            for(id oldModel in oldData) {
                if(![oldModel isKindOfClass:[FacebookDataModel class]]) {
                    return;
                }
                NSInteger oldItem = [oldData indexOfObject:oldModel];
                [weakSelf.dataList removeObject:oldModel];
                [deleteIndexPaths addObject:[NSIndexPath indexPathForItem:oldItem inSection:0]];
            }
            
            for(FacebookDataModel *fbData in facebook.data) {
                [weakSelf.dataList addObject:fbData];
                NSInteger item = [weakSelf.dataList indexOfObject:fbData];
                [insertIndexPaths addObject:[NSIndexPath indexPathForItem:item inSection:0]];
            }
            
            [weakSelf.tableNode insertRowsAtIndexPaths:insertIndexPaths
                                      withRowAnimation:UITableViewRowAnimationFade];
            [weakSelf.tableNode deleteRowsAtIndexPaths:deleteIndexPaths
                                      withRowAnimation:UITableViewRowAnimationNone];
        } completion:nil];
        
        if(modelErr) {
            NSLog(@"Model Error: %@", modelErr);
            return;
        }
    }];
}

#pragma mark - ASTableDataSource

- (NSInteger)numberOfSectionsInTableNode:(ASTableNode *)tableNode {
    return 1;
}

- (NSInteger)tableNode:(ASTableNode *)tableNode numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (ASCellNodeBlock)tableNode:(ASTableNode *)tableNode nodeBlockForRowAtIndexPath:(NSIndexPath *)indexPath {
    id data = [self.dataList objectAtIndex:indexPath.row];
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
                     } completion:^(BOOL finished) {
                         [context completeBatchFetching:YES];
                     }];
                 } else {
                     [context completeBatchFetching:YES];
                 }
             } else {
                 [context completeBatchFetching:YES];
             }
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             [context completeBatchFetching:YES];
         }];
}

- (BOOL)shouldBatchFetchForTableNode:(ASTableNode *)tableNode {
    if(self.googleData.nextPageToken && self.dataList.count > 0) {
        if(self.googleData.totalItems > self.dataList.count) {
            return YES;
        } else {
            return NO;
        }
    }
    return NO;
}


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
