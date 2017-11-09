//
//  ListCellNode.h
//  LykAssignment
//
//  Created by Juston Paul Alcantara on 07/11/2017.
//  Copyright © 2017 Juston Paul Alcantara. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import <ChameleonFramework/Chameleon.h>

#import <GoogleSignIn/GoogleSignIn.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import <OneSignal/OneSignal.h>

#import <AFNetworking/AFNetworking.h>

@interface ListCellNode : ASCellNode

@property (strong, nonatomic) ASNetworkImageNode *profileImageNode;

@property (strong, nonatomic, readonly) ASTextNode *nameTextNode;

@property (strong, nonatomic, readonly) ASTextNode *emailTextNode;
@property (strong, nonatomic, readonly) ASTextNode *phoneTextNode;

@property (nonatomic, copy) NSString *nameText;
@property (nonatomic, copy) NSString *emailText;
@property (nonatomic, copy) NSString *phoneText;

@property (strong, nonatomic) ASButtonNode *inviteButtonNode;

@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *socialType;

@end
