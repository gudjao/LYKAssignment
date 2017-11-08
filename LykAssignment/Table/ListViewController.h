//
//  ListViewController.h
//  LykAssignment
//
//  Created by Juston Paul Alcantara on 07/11/2017.
//  Copyright © 2017 Juston Paul Alcantara. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import <ChameleonFramework/Chameleon.h>
#import <AFNetworking/AFNetworking.h>

#import <GoogleSignIn/GoogleSignIn.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import <GTLRService.h>

#import "GoogleModel.h"
#import "FacebookModel.h"

#import "ListCellNode.h"

@interface ListViewController : ASViewController <ASTableDelegate, ASTableDataSource, UISearchBarDelegate> {
    UIRefreshControl *_refreshControl;
    BOOL _willBatchFetch;
    BOOL _isFiltered;
}

// Search
@property (strong, nonatomic) ASDisplayNode *searchBarNode;

// Table
@property (strong, nonatomic) ASTableNode *tableNode;

// Google data
@property (strong, nonatomic) GoogleModel *googleData;

// List
@property (strong, nonatomic) NSMutableArray *dataList;
@property (strong, nonatomic) NSMutableArray *filteredDataList;

@end
