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

@interface ListViewController : ASViewController <ASTableDelegate, ASTableDataSource> {
    UIRefreshControl *_refreshControl;
}

@property (strong, nonatomic) ASTableNode *tableNode;

@property (strong, nonatomic) GoogleModel *googleData;

@property (strong, nonatomic) NSMutableArray *dataList;

@end
